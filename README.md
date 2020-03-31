# otus-linux-security-hw
Репозиторий домашних заданий по курсу ["Безопасность Linux"](https://otus.ru/lessons/bezopasnost-linux/)

## Запустить nginx на нестандартном порту 3-мя разными способами
### Логические параметры SELinux
```bash
setsebool -P nis_enabled on
```
### Добавление нестандартного порта в имеющийся тип
```bash
semanage port --add --type http_port_t --proto tcp 5150
```
### Формирование и установка модуля SELinux
```bash
ausearch -c 'nginx' --raw | audit2allow -M nginx-custom-port
semodule -i nginx-custom-port.pp
```