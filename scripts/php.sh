#!/usr/bin/env bash

export LANG=C.UTF-8

PHP_TIMEZONE=$1
HHVM=$2
PHP_VERSION=$3

if [[ $HHVM == "true" ]]; then

    echo ">>> Installing HHVM"

    # Get key and add to sources
    wget --quiet -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
    echo deb http://dl.hhvm.com/ubuntu trusty main | sudo tee /etc/apt/sources.list.d/hhvm.list

    # Update
    sudo apt-get update

    # Install HHVM
    # -qq implies -y --force-yes
    sudo apt-get install -qq hhvm

    # Start on system boot
    sudo update-rc.d hhvm defaults

    # Replace PHP with HHVM via symlinking
    sudo /usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60

    sudo service hhvm restart
else
    sudo apt -y install software-properties-common dirmngr apt-transport-https lsb-release ca-certificates

    sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
    sudo add-apt-repository -y ppa:ondrej/php
    sudo apt-key update
    sudo apt-get update
    deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main
    deb-src http://ppa.launchpad.net/ondrej/php/ubuntu bionic main

    sudo apt-get update

    sudo apt install php7.3-cli php7.3-fpm php7.3-common php7.3-json php7.3-pdo php7.3-mysql php7.3-sqlite php7.3-zip php7.3-gd php7.3-mbstring php7.3-curl php7.3-xml php7.3-bcmath php7.3-json php7.3-imagick php7.3-ctype php7.3-fileinfo php7.3-openssl php7.3-pdo_mysql php7.3-pdo_sqlite php7.3-bz2 php7.3-intl php7.3-tokenizer php7.3-xml php7.3-xmlrpc php7.3-dev php7.3-opcache php7.3-soap

    sudo apt policy php7.3-cli

    # Set PHP FPM to listen on TCP instead of Socket
    sudo sed -i "s/listen =.*/listen = 127.0.0.1:9000/" /etc/php/7.3/fpm/pool.d/www.conf

    # Set PHP FPM allowed clients IP address
    sudo sed -i "s/;listen.allowed_clients/listen.allowed_clients/" /etc/php/7.3/fpm/pool.d/www.conf

    # Set run-as user for PHP/7.0-FPM processes to user/group "vagrant"
    # to avoid permission errors from apps writing to files
    sudo sed -i "s/user = www-data/user = vagrant/" /etc/php/7.3/fpm/pool.d/www.conf
    sudo sed -i "s/group = www-data/group = vagrant/" /etc/php/7.3/fpm/pool.d/www.conf

    sudo sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/7.3/fpm/pool.d/www.conf
    sudo sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/7.3/fpm/pool.d/www.conf
    sudo sed -i "s/listen\.mode.*/listen.mode = 0666/" /etc/php/7.3/fpm/pool.d/www.conf

    # Nginx
    sudo systemctl restart nginx

    sudo service php7.3-fpm restart
fi
