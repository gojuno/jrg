#!/bin/bash
set -e -u
export PGDATABASE="${PGDATABASE:-gis}"
export PGUSER="${PGUSER:-$(whoami)}"
export PGHOST=localhost

HERE="$(dirname "$0")"
VENV="${VENV:-$HERE/.venv}"

# If a file was specified, load it into the database
if [ $# -gt 0 ]; then
    osm2pgsql --slim --drop --number-processes 6 \
        --style "$HERE/sql/geocoder.style" \
        -d $PGDATABASE --prefix geocoder "$1"
    for f in "$HERE"/sql/prepare/*; do
        echo "$f"
        psql -v ON_ERROR_STOP=1 -qXf "$f"
    done
fi

# Update geocoding functions unconditionally
for f in "$HERE"/sql/query/*; do
    psql -qXf "$f"
done

# Creating a virtual environment if it doesn't exist
if [ ! -d "$VENV" ]; then
    python3 -m venv "$VENV"
    "$VENV"/bin/pip install -r "$HERE/web/requirements.txt"
fi

export FLASK_APP="$HERE/web/geocoder.py"
export FLASK_ENV=development
"$VENV/bin/flask" run
