#!/usr/bin/env bash
set -euo pipefail

# predefined
if [[ ! $(id -u otus) ]]; then
    useradd otus
    cp -r /home/vagrant/.ssh /home/otus/.ssh
    chown otus:otus -R /home/otus/.ssh
fi

if [[ ! $(id -u otus2) ]]; then
    useradd otus2
    echo otus2:goodowl | chpasswd
fi

if [[ ! $(id -u otus3) ]]; then
    useradd otus3
    echo otus3:goodowltoo | chpasswd
fi

echo "==> Cоздать policikit правила разрешающих пользователю otus монтировать диски"
# cp -v /vagrant/org.freedesktop.udisks2.policy /usr/share/polkit-1/actions
echo "==> Устанавливаем udisks2"
cp -v /vagrant/10-udisks2.rules /etc/polkit-1/rules.d
yum install -y udisks2
DISK=/dev/sdb
if [[ ! $(df | grep ${DISK}) ]]; then
    echo "==> Разбиваем диск ${DISK}"
    echo "n
    p
    1
    
    
    w" | fdisk ${DISK}

    echo "==> Форматируем диск ${DISK}"
    PARTITION=$(fdisk -l ${DISK} | tail -n1 | awk '{print $1}')
    mkfs.ext4 ${PARTITION}

    # echo "==> Монтируем диск ${DISK}"
    # runuser -l otus -c "udisksctl mount -b ${PARTITION}"
    # mkdir -p /mnt/otus
    # sudo su otus
    # mount -v -t ext4 ${PARTITION} /mnt/otus
    # df -h | grep ${PARTITION}
    # exit
fi

echo "==> Запретить с помощью time_conf логиниться пользователю otus2 через ssh в выходные"
PREV_LINE="account    required     pam_nologin.so"
CODE="account    required     pam_time.so"
DEST=/etc/pam.d/sshd
grep -qxF "${CODE}" $DEST || sed -i "s/${PREV_LINE}/${PREV_LINE}\n${CODE}/" $DEST
cat $DEST

# Разрешаем доступ по ssh c паролем
CODE="PasswordAuthentication yes"
DEST=/etc/ssh/sshd_config
grep -qxF "${CODE}" $DEST || sed -i "s/PasswordAuthentication no/${CODE}/" $DEST

# устанавливаем московскую таймзону
timedatectl set-timezone Europe/Moscow

# выходные дни с 12 до 18 вечера
CODE="sshd;*;otus2;!SaSu1200-1800"
DEST=/etc/security/time.conf
grep -qxF "${CODE}" $DEST || echo "${CODE}" >> $DEST
cat $DEST | tail -n1

echo "==> Настроить chroot при логине через ssh для пользователя otus3"
CH_ROOT=/home/otus3-jail
if [[ ! -e $CH_ROOT ]]; then
    echo "==> Создаем папку для chroot"
    mkdir -p $CH_ROOT/bin

    echo "==> Копируем bash c зависимостями"
    cp /bin/bash $CH_ROOT/bin
    mkdir -p $CH_ROOT/lib64
    cp /lib64/{libtinfo.so.5,libdl.so.2,libc.so.6,ld-linux-x86-64.so.2,libattr.so.1,libpthread.so.0} $CH_ROOT/lib64

    echo "==> Создаем домашнюю папку пользователя"
    mkdir -p $CH_ROOT/home/otus3

    echo "==> Копируем ls c зависимостями"
    mkdir -p $CH_ROOT/usr/bin
    cp /usr/bin/ls $CH_ROOT/usr/bin
    cp /lib64/{libselinux.so.1,libcap.so.2,libacl.so.1,libc.so.6,libpcre.so.1,libdl.so.2,ld-linux-x86-64.so.2,libattr.so.1,libpthread.so.0} $CH_ROOT/lib64

    echo "==> Копируем cd c зависимостями"
    cp /usr/bin/cd $CH_ROOT/usr/bin

    echo "==> Добавляем ChrootDirectory в sshd_config для пользователя otus3"
    {
        echo "Match User otus3"
        echo "          ChrootDirectory $CH_ROOT"
    } >>/etc/ssh/sshd_config

    echo "==> Передаем права"
    chown -R root:root $CH_ROOT
    chown otus3:otus3 $CH_ROOT/home/otus3
fi

# перезапускаем службу ssh
systemctl reload sshd
