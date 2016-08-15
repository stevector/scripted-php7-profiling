#!/bin/bash

# Bring the code down to Circle so that modules can be added via composer.
git clone $(terminus site connection-info --field=git_url) drupal8
cd drupal8
git checkout -b $TERMINUS_ENV
