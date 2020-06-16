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

envLog DEBIAN_FRONTEND=noninteractive

runLog sudo dd if=/dev/urandom of=/root/.rnd bs=256 count=1 | tee -a "$COMMAND_LOG"
runLog sudo dd if=/dev/urandom of=/home/vagrant/.rnd bs=256 count=1 | tee -a "$COMMAND_LOG"

echo "Setting Timezone & Locale to $3 & en_US.UTF-8" | tee -a "$COMMAND_LOG"

sudo ln -sf /usr/share/zoneinfo/$3 /etc/localtime | tee -a "$COMMAND_LOG"
sudo apt-get install -qq language-pack-en | tee -a "$COMMAND_LOG"
sudo locale-gen en_US | tee -a "$COMMAND_LOG"
sudo update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8 | tee -a "$COMMAND_LOG"

echo ">>> Installing Base Packages" | tee -a "$COMMAND_LOG"

if [[ -z $1 ]]; then
    github_url="https://raw.githubusercontent.com/mikaelmattsson/Vaprobash/master"
else
    github_url="$1"
fi

echo $github_url >> /scripts/.env

# Update
sudo apt-get update | tee -a "$COMMAND_LOG"

# Install base packages
# -qq implies -y --force-yes
sudo apt-get install -qq curl unzip git-core ack-grep software-properties-common build-essential cachefilesd | tee -a "$COMMAND_LOG"
sudo apt-get install -qq ruby-full gcc g++ make libsqlite3-dev | tee -a "$COMMAND_LOG"

SSL_DIR="/etc/ssl/xip.io"
DOMAIN="*.xip.io"
PASSPHRASE="vaprobash"
EMAIL="support@xip.io"

echo ">>> Installing $DOMAIN self-signed SSL"

echo "export EMAIL=$EMAIL" >> /scripts/.env
echo "export DOMAIN=$DOMAIN" >> /scripts/.env
echo "export PASSPHRASE=$PASSPHRASE" >> /scripts/.env
echo "export SSL_DIR=$SSL_DIR" >> /scripts/.env

sudo mkdir -p "$SSL_DIR"

#sudo openssl genrsa -out "$SSL_DIR/xip.io.key" 1024
#sudo openssl req -new -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -key "$SSL_DIR/xip.io.key" -out "$SSL_DIR/xip.io.csr" -passin pass:$PASSPHRASE
#sudo openssl x509 -req -days 365 -in "$SSL_DIR/xip.io.csr" -signkey "$SSL_DIR/xip.io.key" -out "$SSL_DIR/xip.io.crt"

# This is the current one that works as of 2020/05/16
sudo openssl req -subj "/O=personal/CN=$DOMAIN/" -x509 -nodes -days 730 -newkey rsa:2048 -keyout "$SSL_DIR/xip.io.key" -out "$SSL_DIR/xip.io.crt"

# Setting up Swap

# Disable case sensitivity
shopt -s nocasematch

if [[ ! -z $2 && ! $2 =~ false && $2 =~ ^[0-9]*$ ]]; then

    echo ">>> Setting up Swap ($2 MB)"

    # Create the Swap file
    fallocate -l $2M /swapfile

    # Set the correct Swap permissions
    chmod 600 /swapfile

    # Setup Swap space
    mkswap /swapfile

    # Enable Swap space
    swapon /swapfile

    # Make the Swap file permanent
    echo "/swapfile   none    swap    sw    0   0" | tee -a /etc/fstab

    # Add some swap settings:
    # vm.swappiness=10: Means that there wont be a Swap file until memory hits 90% useage
    # vm.vfs_cache_pressure=50: read http://rudd-o.com/linux-and-free-software/tales-from-responsivenessland-why-linux-feels-slow-and-how-to-fix-that
    printf "vm.swappiness=10\nvm.vfs_cache_pressure=50" | tee -a /etc/sysctl.conf && sysctl -p

fi

# Enable case sensitivity
shopt -u nocasematch

# Enable cachefilesd
echo "RUN=yes" > /etc/default/cachefilesd
