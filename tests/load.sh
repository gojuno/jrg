#!/bin/bash
set -e -u
HERE="$(dirname "$0")"
VENV="${VENV:-$HERE/../.venv}"
export PYTHONPATH="$HERE"
"$VENV/bin/behave" -f formatter:BareFormatter --tags load $@ "$HERE"
