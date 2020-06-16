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

echo ">>> Installing Sphinx"

if [[ -z $1 ]]; then
    sphinxsearch_version="stable"
else
    sphinxsearch_version="$1"
fi

# Add sphinxsearch repo
sudo add-apt-repository -y ppa:builds/sphinxsearch-$sphinxsearch_version

# The usual updates
sudo apt-get update

# Install SphinxSearch
sudo apt-get install -qq sphinxsearch

# Create a base conf file (Altho we can't make any assumptions about its use)

# Stop searchd so we can change the config file
searchd --stop

# Move pid file since searchd will fail to start after reboot
sudo sed -i 's/sphinxsearch\/searchd.pid/searchd.pid/' /etc/sphinxsearch/sphinx.conf

# Start searchd
searchd
