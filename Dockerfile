FROM debian:jessie-backports

# Add DSE group and user
RUN groupadd -r dse --gid=999 \
    && useradd -r -g dse --uid=999 dse

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
    && apt-get install -y openjdk-8-jre-headless \
                          python \
                          python-support \
    && rm -rf /var/lib/apt/lists/*
    
# Get the version of DSE we're installing from the build argument
ARG DSE_VERSION
ENV DSE_VERSION ${DSE_VERSION}

# Add DSE (we're assuming it's available in the same directory as this Dockerfile)
# Hint: Use the download.sh script in the build directory to download a tarball
ADD dse-${DSE_VERSION}-bin.tar.gz /opt

# Link dse regardless of version to /opt/dse
RUN ln -s /opt/dse* /opt/dse \
    && chown -R dse:dse /opt/dse*

# Append DSE binaries directory to the PATH so we can execute them from any working directory
ENV PATH /opt/dse/bin:$PATH

# Create directories for Cassandra and Spark data
RUN mkdir -p /var/lib/cassandra /var/lib/spark /var/log/cassandra /var/log/spark \
    && chown -R dse:dse /var/lib/cassandra /var/lib/spark /var/log/cassandra /var/log/spark \
    && chmod 777 /var/lib/cassandra /var/lib/spark /var/log/cassandra /var/log/spark

# Volumes for Cassandra and Spark data
VOLUME /var/lib/cassandra /var/lib/spark /var/log/cassandra /var/log/spark

# Volume for configuration files in resources
VOLUME /opt/dse/resources

# Entrypoint script for launching
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

# Cassandra ports (intra-node, TLS intra-node, JMX, CQL, Thrift)
EXPOSE 7000 7001 7199 9042 9160

# DSE Search (Solr)
EXPOSE 8983 8984

# DSE Analytics (Spark)
EXPOSE 4040 7077 7080 7081

# BYOH
EXPOSE 8012 9290 10000 50030 50060

# Run DSE in foreground by default
CMD [ "dse", "cassandra", "-f" ]
