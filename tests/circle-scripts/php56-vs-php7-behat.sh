

sleep 60

cd ${TERMINUS_SITE}

echo "php_version: 5.6" >> pantheon.yml

git add pantheon.yml
git commit -m 'Setting php 5.6'
git push

sleep 30

cd ..
terminus site clear-cache
terminus drush "config-list"
terminus drush role-list
terminus drush help
terminus drush pml
terminus drush status
terminus drush views-list
terminus drush watchdog-list

./execute-behat.sh


cd ${TERMINUS_SITE}
sleep 15
echo "php_version: 7.0" >> pantheon.yml

git add pantheon.yml
git commit -m 'Setting php 7.0'
git push

sleep 60
cd ..
terminus site clear-cache
terminus drush "config-list"
terminus drush role-list
terminus drush help
terminus drush pml
terminus drush status
terminus drush views-list
terminus drush watchdog-list
./execute-behat.sh
