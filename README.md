# otus-linux-security-hw
Репозиторий домашних заданий по курсу ["Безопасность Linux"](https://otus.ru/lessons/bezopasnost-linux/)

## Проверка
Чтобы проверить, может ли пользователь otus монтировать диски, в виртуальной машине нужно запустить команды:
```bash
sudo su otus
udisksctl mount -b /dev/sdb1
```
Чтобы проверить запрещено ли пользователю otus2 логиниться по выходным с 12 до 18 вечера, нужно поключиться к виртуальной машине по ssh.
```
ssh otus2@192.168.55.11
# пароль: goodowl
```
В зависимости от времени и дня недели (на виртуальной машине время московское), подключение либо удастся, либо в вирутальной машине в файле /var/log/secure будет такая запись:
```
Mar  1 14:36:25 localhost sshd[5785]: fatal: Access denied for user otus2 by PAM account configuration [preauth]
```
Проверка chroot для otus3. Нужно подключиться к виртуальной машине по ssh.
```bash
ssh otus3@192.168.55.11
# пароль: goodowltoo
```
В jail есть bash, команды ls и cd