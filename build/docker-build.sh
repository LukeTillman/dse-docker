#!/bin/bash

set -e  # Bail if something fails

# Make sure we have the DSE_CREDENTIALS_URL available
if [[ -z "$DOCKER_USER" ]]; then
  echo 'The DSE_CREDENTIALS_URL environment variable must be set before building'
  exit 1
fi

# Set the DSE_VERSION so it can be used then run docker build
. "`dirname $0`/DSE_VERSION"

# Run the build
docker build --build-arg DSE_VERSION=$DSE_VERSION --build-arg DSE_CREDENTIALS_URL=$DSE_CREDENTIALS_URL -t luketillman/datastax-enterprise:$DSE_VERSION .

# Output some image information after the build is finished
docker images luketillman/datastax-enterprise