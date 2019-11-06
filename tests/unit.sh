#!/bin/bash
# This script runs unit tests on a pre-built OSM file.

set -e -u
export PGDATABASE="${PGDATABASE:-test}"
export PGUSER="${PGUSER:-$(whoami)}"
export PGHOST=localhost

# Note that $HERE points to the top-level directory
HERE="$(dirname "$0")/.."
VENV="${VENV:-$HERE/.venv}"

# Load test OSM data
echo "Loading test data"
osm2pgsql --slim --drop --style "$HERE/sql/geocoder.style" \
    -d $PGDATABASE --prefix geocoder "$HERE/tests/unit_data.osm" 2>/dev/null

# Execute all the scripts
for f in "$HERE"/sql/prepare/* "$HERE"/sql/query/*; do
    echo "$f"
    psql -v ON_ERROR_STOP=1 -qXf "$f"
done

# Creating a virtual environment if it doesn't exist
if [ ! -d "$VENV" ]; then
    python3 -m venv "$VENV"
    "$VENV"/bin/pip install -r "$HERE/web/requirements.txt"
fi
[ ! -e "$VENV/bin/behave" ] && "$VENV"/bin/pip install behave

# Start web server in the background
export FLASK_APP="$HERE/web/geocoder.py"
export FLASK_ENV=development
export GEOCODER_PORT=5001
"$VENV/bin/flask" run --port $GEOCODER_PORT 2>/dev/null &
FLASK_JOB="$(jobs -p | head -n 1)"
trap "kill $FLASK_JOB; exit" EXIT SIGHUP SIGINT SIGQUIT SIGTERM

# Allowing flask time to start
sleep 1

# Make tags list
if [ "${1-}" == "wip" ]; then
    TAGS="--tags wip"
    shift
else
    TAGS="--tags ~wip"
fi

# Run tests
export PYTHONPATH="$HERE/tests"
"$VENV/bin/behave" -f formatter:BareFormatter --tags unit ${TAGS-} $@ "$HERE/tests" || true
