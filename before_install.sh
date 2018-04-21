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

composer global require --no-interaction codeception/codeception:2.3.4 facebook/webdriver:1.4.1

## starting in built server
echo "Starting the PHP webserver"
php -S localhost:8080 -t $TRAVIS_BUILD_DIR >/dev/null 2>&1 &
