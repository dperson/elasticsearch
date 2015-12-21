FROM debian:jessie
MAINTAINER David Personette <dperson@dperson.com>

# Install elasticsearch
RUN export DEBIAN_FRONTEND='noninteractive' && \
    export version='2.1.1' && \
    export sha1sum='360ca8e329b8b0c34b1cd6012c452951f8d3e137' && \
    export URL='https://download.elasticsearch.org/elasticsearch/release/org'&&\
    export URL="$URL/elasticsearch/distribution/tar/elasticsearch/$version" && \
    groupadd -r elasticsearch && useradd -r -g elasticsearch elasticsearch && \
    echo "deb http://httpredir.debian.org/debian jessie-backports main" \
                >>/etc/apt/sources.list && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends ca-certificates curl \
                openjdk-8-jre \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    echo "downloading: elasticsearch-${version}.tar.gz ..." && \
    curl -LOC- -s $URL/elasticsearch-${version}.tar.gz && \
    sha1sum elasticsearch-${version}.tar.gz | grep -q "$sha1sum" && \
    tar -xf elasticsearch-${version}.tar.gz -C /tmp && \
    mv /tmp/elasticsearch-* /opt/elasticsearch && \
    echo '\nhttp.cors.enabled: true\n#http.cors.allow-origin:' \
                >>/opt/elasticsearch/config/elasticsearch.yml && \
    chown -Rh elasticsearch. /opt/elasticsearch && \
    apt-get purge -qqy curl && \
    apt-get autoremove -qqy && apt-get clean -qqy && \
    rm -rf /tmp/* /var/lib/apt/lists/* elasticsearch-${version}.tar.gz
COPY elasticsearch.sh /usr/bin/

EXPOSE 9200 9300

VOLUME ["/opt/elasticsearch/data", "/opt/elasticsearch/logs"]

ENTRYPOINT ["elasticsearch.sh"]
