#!/usr/bin/env bash
set -euo pipefail

echo "==> 0. Подготовка"
yum install cryptsetup -y

DISK=/dev/sdb
DEVICE=/dev/sdb1
if [[ ! $(df | grep ${DISK}) ]]; then
  parted -s $DISK mklabel msdos
  parted -s -a opt $DISK mkpart primary ext4 0% 100%
fi

KEY=/root/my.key
if [[ ! -e $KEY ]]; then
echo "==> 1. Делаем файл-ключ"
dd if=/dev/urandom of=$KEY bs=1 count=1024
fi

echo "==> 2. Создаем криптоконтейнер"
cryptsetup -v -s 512 luksFormat $DEVICE $KEY

echo "==> 3. Открываем контейнер"
MAPPED_NAME=secrets
cryptsetup luksOpen -d $KEY $DEVICE $MAPPED_NAME
# Форматируем раздел
mkfs.xfs /dev/mapper/$MAPPED_NAME
# Монтируем раздел
mkdir /secrets
mount /dev/mapper/$MAPPED_NAME /$MAPPED_NAME

echo "==> 4. Заполняем контейнер произвольными данными"
echo "My secret" > /$MAPPED_NAME/secret.txt

echo "==> 5. Закрываем контейнер"
umount /$MAPPED_NAME
cryptsetup luksClose $MAPPED_NAME

echo "==> 6. Открываем контейнер"
cryptsetup luksOpen -d $KEY $DEVICE $MAPPED_NAME
# Монтируем раздел повторно
mount /dev/mapper/$MAPPED_NAME /$MAPPED_NAME

echo "==> 7. Проверяем, что все на месте. Выводим файл secrets.txt"
cat /$MAPPED_NAME/secret.txt

# echo "==> 8. Создать дополнительный ключ (либо ключевой файл)"
# NEW_KEY=my_new_key
# #dd if=/dev/urandom of=$KEY2 bs=1 count=1024
# echo "$NEW_KEY" | cryptsetup luksAddKey -d $KEY --key-slot 5 /dev/sdb1

# echo "==> 9. Удалить старый ключ"
# echo "$NEW_KEY" | cryptsetup luksRemoveKey -d $KEY $DEVICE

# echo "==> 10. Очистить слот от старого ключа"
# echo "$NEW_KEY" | cryptsetup luksKillSlot $DEVICE 0