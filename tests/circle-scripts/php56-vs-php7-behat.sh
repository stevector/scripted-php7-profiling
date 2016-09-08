#!/bin/bash

set -ex

cd ${TERMINUS_SITE}

echo "php_version: 7.0 " >> pantheon.yml

git add pantheon.yml
git commit -m 'Setting php 7, clean install of Drupal Core'
git push

sleep 30
terminus drush "si -y"
terminus site clear-cache

cd ..
./execute-behat.sh

cd ${TERMINUS_SITE}
sleep 15

composer config repositories.drupal composer https://packages.drupal.org/8
composer require drupal/lcache:1.x-dev

git add pantheon.yml
git commit -m 'Adding LCache'
git push

sleep 60
terminus drush "si -y"
terminus drush "en lcache -y"
terminus site clear-cache

cd ..
./execute-behat.sh
