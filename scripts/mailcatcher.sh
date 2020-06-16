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

echo ">>> Installing Mailcatcher"

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$1

# Test if Apache is installed
apache2 -v > /dev/null 2>&1
APACHE_IS_INSTALLED=$?

# Test if Nginx is installed
nginx -v > /dev/null 2>&1
NGINX_IS_INSTALLED=$?

# Installing dependency
# -qq implies -y --force-yes

if $(which rvm) -v > /dev/null 2>&1; then
	echo ">>>>Installing with RVM"
	$(which rvm) default@mailcatcher --create do gem install --no-rdoc --no-ri mailcatcher
	$(which rvm) wrapper default@mailcatcher --no-prefix mailcatcher catchmail
else
	# Gem check
	if ! gem -v > /dev/null 2>&1; then sudo aptitude install -y libgemplugin-ruby; fi

	# Install
	gem install --no-rdoc --no-ri mailcatcher
fi

# Make it start on boot
sudo tee /etc/init/mailcatcher.conf <<EOL
description "Mailcatcher"

start on runlevel [2345]
stop on runlevel [!2345]

respawn

exec /usr/bin/env $(which mailcatcher) --foreground --http-ip=0.0.0.0
EOL

# Start Mailcatcher
sudo service mailcatcher start

if [[ $PHP_IS_INSTALLED -eq 0 ]]; then
	# Make php use it to send mail
    echo "sendmail_path = /usr/bin/env $(which catchmail)" | sudo tee /etc/php/7.3/mods-available/mailcatcher.ini
	sudo phpenmod mailcatcher
	sudo service php7.3-fpm restart
fi

if [[ $APACHE_IS_INSTALLED -eq 0 ]]; then
	sudo service apache2 restart
fi

if [[ $NGINX_IS_INSTALLED -eq 0 ]]; then
	sudo service nginx restart
fi
