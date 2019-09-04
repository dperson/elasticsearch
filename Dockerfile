FROM alpine
MAINTAINER David Personette <dperson@gmail.com>

# Install elasticsearch
RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash curl openjdk11-jre-headless shadow \
                tini tzdata && \
    export version='7.3.1' && \
    export shasum='fa4348461879ba1f979b44fdb3752af27a6fb8f6259d2a87e667d76' && \
    export url='https://artifacts.elastic.co/downloads/elasticsearch' && \
    addgroup -S elasticsearch && \
    adduser -S -D -H -h /opt/elasticsearch -s /sbin/nologin -G elasticsearch \
                -g 'Elasticsearch User' elasticsearch && \
    file="elasticsearch-${version}-linux-x86_64.tar.gz" && \
    echo "downloading: $file ..." && \
    curl -LOSs ${url}/$file && \
    sha512sum $file | grep -q "$shasum" || \
    { echo "expected $shasum, got $(sha512sum $file)"; exit 13; } && \
    tar -xf $file -C /tmp && \
    mv /tmp/elasticsearch-* /opt/elasticsearch && \
    (echo '\nhttp.cors.enabled: true\n#http.cors.allow-origin:' && \
    echo 'http.host: 0.0.0.0') \
                >>/opt/elasticsearch/config/elasticsearch.yml && \
    sed -i 's/^\(-Xm[sx]\).*/\1512m/' /opt/elasticsearch/config/jvm.options && \
    chown -Rh elasticsearch. /opt/elasticsearch && \
    rm -rf /tmp/* $file
COPY elasticsearch.sh /usr/bin/

EXPOSE 9200 9300

HEALTHCHECK --interval=60s --timeout=15s --start-period=120s \
             CMD curl -Lk 'http://localhost:9200'

VOLUME ["/opt/elasticsearch/config", "/opt/elasticsearch/data", \
            "/opt/elasticsearch/logs", "/opt/elasticsearch/plugins"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/elasticsearch.sh"]