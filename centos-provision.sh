#!/usr/bin/env bash
set -euo pipefail

if [[ $(uname -r) == "3.10.0-957.12.2.el7.x86_64" ]]; then
  echo "==> Обновляем ядро"
  rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
  yum install -y yum-plugin-fastestmirror https://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
  yum -y --disablerepo=\* --enablerepo=elrepo-kernel install kernel-ml
  sed -i -e"s/^GRUB_DEFAULT=saved.*$/GRUB_DEFAULT=0/" /etc/default/grub
  grub2-mkconfig -o /boot/grub2/grub.cfg
  shutdown -r now
fi

generate_password() {
    echo $(cat /dev/urandom | tr -d -c 'a-zA-Z0-9' | fold -w 16 | head -1)
}

DISK=/dev/sdb
DIR=/var/lib/docker
if [[ ! $(df | grep ${DISK}) ]]; then
  echo "==> 1.1 Ensure a separate partition for containers has been created -> Монтируем /var/lib/docker в отдельный раздел"
  parted -s $DISK mklabel msdos
  parted -s -a opt $DISK mkpart primary ext4 0% 100%
  mkfs.ext4 "${DISK}1" >/dev/null
  mkdir -p $DIR
  mount "${DISK}1" $DIR
  echo "${DISK}1 $DIR ext4 defaults 0 0" >>/etc/fstab
fi

if ! [[ -x "$(command -v docker)" ]]; then
  echo "==> Добавляем репозиторий docker"
  yum install -y yum-utils device-mapper-persistent-data lvm2 >/dev/null
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo >/dev/null
fi

echo "==> Устанавливаем syslog docker docker-compose"
yum install -y nano syslog docker-ce docker-ce-cli containerd.io >/dev/null
echo "==> Устанавливаем trivy"
rpm -ivh https://github.com/aquasecurity/trivy/releases/download/v0.5.2/trivy_0.5.2_Linux-64bit.rpm >/dev/null
echo "==> 2.12 Ensure centralized and remote logging is configured -> Запускаем rsyslog"
systemctl start rsyslog
echo "==> Запускаем docker"
systemctl start docker

echo "==> 1.5 - 1.13 Ensure auditing is configured -> Конфигурируем auditd"
RULESD_DIR=/etc/audit/rules.d
AUDIT_RULES=$RULESD_DIR/audit.rules
DOCKER_RULES=$RULESD_DIR/docker.rules
if [[ ! -e $DOCKER_RULES ]]; then
  cat $AUDIT_RULES >$DOCKER_RULES
  {
    echo "-w /usr/bin/docker -k docker"
    echo "-w /usr/bin/dockerd -k docker"
    echo "-w /var/lib/docker -k docker"
    echo "-w /etc/docker -k docker"
    echo "-w /usr/lib/systemd/system/docker.service -k docker"
    echo "-w /usr/lib/systemd/system/docker.socket -k docker"
    echo "-w /etc/default/docker -k docker"
    echo "-w /etc/docker/daemon.json -k docker"
    echo "-w /usr/bin/docker-containerd -k docker"
    echo "-w /usr/bin/docker-runc -k docker"
  } >> $DOCKER_RULES
  systemctl daemon-reload
  service auditd restart >/dev/null
  auditctl -l
fi

if [[ ! -e /etc/docker/policies ]]; then
  echo "==> 2.11 - Ensure that authorization for Docker client commands is enabled -> Пишем authz.rego"
  mkdir -p /etc/docker/policies
  {
    echo "package docker.authz"
    echo ""
    echo "allow = true"
  } > /etc/docker/policies/authz.rego
fi

if [[ ! -e /root/docker-ca ]]; then
  echo "==> 2.6 Ensure TLS authentication for Docker daemon is configured -> Генерируем сертификаты"
  mkdir -p /root/docker-ca
  cd /root/docker-ca
  echo "==> Генерируем passphrase"
  PASS=$(generate_password)
  CN=$IP
  echo "==> Генерируем ключ центра сертификации"
  openssl genrsa -aes256 -passout "pass:$PASS" -out "ca-key.pem" 4096 >/dev/null
  echo "==> Генерируем сертификат центра сертификации"
  openssl req -new -x509 -days 365 -key "ca-key.pem" -sha256 -passin "pass:$PASS" -subj "/CN=$CN" -out "ca-cert.pem"

  if [[ ! -e /var/docker ]]; then
    mkdir -p /var/docker
  fi
  cd /var/docker
  echo "==> Генерируем серверный ключ"
  openssl genrsa -out "server-key.pem" 4096 >/dev/null
  echo "==> Генерируем серверный сертификат"
  openssl req -new -sha256 -key "server-key.pem" -subj "/CN=$CN" -out server.csr
  echo "subjectAltName = IP:$IP,IP:127.0.0.1" > extfile.cnf
  echo "extendedKeyUsage = serverAuth" >> extfile.cnf
  openssl x509 -req -days 365 -sha256 -in server.csr -passin "pass:$PASS" -CA "/root/docker-ca/ca-cert.pem" -CAkey "/root/docker-ca/ca-key.pem" -CAcreateserial -out "server-cert.pem" -extfile extfile.cnf

  mkdir -p ~/.docker
  cd ~/.docker
  echo "==> Генерируем клиентский ключ"
  openssl genrsa -out "key.pem" 4096 >/dev/null
  echo "==> Генерируем клиентский сертификат"
  openssl req -subj "/CN=root" -new -key "key.pem" -out client.csr
  echo "extendedKeyUsage = clientAuth" > extfile.cnf
  openssl x509 -req -days 365 -sha256 -in client.csr -passin "pass:$PASS" -CA "/root/docker-ca/ca-cert.pem" -CAkey "/root/docker-ca/ca-key.pem" -CAcreateserial -out "cert.pem" -extfile extfile.cnf
fi

#export DOCKER_CONTENT_TRUST=1
echo "==> 2.8 Enable user namespace support (Scored) -> Создаем subuid и subgid"
echo "vagrant:231072:65536" >/etc/subuid
echo "vagrant:231072:65536" >/etc/subgid

echo "==> 2.1 Ensure network traffic is restricted between containers on the default bridge -> Конфигурируем daemon.json"
echo "==> 2.14 Ensure live restore is Enabled -> Конфигурируем daemon.json"
echo "==> 2.15 Ensure Userland Proxy is Disabled -> Конфигурируем daemon.json"
echo "==> 2.18 Ensure containers are restricted from acquiring new privileges -> Конфигурируем daemon.json"
echo "==> 5.18 Ensure the default ulimit is overwritten at runtime, only if needed -> Конфигурируем daemon.json"
echo "==> Копируем daemon.json"
cp /vagrant/daemon.json /etc/docker

echo "==> Добавляем пользователя vagrant в группу docker"
usermod -aG docker vagrant >/dev/null

echo "==> Собираем образ"
IMAGE_NAME=signal-server:1.0
cd /vagrant
docker build -t ${IMAGE_NAME} . >/dev/null

echo "==> TRIVY"
echo "==> TRIVY: запускаем проверку"
/usr/local/bin/trivy ${IMAGE_NAME}

echo "==> SNYK"
echo "==> SNYK: cкачиваем образ snyk/snyk-cli:docker"
docker pull snyk/snyk-cli:docker >/dev/null
echo "==> SNYK: запускаем проверку"
docker run \
-e "SNYK_TOKEN=${SNYK_TOKEN}" \
-e "USER_ID=${UID}" \
-e "MONITOR=true" \
-v "/vagrant:/project" \
-v "/var/run/docker.sock:/var/run/docker.sock" \
snyk/snyk-cli:docker test --docker ${IMAGE_NAME} --file=Dockerfile

echo "==> Перезапускаем docker чтобы применить daemon.json"
systemctl restart docker
echo "==> 2.11 - Ensure that authorization for Docker client commands is enabled -> Устанавливаем opa-docker-authz"
docker plugin install --grant-all-permissions openpolicyagent/opa-docker-authz-v2:0.5 opa-args="-policy-file /opa/policies/authz.rego"
echo ',"authorization-plugins": ["openpolicyagent/opa-docker-authz-v2:0.5"]' >>/etc/docker/daemon.json
systemctl restart docker

echo "==> DOCKER-BENCH-SECURITY"
echo "==> DOCKER-BENCH-SECURITY: скачиваем образ docker/docker-bench-security"
docker pull docker/docker-bench-security >/dev/null
echo "==> DOCKER-BENCH-SECURITY: запускаем проверку"
docker run --net host --pid host --userns host --cap-add audit_control \
   -e DOCKER_CONTENT_TRUST=0 \
   -v /etc:/etc:ro \
   -v /usr/bin/docker-containerd:/usr/bin/docker-containerd:ro \
   -v /usr/bin/docker-runc:/usr/bin/docker-runc:ro \
   -v /usr/lib/systemd:/usr/lib/systemd:ro \
   -v /var/lib:/var/lib:ro \
   -v /var/run/docker.sock:/var/run/docker.sock:ro \
   --label docker_bench_security \
   docker/docker-bench-security ./docker-bench-security.sh
