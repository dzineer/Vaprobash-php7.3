#!/bin/bash

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

# exit script if not run as root
if [[ $EUID -ne 0 ]]; then
    cat <<END
you need to run this script as the root user
use :privileged => true in Vagrantfile
END

    exit 0
fi

# optimize apt sources to select best mirror
perl -pi -e 's@^\s*(deb(\-src)?)\s+http://us.archive.*?\s+@\1 mirror://mirrors.ubuntu.com/mirrors.txt @g' /etc/apt/sources.list

# update repositories
apt-get update
