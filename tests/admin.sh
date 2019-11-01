#!/bin/bash
set -e -u
HERE="$(dirname "$0")"
VENV="${VENV:-$HERE/../.venv}"
if [ "${1-}" == "wip" ]; then
    TAGS="--tags wip"
    shift
else
    TAGS="--tags ~wip"
fi
export PYTHONPATH="$HERE"
"$VENV/bin/behave" -f formatter:BareFormatter --tags admin --tags ~unit $TAGS $@ "$HERE"
