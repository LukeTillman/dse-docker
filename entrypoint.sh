#!/bin/bash
set -ex

echo "Starting DSE"
echo "Path is $PATH"

# first arg is `-f` or `--some-option`
if [ "${1:0:1}" = '-' ]; then
	set -- dse cassandra -f "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'dse' -a "$(id -u)" = '0' ]; then
	chown -R dse /var/lib/cassandra /var/lib/spark /opt/dse/resources
	exec gosu dse "$BASH_SOURCE" "$@"
fi

exec "$@"