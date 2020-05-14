# otus-linux-security-hw
Репозиторий домашних заданий по курсу ["Безопасность Linux"](https://otus.ru/lessons/bezopasnost-linux/)

## Отчет
1. [HIDS установлен](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-06-ossim/hids-installed.png)
2. [Хосты отображаются](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-06-ossim/hosts-list.png)
3. [Сканирование запущено](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-06-ossim/scan-before-fix-in-progress.png)
4. [Отчет о сканировании](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-06-ossim/ScanResult_20200513_before_fix.pdf)
5. Критическая уязвимость "SSH Brute Force Logins With Default Credentials Reporting" на стр.6. Устраняем меняя пароль пользователя и запрещая подключение через ssh под рутом.
6. [Запускаем повторное сканирование](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-06-ossim/scan-after-fix-in-progress.png)
7. [Отчет после исправления уязвимости](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-06-ossim/ScanResult_20200513_after_fix.pdf)
8. [Сравнение отчетов до и после](https://raw.githubusercontent.com/toolen/otus-linux-security-hw/hw-06-ossim/report-compare.png)

## Установка HIDS в MSF
```shell
sudo apt-get install -y libevent-dev
sudo PCRE2_SYSTEM=no ./install.sh
```
