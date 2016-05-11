#!/bin/bash

# Download the dse version specified in DSE_VERSION file (assumes you have credentials setup in a 
# .netrc file or _netrc file under Windows)
. "`dirname $0`/DSE_VERSION"
curl --netrc -SLO http://downloads.datastax.com/enterprise/dse-$DSE_VERSION-bin.tar.gz
curl --netrc -SLO http://downloads.datastax.com/enterprise/dse-$DSE_VERSION-bin.tar.gz.md5
md5sum -c *.md5