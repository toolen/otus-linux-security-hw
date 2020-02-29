#!/usr/bin/env bash
set -euo pipefail

# echo "==> Проверяем, что ядро уязвимо к DirtyCOW"
# yum install wget -y
# wget https://access.redhat.com/sites/default/files/rh-cve-2016-5195_1.sh
# bash rh-cve-2016-5195_1.sh
echo "==> Добавляем скомпрометированного пользователя alice"
adduser alice
echo "==> Копируем эксплоит в домашнюю директорию alice"
cp /vagrant/CVE-2016-5195/golang/dcow /home/alice
echo "==> Делаем эксплоит исполняемым"
chmod +x /home/alice/dcow
echo "==> Передаем alice права на эксплоит"
chown alice:alice /home/alice/dcow

echo "==> Добавляем секретный документ в директорию рута"
echo "There is no cow." > /root/secret
echo "==> Запрещаем всем, кроме рута иметь доступ к этому документу"
chmod 600 /root/secret

# https://github.com/dirtycow/dirtycow.github.io/issues/25
echo 0 | sudo tee /proc/sys/vm/dirty_writeback_centisecs
