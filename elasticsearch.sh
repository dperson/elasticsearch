#!/usr/bin/env bash
#===============================================================================
#          FILE: elasticsearch.sh
#
#         USAGE: ./elasticsearch.sh
#
#   DESCRIPTION: Entrypoint for elasticsearch docker container
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: David Personette (dperson@gmail.com),
#  ORGANIZATION:
#       CREATED: 2014-10-16 02:56
#      REVISION: 1.0
#===============================================================================

set -o nounset                              # Treat unset variables as an error

### usage: Help
# Arguments:
#   none)
# Return: Help text
usage() { local RC="${1:-0}"
    echo "Usage: ${0##*/} [-opt] [command]
Options (fields in '[]' are optional, '<>' are required):
    -h          This help

The 'command' (if provided and valid) will be run instead of elasticsearch
" >&2
    exit $RC
}

while getopts ":h:" opt; do
    case "$opt" in
        h) usage ;;
        "?") echo "Unknown option: -$OPTARG"; usage 1 ;;
        ":") echo "No argument value for option: -$OPTARG"; usage 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

[[ "${USERID:-""}" =~ ^[0-9]+$ ]] && usermod -u $USERID -o elasticsearch
[[ "${GROUPID:-""}" =~ ^[0-9]+$ ]] && groupmod -g $GROUPID -o elasticsearch

export JAVA_HOME='/usr/lib/jvm/java-8-openjdk-amd64'
chown -Rh elasticsearch. /opt/elasticsearch 2>&1 | grep -iv 'Read-only' || :

if [[ $# -ge 1 && -x $(which $1 2>&-) ]]; then
    exec "$@"
elif [[ $# -ge 1 ]]; then
    echo "ERROR: command not found: $1"
    exit 13
elif ps -ef | egrep -v 'grep|elasticsearch.sh' | grep -q elasticsearch; then
    echo "Service already running, please restart container to apply changes"
else
    exec su -l elasticsearch -s /bin/bash -c \
                "exec /opt/elasticsearch/bin/elasticsearch"
fi