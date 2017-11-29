FROM debian:jessie-backports

# Add DSE group and user
RUN groupadd -r dse --gid=999 \
    && useradd -m -d /home/dse -r -g dse --uid=999 dse

# gosu for easy step down from root
ENV GOSU_VERSION 1.7
RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && apt-get purge -y --auto-remove ca-certificates wget

# Install JRE and Python prereqs
RUN set -x \
    && apt-get update \
    && apt-get -t jessie-backports install -y openjdk-8-jre-headless \
                                              ca-certificates-java \
                                              python \
                                              python-support \
                                              curl \
    && rm -rf /var/lib/apt/lists/*
    
# Get the version of DSE we're installing from the build argument
ARG DSE_VERSION
ENV DSE_VERSION ${DSE_VERSION}

# The URL where the DSE download credentials .netrc file is located
ARG DSE_CREDENTIALS_URL

# Download DSE by grabbing the .netrc credentials from the DSE_CREDENTIALS_URL, then unpack to
# /opt, and create a link (regardless of DSE version) under /opt/dse, making sure to clean up
# the credentials and other downloaded files
RUN set -x \
    && export DSE_TEMP="$(mktemp -d)" \
    && cd "$DSE_TEMP" \
    && curl -SLO "$DSE_CREDENTIALS_URL/.netrc" \
    && curl --netrc-file .netrc -SLO "http://downloads.datastax.com/enterprise/dse-$DSE_VERSION-bin.tar.gz" \
    && curl --netrc-file .netrc -SLO "http://downloads.datastax.com/enterprise/dse-$DSE_VERSION-bin.tar.gz.md5" \
    && md5sum -c *.md5 \
    && tar -xzf "dse-$DSE_VERSION-bin.tar.gz" -C /opt \
    && cd / \
    && rm -rf "$DSE_TEMP" \
    && ln -s /opt/dse* /opt/dse \
    && chown -R dse:dse /opt/dse*

# Append DSE binaries directory to the PATH so we can execute them from any working directory
ENV PATH /opt/dse/bin:$PATH

# Create directories for Cassandra and Spark data
RUN mkdir -p /var/lib/cassandra /var/lib/spark /var/lib/spark/worker /var/lib/spark/rdd /var/lib/dsefs \
    && chown -R dse:dse /var/lib/cassandra /var/lib/spark /var/lib/dsefs \
    && chmod 777 /var/lib/cassandra /var/lib/spark /var/lib/dsefs

# Create log directories
RUN mkdir -p /var/log/cassandra /var/log/spark \
    && chown -R dse:dse /var/log/cassandra /var/log/spark \
    && chmod 777 /var/log/cassandra /var/log/spark

# Volumes for Cassandra and Spark data
VOLUME /var/lib/cassandra /var/lib/spark /var/lib/dsefs /var/log/cassandra /var/log/spark

# Volume for configuration files in resources
VOLUME /opt/dse/resources

# Entrypoint script for launching
COPY entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

# Cassandra ports (intra-node, TLS intra-node, JMX, CQL, Thrift, DSEFS intra-node, intra-node messaging service)
EXPOSE 7000 7001 7199 8609 9042 9160

# DSE Search (Solr)
EXPOSE 8983 8984

# DSE Analytics (Spark)
EXPOSE 4040 7077 7080 7081 8090 9999 18080

# BYOH (this is deprecated and will be removed at some point)
EXPOSE 8012 9290 10000 50030 50060

# DSE Graph
EXPOSE 8182

# DSEFS
EXPOSE 5598 5599

# Ports purposefully not exposed by default:
#   9091 for DS Studio because it's not part of this image
#   8888 for OpsCenter because it's not part of this image

HEALTHCHECK --retries=6 --interval=50s --timeout=10s CMD ./healthcheck.sh

# Run DSE in foreground by default
CMD [ "dse", "cassandra", "-f" ]
