#!/usr/bin/env bash

export COMMAND_LOG="/scripts/commands.log"
export COMMAND_AND_OUTPUT_LOG="/scripts/commands-with-output.log"
export ENV_LOG="/scripts/env.log"

fuction cleanLogs {
  sudo rm -rf  $COMAMND_LOG
  sudo rm -rf $COMMAND_AND_OUTPUT_LOG
  sudo rm -rf $ENV_LOG
}

function runLog {
  cmd="$*"
  sudo echo $cmd >> $COMMAND_LOG
  sudo echo $cmd
  sudo echo $cmd >> $COMMAND_AND_OUTPUT_LOG
  sudo exec $cmd >> $COMMAND_AND_OUTPUT_LOG
}

function envLog {
   theenv="$*"
   sudo echo export $theenv >> $ENV_LOG
   export $theenv
}

echo ">>> Installing Couchbase Server"

# Set some variables
COUCHBASE_EDITION=community
COUCHBASE_VERSION=2.2.0 # Check http://http://www.couchbase.com/download/ for latest version
COUCHBASE_ARCH=x86_64


wget --quiet http://packages.couchbase.com/releases/${COUCHBASE_VERSION}/couchbase-server-${COUCHBASE_EDITION}_${COUCHBASE_VERSION}_${COUCHBASE_ARCH}.deb
sudo dpkg -i couchbase-server-${COUCHBASE_EDITION}_${COUCHBASE_VERSION}_${COUCHBASE_ARCH}.deb
rm couchbase-server-${COUCHBASE_EDITION}_${COUCHBASE_VERSION}_${COUCHBASE_ARCH}.deb

php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

dpkg -s php-pear
PEAR_IS_INSTALLED=$?

dpkg -s php7.3-dev
PHPDEV_IS_INSTALLED=$?

if [ ${PHP_IS_INSTALLED} -eq 0 ]; then

    if [ ${PEAR_IS_INSTALLED} -eq 1 ]; then
        sudo apt-get -qq install php-pear
    fi

    if [ ${PHPDEV_IS_INSTALLED} -eq 1 ]; then
        sudo apt-get -qq install php7.3-dev
    fi

    sudo wget --quiet -O/etc/apt/sources.list.d/couchbase.list http://packages.couchbase.com/ubuntu/couchbase-ubuntu1204.list
    wget --quiet -O- http://packages.couchbase.com/ubuntu/couchbase.key | sudo apt-key add -
    sudo apt-get update
    sudo apt-get -qq install libcouchbase2-libevent libcouchbase-dev

    sudo pecl install couchbase-1.2.2
    sudo cat > /etc/php/7.3/mods-available/couchbase.ini << EOF
; configuration for php couchbase module
; priority=30
extension=couchbase.so
EOF
    sudo phpenmod couchbase
    sudo service php7.3-fpm restart
fi
