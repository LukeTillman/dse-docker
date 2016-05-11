# DataStax Enterprise on Docker

> **Note:** Not meant for production use. See http://www.datastax.com/wp-content/uploads/resources/DataStax-WP-Best_Practices_Running_DSE_Within_Docker.pdf for details on setting up DSE and Docker in production.

## Starting DSE

Start a DSE node in Cassandra mode:
```
docker run --name some-dse -d luketillman/datastax-enterprise:tag
```

The default command is to run `dse`, so the [usual flags](http://docs.datastax.com/en/datastax_enterprise/4.8/datastax_enterprise/startStop/refDseStandalone.html) are available as well. For example, to start a Search node just add the `-s` flag:
```
docker run --name some-dse -d luketillman/datastax-enterprise:tag -s
```

## Starting Related Tools

With a node running, use `docker exec` to run other tools. For example, the `nodetool status` command:
```
docker exec -it some-dse nodetool status
```

Or to connect with `cqlsh`:
```
docker exec -it some-dse cqlsh
```
