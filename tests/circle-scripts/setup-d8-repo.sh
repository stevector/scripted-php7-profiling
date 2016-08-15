#!/bin/bash

# Bring the code down to Circle so that modules can be added via composer.
git clone $(terminus site connection-info --field=git_url) $TERMINUS_SITE
cd $TERMINUS_SITE
git checkout -b $TERMINUS_ENV
