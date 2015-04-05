FROM debian:jessie
MAINTAINER David Personette <dperson@dperson.com>

# Install elasticsearch
RUN export DEBIAN_FRONTEND='noninteractive' && \
    export URL='https://download.elasticsearch.org/elasticsearch/elasticsearch'\
                && \
    export version='1.5.0' && \
    export sha1sum='07987acd48c754b8e7db6829314b56e1928b5e1b' && \
    groupadd -r elasticsearch && useradd -r -g elasticsearch elasticsearch && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends ca-certificates curl \
                openjdk-7-jre \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    curl -LOC- -s $URL/elasticsearch-${version}.tar.gz && \
    sha1sum elasticsearch-${version}.tar.gz | grep -q "$sha1sum" && \
    tar -xf elasticsearch-${version}.tar.gz -C /tmp && \
    mv /tmp/elasticsearch-* /opt/elasticsearch && \
    echo '\nhttp.cors.enabled: true\n#http.cors.allow-origin:' >> \
                /opt/elasticsearch/config/elasticsearch.yml && \
    apt-get purge -qqy curl && \
    apt-get autoremove -qqy && apt-get clean -qqy && \
    rm -rf /tmp/* /var/lib/apt/lists/* elasticsearch-${version}.tar.gz
COPY elasticsearch.sh /usr/bin/

EXPOSE 9200
EXPOSE 9300

VOLUME ["/opt/elasticsearch/data"]

ENTRYPOINT ["elasticsearch.sh"]
