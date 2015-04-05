[![logo](https://www.elastic.co/static/img/logo-elastic.png)](https://www.elastic.co/)

# Elasticsearch

Elasticsearch docker container

# What is Elasticsearch?

Elasticsearch is a search server based on Lucene. It provides a distributed,
multitenant-capable full-text search engine with a RESTful web interface and
schema-free JSON documents. Elasticsearch is developed in Java and is released
as open source under the terms of the Apache License. Elasticsearch is the
second most popular enterprise search engine.

# How to use this image

When started Elasticsearch container will listen on ports 9200 and 9300.

## Hosting a Elasticsearch instance

    sudo docker run -d dperson/elasticsearch

## Configuration

    sudo docker run -it --rm dperson/elasticsearch -h

    Usage: elasticsearch.sh [-opt] [command]
    Options (fields in '[]' are optional, '<>' are required):
        -h          This help
        -t ""       Configure timezone
                    possible arg: "[timezone]" - zoneinfo timezone for container

    The 'command' (if provided and valid) will be run instead of elasticsearch

ENVIROMENT VARIABLES (only available with `docker run`)

 * `TIMEZONE` - As above, set a zoneinfo timezone, IE `EST5EDT`

## Examples

Any of the commands can be run at creation with `docker run` or later with
`docker exec elasticsearch.sh` (as of version 1.3 of docker).

    sudo docker run -p 9200:9200 -p 9300:9300 -d dperson/elasticsearch \
                -T EST5EDT

Will get you the same settings as

    sudo docker run --name es -p 9200:9200 -p 9300:9300 -d dperson/elasticsearch
    sudo docker exec es elasticsearch.sh -T EST5EDT ls -AlF /etc/localtime
    sudo docker restart es

## Complex configuration

[Example configs](http://www.elastic.co/guide/)

If you wish to adapt the default configuration, use something like the following
to copy it from a running container:

    sudo docker cp es:/opt/elasticsearch/config /some/path

You can use the modified configuration with:

    sudo docker run --name es -p 9200:9200 -p 9300:9300 \
                -v /some/path:/opt/elasticsearch/config:ro \
                -d dperson/elasticsearch

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact me
through a [GitHub issue](https://github.com/dperson/elasticsearch/issues).