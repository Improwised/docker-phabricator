#!/bin/bash

set -e
set -x

# Add repositories
zypper --non-interactive ar http://download.opensuse.org/repositories/devel:languages:php/openSUSE_Factory/ php
zypper --non-interactive ar http://download.opensuse.org/repositories/devel:/languages:/nodejs/openSUSE_Tumbleweed/ nodejs
zypper --non-interactive ar http://download.opensuse.org/repositories/devel:/languages:/python/openSUSE_Tumbleweed/ python

# Add SCM package for other tools (Subversion, Mercurial)...
zypper --non-interactive ar http://download.opensuse.org/repositories/devel:/tools:/scm/openSUSE_Tumbleweed/ scm

# Install requirements
zypper --gpg-auto-import-keys --non-interactive in --force-resolution git nginx php7-fpm php7-APCu php7-mbstring php7-mysql php7-curl php7-pcntl php7-gd php7-openssl php7-ldap php7-fileinfo php7-posix php7-json php7-iconv php7-ctype php7-zip php7-sockets which python2-pip python2-Pygments nodejs10 npm10 ca-certificates ca-certificates-mozilla ca-certificates-cacert sudo subversion mercurial php7-xmlwriter php7-opcache ImageMagick postfix glibc-locale
pip install supervisor
npm install -g ws

# Build and install APCu
# zypper --non-interactive install --force-resolution autoconf automake binutils cpp cpp48 gcc gcc48 glibc-devel libasan0 libatomic1 libcloog-isl4 libgomp1 libisl10 libitm1 libltdl7 libmpc3 libmpfr4 libpcre16-0 libpcrecpp0 libpcreposix0 libstdc++-devel libstdc++48-devel libtool libtsan0 libxml2-devel libxml2-tools linux-glibc-devel m4 make ncurses-devel pcre-devel php7-devel php7-pear php7-zlib pkg-config readline-devel tack xz-devel zlib-devel
# printf "\n" | pecl install apcu-5.1.12
#zypper --non-interactive remove --force-resolution autoconf automake binutils cpp cpp48 gcc gcc48 glibc-devel libasan0 libatomic1 libcloog-isl4 libgomp1 libisl10 libitm1 libltdl7 libmpc3 libmpfr4 libpcre16-0 libpcrecpp0 libpcreposix0 libstdc++-devel libstdc++48-devel libtool libtsan0 libxml2-devel libxml2-tools linux-glibc-devel m4 ncurses-devel pcre-devel php5-devel php5-pear pkg-config readline-devel tack xz-devel zlib-devel

# Remove cached things that pecl left in /tmp/
rm -rf /tmp/*

# Install a few extra things
zypper --non-interactive install --force-resolution mariadb-client vim vim-data

# Force reinstall cronie
zypper --non-interactive install -f cronie

# Create users and groups
# groupadd -g 495 nginx
groupadd -g 2000 wwwgrp-phabricator
# useradd -m -d /var/lib/nginx -s /bin/false -c "user for nginx" -u 497 -g 495 -G wwwgrp-phabricator nginx
# echo "nginx:x:497:495:user for nginx:/var/lib/nginx:/bin/false" >> /etc/passwd
# echo "nginx:!:495:" >> /etc/group
useradd -m -d /srv/phabricator -s /bin/bash -c "user for phabricator" -u 2000 -g 2000 PHABRICATOR
# echo "PHABRICATOR:x:2000:2000:user for phabricator:/srv/phabricator:/bin/bash" >> /etc/passwd
# echo "wwwgrp-phabricator:!:2000:nginx" >> /etc/group

# Set up the Phabricator code base
# mkdir /srv/phabricator
chown PHABRICATOR:wwwgrp-phabricator /srv/phabricator
cd /srv/phabricator
sudo -u PHABRICATOR git clone https://www.github.com/phacility/libphutil.git /srv/phabricator/libphutil
sudo -u PHABRICATOR git clone https://www.github.com/phacility/arcanist.git /srv/phabricator/arcanist
sudo -u PHABRICATOR git clone https://www.github.com/phacility/phabricator.git /srv/phabricator/phabricator
sudo -u PHABRICATOR git clone https://www.github.com/PHPOffice/PHPExcel.git /srv/phabricator/PHPExcel
cd /

# Clone Let's Encrypt
git clone https://github.com/letsencrypt/letsencrypt /srv/letsencrypt
cd /srv/letsencrypt
./letsencrypt-auto-source/letsencrypt-auto --help
cd /
