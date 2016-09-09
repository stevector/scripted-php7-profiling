#!/bin/bash

set -ex


# Create a drush alias file so that Behat tests can be executed against Pantheon.
terminus sites aliases
# Drush Behat driver fails without this option.
echo "\$options['strict'] = 0;" >> ~/.drush/pantheon.aliases.drushrc.php

export BEHAT_PARAMS='{"extensions" : {"Behat\\MinkExtension" : {"base_url" : "http://'$TERMINUS_ENV'-'$TERMINUS_SITE'.pantheonsite.io/"}, "Drupal\\DrupalExtension" : {"drush" :   {  "alias":  "@pantheon.'$TERMINUS_SITE'.'$TERMINUS_ENV'" }}}}'

terminus site set-connection-mode  --mode=git


cd ${TERMINUS_SITE}

echo "php_version: 7.0 " >> pantheon.yml

git add pantheon.yml
git commit -m 'Clean install of Drupal Core'
git push

sleep 30
{
  terminus drush "si -y"
} &> /dev/null
terminus site clear-cache


# Make a custom admin user because the normal Drush/Behat way of creating users
# 1) is slow and 2) would require rerunning with each Behat run and 3)
# would result nodes getting deleted at the end of each run.
{
 terminus drush "user-create $DRUPAL_ADMIN_USERNAME"
 terminus drush "user-add-role  administrator $DRUPAL_ADMIN_USERNAME"
 terminus drush "upwd $DRUPAL_ADMIN_USERNAME  --password=$DRUPAL_ADMIN_PASSWORD"
} &> /dev/null



cd ..
for i in $(seq 20); do
  echo "Peformance test pass $i with Core"
  ./../../vendor/bin/behat --config=../behat/behat-pantheon.yml ../behat/features/create-node-view-all-nodes.feature
done

cd ${TERMINUS_SITE}
sleep 15

composer config repositories.drupal composer https://packages.drupal.org/8
composer require drupal/lcache:1.x-dev

# A .git directory might in modules/lcache/
git add modules/lcache/*
git add .
git commit -m 'Adding LCache'
git push

sleep 60
{
  terminus drush "si -y"
} &> /dev/null
terminus drush "en lcache -y"
terminus site clear-cache

echo "\$settings['cache']['default'] = 'cache.backend.lcache';" >> sites/default/settings.php


git add .
git commit -m 'LCache in settings.php'
git push


# Make a custom admin user because the normal Drush/Behat way of creating users
# 1) is slow and 2) would require rerunning with each Behat run and 3)
# would result nodes getting deleted at the end of each run.
{
 terminus drush "user-create $DRUPAL_ADMIN_USERNAME"
 terminus drush "user-add-role  administrator $DRUPAL_ADMIN_USERNAME"
 terminus drush "upwd $DRUPAL_ADMIN_USERNAME  --password=$DRUPAL_ADMIN_PASSWORD"
} &> /dev/null


cd ..
for i in $(seq 20); do
  echo "Peformance test pass $i with LCache"
  ./../../vendor/bin/behat --config=../behat/behat-pantheon.yml ../behat/features/create-node-view-all-nodes.feature
done

terminus site clear-cache


