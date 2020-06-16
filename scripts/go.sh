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

# check if a go version is set
if [[ -z $1 ]]; then
        GO_VERSION="latest"
else
        GO_VERSION=$1
fi

# Check if gvm is installed
gvm version > /dev/null 2>&1
GVM_IS_INSTALLED=$?

if [ $GVM_IS_INSTALLED -eq 0 ]; then
    echo "Gvm Already Installed"
else
    # Installing dependencies
    echo "Installing Go version manager"
    sudo apt-get install -qq curl git mercurial make binutils bison build-essential
    bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
    source /home/vagrant/.gvm/scripts/gvm

    if [[ $GO_VERSION -eq "latest" ]]; then
        GO_VERSION=`curl -L 'https://golang.org/' | grep 'Build version' | awk '{print $3}' | awk -F\< '{ print $1 }' | rev | cut -c 2- | rev`
    fi
    echo "Installing Go version "$GO_VERSION
    echo "This will also be the default version"

    gvm install $GO_VERSION --prefer-binary
    gvm use $GO_VERSION --default
fi
