#!/bin/bash


	# Get a list of all environments
	PANTHEON_ENVS="$(terminus site environments --site=$TERMINUS_SITE --format=bash)"
	terminus site environments --site=$TERMINUS_SITE

	# If the multidev for this branch is found
	if [[ ${PANTHEON_ENVS} == *"${TERMINUS_ENV}"* ]]
	then
		# Send a message
		echo "Multidev found"
	else
		terminus site create-env --to-env=$TERMINUS_ENV --from-env=dev
	fi

