FROM debian:stretch
MAINTAINER David Personette <dperson@gmail.com>

# Install elasticsearch
RUN export DEBIAN_FRONTEND='noninteractive' && \
    export version='5.1.2' && \
    export sha1sum='ae3d5b0d631a61e72b88f930b3cc9f8475a766d6' && \
    export url='https://artifacts.elastic.co/downloads/elasticsearch' && \
    groupadd -r elasticsearch && \
    useradd -c 'Elasticsearch' -d /opt/elasticsearch -g elasticsearch -r \
                elasticsearch && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends ca-certificates curl \
                openjdk-8-jre procps \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    echo "downloading: elasticsearch-${version}.tar.gz ..." && \
    curl -LOC- -s ${url}/elasticsearch-${version}.tar.gz && \
    sha1sum elasticsearch-${version}.tar.gz | grep -q "$sha1sum" && \
    tar -xf elasticsearch-${version}.tar.gz -C /tmp && \
    mv /tmp/elasticsearch-* /opt/elasticsearch && \
    (echo '\nhttp.cors.enabled: true\n#http.cors.allow-origin:' && \
    echo 'http.host: 0.0.0.0') \
                >>/opt/elasticsearch/config/elasticsearch.yml && \
    chown -Rh elasticsearch. /opt/elasticsearch && \
    apt-get purge -qqy curl && \
    apt-get autoremove -qqy && apt-get clean -qqy && \
    rm -rf /tmp/* /var/lib/apt/lists/* elasticsearch-${version}.tar.gz
COPY elasticsearch.sh /usr/bin/

EXPOSE 9200 9300

VOLUME ["/opt/elasticsearch/config", "/opt/elasticsearch/data", \
            "/opt/elasticsearch/logs", "/opt/elasticsearch/plugins"]

ENTRYPOINT ["elasticsearch.sh"]