#!/bin/bash
set -e -u
HERE="$(dirname "$0")"
VENV="${VENV:-$HERE/../.venv}"

if [ -e "$VENV/bin/behave" ]; then
    BEHAVE="$VENV/bin/behave"
else
    BEHAVE=behave
fi

if [ "${1-}" == "wip" ]; then
    TAGS="--tags wip"
    shift
else
    TAGS="--tags ~wip"
fi
export PYTHONPATH="$HERE"
"$BEHAVE" -f formatter:BareFormatter --tags ~load --tags ~unit $TAGS $@ "$HERE"
