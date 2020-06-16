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

echo ">>> Installing MongoDB"

# Get key and add to sources
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7.3CEB10

# Make MongoDB connectable from outside world without SSH tunnel
if [ $2 == "3.0" ]; then
  echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
else
  echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
fi


# Update
sudo apt-get update

# Install MongoDB
# -qq implies -y --force-yes
sudo apt-get install -qq mongodb-org

# Make MongoDB connectable from outside world without SSH tunnel
if [ $1 == "true" ]; then
    # enable remote access
    # setting the mongodb bind_ip to allow connections from everywhere
    sed -i "s/bind_ip = .*/bind_ip = 0.0.0.0/" /etc/mongod.conf
fi

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

if [ $PHP_IS_INSTALLED -eq 0 ]; then
    # install dependencies
    sudo apt-get -y install php-pear php7.3-dev

    # install php extension
    echo "no" > answers.txt
    sudo pecl install mongo < answers.txt
    rm answers.txt

    # add extension file and restart service
    echo 'extension=mongo.so' | sudo tee /etc/php/7.3/mods-available/mongo.ini

    ln -s /etc/php/7.3/mods-available/mongo.ini /etc/php/7.3/fpm/conf.d/mongo.ini
    ln -s /etc/php/7.3/mods-available/mongo.ini /etc/php/7.3/cli/conf.d/mongo.ini
    sudo service php7.3-fpm restart
fi
