#!/bin/bash

set -e

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

echo "Installing the test dependencies"
mkdir -p $DOCUMENTROOT $PROJECT_DIR
composer global require --no-interaction codeception/codeception:2.3.4 facebook/webdriver:1.4.1 flow/jsonpath joomlatools/console
joomla plugin:install joomlatools/console-joomlatools:dev-master

DEPENDENCIES=('joomlatools-framework' 'joomlatools-framework-files' 'joomlatools-framework-activities' 'joomlatools-framework-scheduler' 'joomlatools-framework-ckeditor' 'joomlatools-framework-tags' 'joomlatools-framework-migrator' 'joomlatools-ui' 'logman' 'fileman' 'connect')
for DEPENDENCY in "${DEPENDENCIES[@]}"
do
  git clone -q -b master git@github.com:joomlatools/$DEPENDENCY.git $PROJECT_DIR/$DEPENDENCY
done

echo "Installing Joomla $JOOMLA"
joomla site:create --projects-dir=$PROJECT_DIR --release=$JOOMLA --symlink=textman,logman,fileman,connect --www=$DOCUMENTROOT --mysql-login="root" home


## starting in built server
echo "Starting the PHP webserver"
php -S localhost:8080 -t $TRAVIS_BUILD_DIR >/dev/null 2>&1 &
