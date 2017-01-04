# DataStax Enterprise Docker

[![Build Status](https://travis-ci.org/LukeTillman/dse-docker.svg?branch=master)](https://travis-ci.org/LukeTillman/dse-docker)

A Docker image for [DataStax Enterprise][datastax-enterprise]. Please use the 
[GitHub repository][github-repo] for opening issues.

## Usage

> **Note:** Not meant for production use. See [this whitepaper on DataStax.com][whitepaper] for 
> details on setting up DSE and Docker in production.

### Starting DSE

Start a DSE node in Cassandra mode:

```console
docker run --name some-dse -d luketillman/datastax-enterprise:tag
```

The default command is to run `dse`, so the [usual flags][dse-start] are available as well. For 
example, to start a Search node just add the `-s` flag:

```console
docker run --name some-dse -d luketillman/datastax-enterprise:tag -s
```

### Starting Related Tools

With a node running, use `docker exec` to run other tools. For example, the `nodetool status` 
command:

```console
docker exec -it some-dse nodetool status
```

Or to connect with `cqlsh`:

```console
docker exec -it some-dse cqlsh
```

### Environment Variables

The following environment variables can be set at runtime to override configuration. Setting the 
following values will override the corresponding settings in the `cassandra.yaml` configuration 
file:

 - **`LISTEN_ADDRESS`**: The IP address to listen for connections from other nodes. Defaults to 
     the hostname's IP address.
 - **`BROADCAST_ADDRESS`**: The IP address to advertise to other nodes. Defaults to the same 
     value as the `LISTEN_ADDRESS`.
 - **`RPC_ADDRESS`**: The IP address to listen for client/driver connections. Defaults to 
     `0.0.0.0` (i.e. wildcard).
 - **`BROADCAST_RPC_ADDRESS`**: The IP address to advertise to clients/drivers. Defaults to the 
    same value as the `BROADCAST_ADDRESS`.
 - **`SEEDS`**: The comma-delimited list of seed nodes for the cluster. Defaults to this node's 
     `BROADCAST_ADDRESS` if not set and will only be set the first time the node is started.
 - **`START_RPC`**: Whether to start the Thrift RPC server. Will leave the default in the 
     `cassandra.yaml` file if not set.
 - **`CLUSTER_NAME`**: The name of the cluster. Will leave the default in the `cassandra.yaml` 
     file if not set.
 - **`NUM_TOKENS:`**: The number of tokens randomly assigned to this node. Will leave the 
     default in the `cassandra.yaml` file if not set.

The configuration files for DSE (under `$install_dir/resources` in the tarball) are also exposed 
as a volume (see below).

### Volumes

The following volumes are created and can be mounted to the host system:

- **`/var/lib/cassandra`**: Data from Cassandra
- **`/var/lib/spark`**: Data from DSE Analytics w/ Spark
- **`/var/log/cassandra`**: Logs from Cassandra
- **`/var/log/spark`**: Logs from Spark
- **`/opt/dse/resources`**: Most configuration files including `cassandra.yaml`, `dse.yaml`, and
    more can be found here.

### Logging

You can view logs via Docker's container logs:

```console
docker logs some-dse
```

## Builds

Build and publish scripts are available in the `build` folder of the repository. All those 
scripts are meant to be run from the root of the repository. For example:

```console
> ./build/docker-build.sh
```

Continuous integration builds are handled by Travis.


[datastax-enterprise]: http://www.datastax.com/products/datastax-enterprise
[whitepaper]: http://www.datastax.com/wp-content/uploads/resources/DataStax-WP-Best_Practices_Running_DSE_Within_Docker.pdf
[github-repo]: https://github.com/LukeTillman/dse-docker
[dse-start]: http://docs.datastax.com/en/datastax_enterprise/4.8/datastax_enterprise/startStop/refDseStandalone.html