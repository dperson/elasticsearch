FROM debian:jessie
MAINTAINER David Personette <dperson@gmail.com>

# Install elasticsearch
RUN export DEBIAN_FRONTEND='noninteractive' && \
    export version='2.3.5' && \
    export sha1sum='ba8842e4ff35370b9ae6a1a12b7f1d12aa9b5c66' && \
    export url='https://download.elasticsearch.org/elasticsearch/release/org'&&\
    export url="$url/elasticsearch/distribution/tar/elasticsearch/$version" && \
    groupadd -r elasticsearch && \
    useradd -c 'Elasticsearch' -d /opt/elasticsearch -g elasticsearch -r \
                elasticsearch && \
    echo "deb http://httpredir.debian.org/debian jessie-backports main" \
                >>/etc/apt/sources.list && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends ca-certificates curl \
                openjdk-8-jre \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    echo "downloading: elasticsearch-${version}.tar.gz ..." && \
    curl -LOC- -s ${url}/elasticsearch-${version}.tar.gz && \
    sha1sum elasticsearch-${version}.tar.gz | grep -q "$sha1sum" && \
    tar -xf elasticsearch-${version}.tar.gz -C /tmp && \
    mv /tmp/elasticsearch-* /opt/elasticsearch && \
    (echo '\nhttp.cors.enabled: true\n#http.cors.allow-origin:' && \
    echo 'network.host: 0.0.0.0') \
                >>/opt/elasticsearch/config/elasticsearch.yml && \
    cp /opt/elasticsearch/config/logging.yml \
                /opt/elasticsearch/config/logging.yml.orig && \
    sed -i '/org.apache.http/,+19d; /deprecation_log_file:/,$d; /depreca/,+2d' \
                /opt/elasticsearch/config/logging.yml && \
    chown -Rh elasticsearch. /opt/elasticsearch && \
    apt-get purge -qqy curl && \
    apt-get autoremove -qqy && apt-get clean -qqy && \
    rm -rf /tmp/* /var/lib/apt/lists/* elasticsearch-${version}.tar.gz
COPY elasticsearch.sh /usr/bin/

EXPOSE 9200 9300

VOLUME ["/opt/elasticsearch/config", "/opt/elasticsearch/data", \
            "/opt/elasticsearch/logs", "/opt/elasticsearch/plugins"]

ENTRYPOINT ["elasticsearch.sh"]