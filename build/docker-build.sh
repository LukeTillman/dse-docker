#!/bin/bash

# Set the DSE_VERSION so it can be used then run docker build
. "`dirname $0`/DSE_VERSION"

docker build --build-arg DSE_VERSION=$DSE_VERSION -t schrepfler/datastax-enterprise:$DSE_VERSION .
