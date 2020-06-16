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

echo ">>> Installing PHP MSSQL"

# Test if PHP is installed
php -v > /dev/null 2>&1 || { printf "!!! PHP is not installed.\n    Installing PHP MSSQL aborted!\n"; exit 0; }

sudo apt-get update

# Install PHP MSSQL
# -qq implies -y --force-yes
sudo apt-get install -qq php7.3-mssql

echo ">>> Installing freeTDS for MSSQL"

# Install freetds
sudo apt-get install -qq freetds-dev freetds-bin tdsodbc

echo ">>> Installing UnixODBC for MSSQL"

# Install unixodbc
sudo apt-get install -qq unixodbc unixodbc-dev

# Restart php7.3-fpm
sudo service php7.3-fpm restart
