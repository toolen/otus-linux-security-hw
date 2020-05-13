#!/usr/bin/env bash
set -euo pipefail

LIBPCAP_VER=1.8.1
SNORT_VER=2.9.16
DAQ_VER=2.0.7

echo "==> Обновляем пакеты"
yum update -y >/dev/null
echo "==> Подключаем epel-release"
yum install -y epel-release >/dev/null
echo "==> Устанавливаем зависимости для сборки"
yum install -y gcc gcc-c++ libnetfilter_queue libnetfilter_queue-devel git flex bison zlib \
zlib-devel pcre pcre-devel libdnet libdnet-devel tcpdump libnghttp2 wget xz-devel lzma \
automake autotools libtool >/dev/null

if [[ ! -e ~/snort_src ]]; then
    echo "==> Создаем папку ~/snort_src"
    mkdir ~/snort_src
fi

cd ~/snort_src

# ethtool -K eth1 gro off
# ethtool -K eth1 lro off

if [[ ! -e ~/snort_src/libpcap-$LIBPCAP_VER ]]; then
    echo "==> Скачиваем libpcap"
    wget http://www.tcpdump.org/release/libpcap-$LIBPCAP_VER.tar.gz
    echo "==> Распаковываем libpcap"
    tar xzvf libpcap-$LIBPCAP_VER.tar.gz
fi


cd ~/snort_src/libpcap-$LIBPCAP_VER
echo "==> libpcap configure"
./configure >/dev/null
echo "==> libpcap make"
make >/dev/null
echo "==> libpcap make install"
make install >/dev/null
echo "==> Устанавливаем libpcap-devel"
yum install -y libpcap-devel >/dev/null

if [[ ! -e ~/snort_src/daq-$DAQ_VER ]]; then
    cd ~/snort_src
    echo "==> Скачиваем daq"
    wget https://www.snort.org/downloads/snort/daq-$DAQ_VER.tar.gz >/dev/null
    echo "==> Распаковываем daq"
    tar xvfz daq-$DAQ_VER.tar.gz >/dev/null
fi


cd ~/snort_src/daq-$DAQ_VER
echo "==> daq configure"
autoreconf -f -i >/dev/null
./configure >/dev/null
echo "==> daq make"
make >/dev/null
echo "==> daq make install"
make install >/dev/null
cd ..

echo "==> Устанавливаем snort"
yum install -y https://www.snort.org/downloads/snort/snort-$SNORT_VER-1.centos7.x86_64.rpm >/dev/null

# wget https://www.snort.org/downloads/snort/snort-$SNORT_VER.tar.gz
# tar -xvzf snort-$SNORT_VER.tar.gz
# cd snort-$SNORT_VER
# ./configure --enable-sourcefire && make && make install

ldconfig

# if [[ ! -e /usr/sbin/snort ]]; then
#     ln -s /usr/local/bin/snort /usr/sbin/snort
# fi

if [[ ! -e /usr/lib64/libdnet.1 ]]; then
    ln -s /usr/lib64/libdnet.so.1.0.1 /usr/lib64/libdnet.1
fi

# groupadd snort
# useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort

mkdir -p /etc/snort/rules
mkdir /var/log/snort
mkdir /usr/local/lib/snort_dynamicrules
chmod -R 5775 /etc/snort
chmod -R 5775 /var/log/snort
chmod -R 5775 /usr/local/lib/snort_dynamicrules
chmod -R 5775 /usr/local/lib/snort_dynamicrules
chown -R snort:snort /var/log/snort
chown -R snort:snort /usr/local/lib/snort_dynamicrules

touch /etc/snort/rules/white_list.rules
touch /etc/snort/rules/black_list.rules
touch /etc/snort/rules/local.rules

yum install -y perl-libwww-perl perl-core "perl(Crypt::SSLeay)" perl-LWP-Protocol-https

git clone https://github.com/shirkdog/pulledpork.git
cd pulledpork/
cp pulledpork.pl /usr/local/bin
chmod +x /usr/local/bin/pulledpork.pl
cp etc/*.conf /etc/snort
mkdir /etc/snort/rules/iplists
touch /etc/snort/rules/iplists/default.blacklist