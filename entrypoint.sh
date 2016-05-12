#!/bin/bash
set -e

# First arg is `-f` or `--some-option`
if [ "${1:0:1}" = '-' ]; then
  set -- dse cassandra -f "$@"
fi

# If we're running the dse command as root, run as the dse user
if [ "$1" = 'dse' -a "$(id -u)" = '0' ]; then
  chown -R dse /var/lib/cassandra /var/lib/spark /var/log/cassandra /var/log/spark /opt/dse/resources
  exec gosu dse "$BASH_SOURCE" "$@"
fi

# If we're starting DSE
if [ "$1" = 'dse' -a "$2" = 'cassandra' ]; then
	# RPC_ADDRESS is where we listen for drivers/clients to connect to us. Setting to 0.0.0.0 by default is fine
	# since we'll be specifying the BROADCAST_RPC_ADDRESS below 
  : ${RPC_ADDRESS='0.0.0.0'}

	# LISTEN_ADDRESS is where we listen for other nodes who want to communicate. 'auto' is not a valid value here,
	# so use the hostname's IP by default
  : ${LISTEN_ADDRESS='auto'}
  if [ "$LISTEN_ADDRESS" = 'auto' ]; then
    LISTEN_ADDRESS="$(hostname --ip-address)"
  fi

	# BROADCAST_ADDRESS is where we tell other nodes to communicate with us. Again, 'auto' is not a valid value here,
	# so default to the LISTEN_ADDRESS or the hostname's IP address if set to 'auto'
  : ${BROADCAST_ADDRESS="$LISTEN_ADDRESS"}
  if [ "$BROADCAST_ADDRESS" = 'auto' ]; then
    BROADCAST_ADDRESS="$(hostname --ip-address)"
  fi
	
	# By default, tell drivers/clients to use the same address that other nodes are using to communicate with us
  : ${BROADCAST_RPC_ADDRESS:=$BROADCAST_ADDRESS}

  # SEEDS is for other nodes in the cluster we know about. If not set (because we're the only node maybe), just
	# default to ourself 
  : ${SEEDS:="$BROADCAST_ADDRESS"}
  
	# Replace the default seeds setting in cassandra.yaml (this will only execute the first time we run when the
	# setting in cassandra.yaml is still set to 127.0.0.1)
  sed -ri 's/(- seeds:) "127.0.0.1"/\1 "'"$SEEDS"'"/' /opt/dse/resources/cassandra/conf/cassandra.yaml

	# Update the following settings in the cassandra.yaml file based on the ENV variable values
  for yaml in \
    broadcast_address \
    broadcast_rpc_address \
    cluster_name \
    listen_address \
    num_tokens \
    rpc_address \
    start_rpc \
  ; do
    var="${yaml^^}"
    val="${!var}"
    if [ "$val" ]; then
      sed -ri 's/^(# )?('"$yaml"':).*/\2 '"$val"'/' /opt/dse/resources/cassandra/conf/cassandra.yaml
    fi
  done
fi

# Run the command
exec "$@"