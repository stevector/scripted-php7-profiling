#!/bin/bash

set -ex

terminus site clear-cache
terminus drush "config-list"
terminus drush help
terminus drush pml
terminus drush status
sleep 60

cd ${TERMINUS_SITE}

echo "php_version: 5.6" >> pantheon.yml

git add pantheon.yml
git commit -m 'Setting PHP 5.6'
git push

sleep 30

cd ..
./execute-behat.sh


cd ${TERMINUS_SITE}
sleep 15
echo "php_version: 7.0" >> pantheon.yml

git add pantheon.yml
git commit -m 'Setting PHP 7.0'
git push

sleep 60
cd ..
./execute-behat.sh
