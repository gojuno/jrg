#!/bin/bash
set -e -u
HERE="$(dirname "$0")"
if [ -e "$HERE/../.venv/bin/behave" ]; then
    BEHAVE="$HERE/../.venv/bin/behave"
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
"$BEHAVE" -f formatter:BareFormatter --tags admin --tags ~unit $TAGS $@ "$HERE"
