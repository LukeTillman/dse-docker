#!/bin/bash

set -e  # Bail if something fails

# Starts httpd from busybox in Docker, serving up any files under the 'http'
# directory relative to the script.

# Get the absolute path to this script and append 'http' subdirectory to get the absolute
# path we want to serve
pushd `dirname $0` > /dev/null
www_path="$(pwd)/http"
popd > /dev/null

# Start busybox httpd to make any files in the http folder (e.g. download credentials)
# available via HTTP
docker run -d -p 8000:80 -v $www_path:/www --name build-static busybox httpd -f -h /www

# Get the IP address where this will be reachable during a docker build and export it as the
# environment variable that the build script expects
export DSE_CREDENTIALS_URL=$(docker exec build-static ip route | awk '/default/ { print $3 }')