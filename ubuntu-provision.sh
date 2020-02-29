#!/usr/bin/env bash
set -euo pipefail

echo "==> Выводим версию ядра"
uname -rv
echo "==> Добавляем скомпрометированного пользователя alice"
adduser --quiet --disabled-password --gecos "First Last,RoomNumber,WorkPhone,HomePhone" alice
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

echo "==> Устанавливаем уязвимую версию ядра"
apt-get update
apt-get install -y linux-image-extra-4.4.0-43-generic
sed -i -e"s/^GRUB_DEFAULT=0.*$/GRUB_DEFAULT=\"Advanced options for Ubuntu>Ubuntu, with Linux 4.4.0-43-generic\"/" /etc/default/grub
sed -i -e"s/^GRUB_TIMEOUT=0.*$/GRUB_TIMEOUT=5/" /etc/default/grub
# https://github.com/dirtycow/dirtycow.github.io/issues/25
echo 0 | sudo tee /proc/sys/vm/dirty_writeback_centisecs
update-grub
reboot
