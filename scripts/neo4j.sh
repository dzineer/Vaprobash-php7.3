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

echo ">>> Installing Neo4J"

# Install prerequisite: Java
# -qq implies -y --force-yes
sudo apt-get update
sudo apt-get install -qq openjdk-7-jre-headless

# Add the Neo4J key into the apt package manager:
wget -O - http://debian.neo4j.org/neotechnology.gpg.key | apt-key add -

# Add Neo4J to the Apt sources list:
echo 'deb http://debian.neo4j.org/repo stable/' > /etc/apt/sources.list.d/neo4j.list

# Update the package manager:
apt-get update

# Install Neo4J:
apt-get install -qq neo4j

# Start the server
service neo4j-service restart
