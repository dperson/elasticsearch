FROM debian:jessie
MAINTAINER David Personette <dperson@dperson.com>

# Install elasticsearch
RUN export DEBIAN_FRONTEND='noninteractive' && \
    export version='2.0.0' && \
    export URL='https://download.elastic.co/elasticsearch/release/org' && \
    export URL="$URL/elasticsearch/distribution/tar/elasticsearch/$version" && \
    export sha1sum='e369d8579bd3a2e8b5344278d5043f19f14cac88' && \
    groupadd -r elasticsearch && useradd -r -g elasticsearch elasticsearch && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends ca-certificates curl \
                openjdk-7-jre \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
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

VOLUME ["/run", "/tmp", "/var/cache", "/var/lib", "/var/log", "/var/tmp", \
            "/opt/elasticsearch/data", "/opt/elasticsearch/logs"]

ENTRYPOINT ["elasticsearch.sh"]
