# otus-linux-security-hw
Репозиторий домашних заданий по курсу ["Безопасность Linux"](https://otus.ru/lessons/bezopasnost-linux/)

## Отчет по task1
Из [истории bash](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-07-volatility/task1-screenshots/task1-01-bash.png) видно, что был запущен [meterpreter](https://www.offensive-security.com/metasploit-unleashed/about-meterpreter/) из-под суперпользователя. Командой linux_pslist находим [pid и адрес памяти meterpreter](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-07-volatility/task1-screenshots/task1-02-pslist.png). Командой netstat cмотрим [сетевые соединения](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-07-volatility/task1-screenshots/task1-03-netstat.png). Указав pid meterpreter выясняем, что он [установил соединение с другим хостом](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-07-volatility/task1-screenshots/task1-03-netstat-p.png). [Прогоним linux_malfind](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-07-volatility/task1-screenshots/task1-04-malfind.png), [вытащим из отчета все pid'ы](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-07-volatility/task1-screenshots/task1-04-malfind-pids.png), а затем запустим linux_yarascan по найденным pid'ам. [yarascan ничего не нашел](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-07-volatility/task1-screenshots/task1-05-yarascan.png). Возможно, правило было подобрано неправильно. meterpreter оределенно вредоносное ПО, но что он сделал установить не удалось.

## Отчет по task2
Запускаем linux_bash, [видим файл ht0p](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-07-volatility/task2-screenshots/01-linux_bash.png) запущенный в бэкграунде/Этот файл был скопирован с какого-то устройства, еще видна попытка почистить bash_history. Командой linux_pstree cмотрим [дерево процессов](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-07-volatility/task2-screenshots/02-linux_pstree.png), видим что ht0p не порождал другие процессы и имеет pid 1192. Командой linux_getcwd [узнаем откуда этот скрипт был запущен](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-07-volatility/task2-screenshots/04-linux_getcwd.png). Командой linux_find_file [узнаем Inode](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-07-volatility/task2-screenshots/05-linux_find_file-01.png), той же командой [извлечем файл ht0p из памяти](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-07-volatility/task2-screenshots/05-linux_find_file-02.png). [Открытие файла командой xxd](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-07-volatility/task2-screenshots/xxd-htop.txt) и hexdump ничего не дает. [Запустим linux_proc_map](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-07-volatility/task2-screenshots/07-linux_proc_map.png)

## Снипеты
### task1
```shell
cp /vagrant/task1/Ubuntu_4.15.0-72-generic_profile.zip /usr/lib/python2.7/dist-packages/volatility/plugins/overlays/linux
wget https://raw.githubusercontent.com/cuckoosandbox/community/master/data/yara/shellcode/metasploit.yar
volatility --profile=LinuxUbuntu_4_15_0-72-generic_profilex64 --filename=/vagrant/task1/memory.vmem <command>
```
### task2
```shell
sudo cp /vagrant/Ubuntu16.04_4.4.0_116_generic-39158-dea5d1.zip /usr/lib/python2.7/dist-packages/volatility/plugins/overlays/linux
volatility --profile=LinuxUbuntu16_04_4_4_0_116_generic-39158-dea5d1x64 --filename=/vagrant/task2/image <command>
```
