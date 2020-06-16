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

echo ">>> Setting up Vim"

if [[ -z $1 ]]; then
    github_url="https://raw.githubusercontent.com/mikaelmattsson/Vaprobash/master"
else
    github_url="$1"
fi

# Create directories needed for some .vimrc settings
mkdir -p /home/vagrant/.vim/backup
mkdir -p /home/vagrant/.vim/swap

# Install Vundle and set owner of .vim files
git clone https://github.com/gmarik/vundle.git /home/vagrant/.vim/bundle/vundle
sudo chown -R vagrant:vagrant /home/vagrant/.vim

# Grab .vimrc and set owner
curl --silent -L $github_url/helpers/vimrc > /home/vagrant/.vimrc
sudo chown vagrant:vagrant /home/vagrant/.vimrc

# Install Vundle Bundles
sudo su - vagrant -c 'vim +BundleInstall +qall'
