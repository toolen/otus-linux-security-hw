# otus-linux-security-hw
Репозиторий домашних заданий по курсу ["Безопасность Linux"](https://otus.ru/lessons/bezopasnost-linux/)

## Запустить nginx на нестандартном порту 3-мя разными способами
### Логические параметры SELinux
```bash
setsebool -P nis_enabled on
```
[Скриншот](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-03/setsebool.png)
### Добавление нестандартного порта в имеющийся тип
```bash
semanage port --add --type http_port_t --proto tcp 5150
```
[Скриншот](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-03/semanage.png)
### Формирование и установка модуля SELinux
```bash
ausearch -c 'nginx' --raw | audit2allow -M nginx-custom-port
semodule -i nginx-custom-port.pp
```
[Скриншот](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-03/semodule.png)

## Обеспечить работоспособность приложения при включенном SElinux
### Причина неработоспособности механизма обновления зоны
BIND хранит информацию в текстовых файлах (журналах) зон. Чтобы создать DNS запись, BIND должен создать файл. Из логов named видна попытка создать файл /etc/named/dynamic/named.ddns.lab.view1.jnl. Но для selinux домена named_t создание файлов в папке /etc не разрешено. Поэтому создать DNS запись не удается.
### Способы решения
Т.к. разрешать запись фалов в /etc небезопасно и selinux file_contexts для named в основном сконфигурированы для запуска named под chroot. Посмотреть можно командой:
```bash
sudo cat /etc/selinux/targeted/active/file_contexts | grep named
```
Предлагаю запустить named под chroot, кроме формирования chroot окружения, нужно разрешить named записывать мастер зоны:
```
setsebool -P named_write_master_zones 1
```
### Проверка
В корне репозитория выполнить команды:
```bash
git submodule init
git submodule update
cp named.conf otus-linux-sec/selinux_dns_problems/provisioning/files/ns01/
cp playbook.yml otus-linux-sec/selinux_dns_problems/provisioning/
cd otus-linux-sec/selinux_dns_problems
varant up
vagrant ssh client
```
Выполнить команды:
```bash
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
```
Ошибки быть не должно
[Скриншот](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-03/named.png)
