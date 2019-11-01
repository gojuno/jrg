#!/bin/bash
set -e -u
HERE="$(dirname "$0")"
if [ -e "$HERE/../.venv/bin/behave" ]; then
    BEHAVE="$HERE/../.venv/bin/behave"
else
    BEHAVE=behave
fi
export PYTHONPATH="$HERE"
"$BEHAVE" -f formatter:BareFormatter --tags load $@ "$HERE"
