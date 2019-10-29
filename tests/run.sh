#!/bin/bash
set -e -u
HERE="$(dirname "$0")"
VENV="${VENV:-$HERE/../.venv}"
if [ "${1-}" == "load" ]; then
    TAGS="--tags load"
    shift
elif [ "${1-}" == "wip" ]; then
    TAGS="--tags wip"
    shift
elif [ "${1-}" == "all" ]; then
    TAGS=""
    shift
else
    TAGS="--tags ~load --tags ~wip"
fi

export PYTHONPATH="$HERE"
"$VENV/bin/behave" -f formatter:BareFormatter --tags ~unit ${TAGS-} $@ "$HERE"
