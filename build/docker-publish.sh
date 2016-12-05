#!/bin/bash

# This script assumes the following environment variables are present
#
#   DOCKER_USER=username
#   DOCKER_EMAIL=some@email.com
#   DOCKER_PASS=somesecretpassword
DOCKER_IMAGE=schrepfler/datastax-enterprise

# Allow git describe to fail (which it will if this isn't a tagged commit)
set +e 
CURRENT_TAG=`git describe --tags --exact-match 2> /dev/null`

set -e # Exit with nonzero exit code if anything fails

# Only allow publish for tags
if [ -z "$CURRENT_TAG" ]; then
  echo "Current commit is not for a tag, skipping publish"
  exit 0
fi

# Make sure we have a user/pass
if [[ -z "$DOCKER_USER" ]] || [[ -z "$DOCKER_EMAIL" ]] || [[ -z "$DOCKER_PASS" ]]; then
  echo "DOCKER_USER or DOCKER_EMAIL or DOCKER_PASS not set"
  exit 1
fi

echo "Publishing $DOCKER_IMAGE for git tag $CURRENT_TAG"

# Login to Docker and push the image which should have been built
docker login -e $DOCKER_EMAIL -u $DOCKER_USER -p $DOCKER_PASS
docker push $DOCKER_IMAGE
