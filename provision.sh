#!/usr/bin/env bash
set -euo pipefail

echo "==> Обновляем пакеты"
yum update -y >/dev/null

echo "==> Подключаем yum репозиторий nginx"
cp /vagrant/nginx.repo /etc/yum.repos.d/nginx.repo
yum-config-manager --enable nginx-mainline >/dev/null

echo "==> Устанавливаем setools policycoreutils policycoreutils-python setroubleshoot nginx"
yum install -y nano setools policycoreutils policycoreutils-python setroubleshoot nginx >/dev/null

echo "==> Перезапускаем auditd"
service auditd restart >/dev/null

echo "==> Смотрим статус SELinux"
sestatus | grep "SELinux status"

NGINX_CONF=/etc/nginx/conf.d/default.conf
PORT=5150
echo "==> Меняем порт nginx на ${PORT}"
sed -i -e"s/listen       80;/listen       ${PORT};/" ${NGINX_CONF}

#systemctl enable --now nginx

#setsebool -P nis_enabled 1

#semanage port --add --type http_port_t --proto tcp 5150

#ausearch -c 'nginx' --raw | audit2allow -M nginx-custom-port
#semodule -i nginx-custom-port.pp