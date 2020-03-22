#!/usr/bin/env bash
set -euo pipefail

echo "==> Обновляем пакеты"
yum update -y >/dev/null

echo "==> Устанавливаем epel-release setools policycoreutils policycoreutils-python setroubleshoot"
yum install -y epel-release setools policycoreutils policycoreutils-python setroubleshoot >/dev/null

echo "==> Устанавливаем nginx"
yum install -y nginx >/dev/null

echo "==> Перезапускаем auditd"
service auditd restart >/dev/null

#if [[ $(firewall-cmd --state) != "running" ]]; then
#  echo "==> Включаем faerwalld"
#  systemctl start firewalld >/dev/null
#fi
#
#echo "==> Открываем 80й порт"
#firewall-cmd --permanent --add-port=80/tcp >/dev/null
#
#echo "==> Перезапускаем faerwalld"
#firewall-cmd --reload >/dev/null

echo "==> Смотрим статус SELinux"
sestatus | grep "SELinux status"

echo "==> Меняем порт nginx на 8080"
sed 's/listen       80 default_server;/listen       8080 default_server;' /etc/nginx/nginx.conf
sed 's/listen       [::]:80 default_server;/listen       [::]:8080 default_server;' /etc/nginx/nginx.conf

#systemctl enable --now nginx

