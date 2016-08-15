#!/bin/bash

set -e # Exit with nonzero exit code if anything fails

# If a pull request
if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then 
  echo "Skipping publish for pull request"
  exit 0
fi

# Invoke the publish script
MY_PATH="`dirname \"$0\"`"
( exec "$MY_PATH/docker-publish.sh" )