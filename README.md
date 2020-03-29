# otus-linux-security-hw
Упаковать приложение в docker, провести харденинг собранного образа.

## Подготовка
После клонирования репозитория нужно инициализировать сабмодули:
```shell script
git submodule init
git submodule update
```
SNYK_TOKEN передам в чате для проверки домашних заданий.
Виртуальную машину (ВМ) лучше запустить командой:
```bash
vagrant up && sleep 60 && vagrant up --provision
```
После первой команды обновится ядро и перезапустится ВМ.
Второй командой ждем подъем ВМ.
Третья команда запустит основную часть provision скрипта.
Все этапы и проверки снабжены комментариями и будут выведены в консоли.

## Замечания по DOCKER-BENCH-SECURITY (DBC)
Некоторые проверки DBC работают некорректно, например:
##### 1.1 - Ensure a separate partition for containers has been created
Выводит [WARN], из-за user-ns, т.к. DockerRootDir становится не /var/lib/docker, а /var/lib/docker/$UID.$UID, и это значение проверяется командой mountpoint -q -- "$(docker info -f '{{ .DockerRootDir }}')"
##### 4.5 - Ensure Content trust for Docker is Enabled
После включения DCT перестают пулиться образы с hub.docker.com
##### 4.6 - Ensure HEALTHCHECK instructions have been added to the container image
В приложении не предусмотрена ручка для хелсчека, в базовом образе python:3.8.2-alpine3.11 тоже
##### 4.9  - Ensure COPY is used instead of ADD in Dockerfile
Иструкция ADD содержится в самом образе docker/docker-bench-security:latest, в базовом образе python:3.8.2-alpine3.11 и наследуется в signal-server:1.0. Повлиять на это я не могу.