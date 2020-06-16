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

echo ">>> Installing Kibana"

# Set some variables
KIBANA_VERSION=4.1.1 # Check https://www.elastic.co/downloads/kibana for latest version

sudo mkdir -p /opt/kibana
wget --quiet https://download.elastic.co/kibana/kibana/kibana-$KIBANA_VERSION-linux-x64.tar.gz
sudo tar xvf kibana-$KIBANA_VERSION-linux-x64.tar.gz -C /opt/kibana --strip-components=1
rm kibana-$KIBANA_VERSION-linux-x64.tar.gz

# Configure to start up Kibana automatically
cd /etc/init.d && sudo wget --quiet https://gist.githubusercontent.com/thisismitch/8b15ac909aed214ad04a/raw/bce61d85643c2dcdfbc2728c55a41dab444dca20/kibana4

sudo chmod +x /etc/init.d/kibana4
sudo update-rc.d kibana4 defaults 95 10
sudo service kibana4 start
