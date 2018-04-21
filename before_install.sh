#!/bin/bash

set -e

##
# Install the build tools
##

echo "Install Phing"
pear channel-discover pear.phing.info
pear install phing/phing
phpenv rehash

## config php
echo "Configure PHP"
phpenv config-rm xdebug.ini
echo 'error_reporting = 22519' >> ~/.phpenv/versions/$(phpenv version-name)/etc/conf.d/travis.ini


## Set up Codeception tools
echo "Creating virtual display"
/sbin/start-stop-daemon --start --quiet --pidfile /tmp/custom_xvfb_99.pid --make-pidfile --background --exec /usr/bin/Xvfb -- :99 -ac -screen 0 1920x1080x8
sleep 2

echo "Installing Chrome Driver"
curl -s -L https://chromedriver.storage.googleapis.com/2.37/chromedriver_linux64.zip -o /tmp/chromedriver.zip
unzip /tmp/chromedriver.zip -d /home/travis/
chmod +x /home/travis/chromedriver
/home/travis/chromedriver --verbose --log-path=/tmp/chromedriver.log --url-base=/wd/hub &

echo "Starting MailCatcher"
gem install --no-ri --no-rdoc mailcatcher
mailcatcher > /dev/null 2>&1 &

echo "Installing the test dependencies"
mkdir -p $DOCUMENTROOT $PROJECT_DIR
composer global require --no-interaction codeception/codeception:2.3.4 facebook/webdriver:1.4.1 flow/jsonpath joomlatools/console
joomla plugin:install joomlatools/console-joomlatools:dev-master

echo "Installing Joomla $JOOMLA"
joomla site:create --projects-dir=$PROJECT_DIR --release=$JOOMLA --www=$DOCUMENTROOT --mysql-login="root" home

echo "Starting the PHP webserver"
php -S localhost:8080 -t $DOCUMENTROOT/home  >/dev/null 2>&1 &

cd $TRAVIS_BUILD_DIR
