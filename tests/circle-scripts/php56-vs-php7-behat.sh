#!/bin/bash

set -ex

PANTHEON_GIT_URL=$(terminus site connection-info --field=git_url)
PANTHEON_SITE_URL="$TERMINUS_ENV-$TERMINUS_SITE.pantheonsite.io"
BEHAT_PARAMS='{"extensions" : {"Behat\\MinkExtension" : {"base_url" : "http://'$TERMINUS_ENV'-'$TERMINUS_SITE'.pantheonsite.io"} }}'
PREPARE_DIR="/tmp/$TERMINUS_ENV-$TERMINUS_SITE"
BASH_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


###
# Switch to git mode for pushing the files up
###
terminus site set-connection-mode --mode=git
rm -rf $PREPARE_DIR
git clone -b $TERMINUS_ENV $PANTHEON_GIT_URL $PREPARE_DIR


sleep 10

echo $BASH_DIR


cd $PREPARE_DIR
echo "php_version: 5.6" >> pantheon.yml

git add pantheon.yml
git commit -m 'Setting php 5.6'
git push

sleep 30
terminus wp "cache flush"
terminus  site  clear-cache
yes | terminus site wipe
 {
   terminus wp "core install --title=$TERMINUS_ENV-$TERMINUS_SITE --url=$PANTHEON_SITE_URL --admin_user=$WORDPRESS_ADMIN_USERNAME --admin_email=wp-lcache@getpantheon.com --admin_password=$WORDPRESS_ADMIN_PASSWORD"
 } &> /dev/null


exit;



cd $BASH_DIR
 ./../../vendor/bin/behat --config=../behat/behat-pantheon.yml ../behat/features/


cd $PREPARE_DIR
sleep 15
echo "php_version: 7.0" >> pantheon.yml

git add pantheon.yml
git commit -m 'Setting php 7.0'
git push

sleep 60
terminus wp "cache flush"
terminus  site  clear-cache
yes | terminus site wipe
 {
   terminus wp "core install --title=$TERMINUS_ENV-$TERMINUS_SITE --url=$PANTHEON_SITE_URL --admin_user=$WORDPRESS_ADMIN_USERNAME --admin_email=wp-lcache@getpantheon.com --admin_password=$WORDPRESS_ADMIN_PASSWORD"
 } &> /dev/null


cd $BASH_DIR
 ./../../vendor/bin/behat --config=../behat/behat-pantheon.yml ../behat/features/