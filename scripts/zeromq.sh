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

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

[[ $PHP_IS_INSTALLED -ne 0 ]] && { printf "!!! PHP is not installed.\n    Installing ØMQ aborted!\n"; exit 0; }

echo ">>> Installing ØMQ"

sudo add-apt-repository -qq pp:chris-lea/zeromq 
sudo apt-get update -qq
sudo apt-get install -qq libtool autoconf automake uuid uuid-dev uuid-runtime build-essential php7.3-dev pkg-config libzmq3-dbg libzmq3-dev libzmq3

echo "" | sudo pecl install zmq-beta > /dev/null

sudo echo "extension=zmq.so" >> /etc/php/7.3/mods-available/zmq.ini
sudo phpenmod zmq > /dev/null
sudo service php7.3-fpm restart > /dev/null

