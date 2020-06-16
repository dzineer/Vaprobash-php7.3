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

# Test if git is installed
git --version > /dev/null 2>&1
GIT_IS_INSTALLED=$?

if [[ $GIT_IS_INSTALLED -gt 0 ]]; then
    echo ">>> ERROR: git-ftp install requires git"
    exit 1
fi

# Test if cURL is installed
curl --version > /dev/null 2>&1
CURL_IS_INSTALLED=$?

if [ $CURL_IS_INSTALLED -gt 0 ]; then
    echo ">>> ERROR: git-ftp install requires cURL"
    exit 1
fi

echo ">>> Installing git-ftp";

# Clone git-ftp into .git-ftp folder
git clone https://github.com/git-ftp/git-ftp.git /home/vagrant/.git-ftp

# Move to the .git-ftp folder
cd /home/vagrant/.git-ftp

# Install git-ftp
sudo make install
