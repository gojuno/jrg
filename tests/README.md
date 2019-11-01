# Testing Juno Reverse Geocoder

The testing framework is based on [behave](https://behave.readthedocs.io/en/latest/),
with cases being explained in English in the `features` directory.

You may notice it has few files: for unit testing, test cases are generated on the fly
from the `unit_data.osm` file, which has both OSM data for testing, and named nodes
tagged `feature=*` for test cases. These use coordinates for "When" clause, and the string
in `then` and `and` tags for the respective Gherkin language clauses.

## Running the unit tests

You would need a PostgreSQL database named `test` (unless you override the name with
the `PGDATABASE` environment variable). Install a PostGIS extension into it:

    psql test -c "create extension postgis;"

And the run `./unit.sh`. It would populate the database with OSM data, run all scripts
from `sql/prepare` and `sql/query` directories, generate behave testing files from
the `unit_data.osm`, run all the tests, and then remove temporary data. The whole process
should take around five seconds.

## Updating unit tests

Just open the `unit_data.osm` with JOSM and edit it like a regular OSM file. Be careful
not to adjust tests you don't intend to. Do not download OSM data straight into this
file; copy and paste individual objects instead (Ctrl+Alt+V pastes in place).
When you're done, remove the layer from JOSM and run the renumbering script:

    utils/renumber_negative_ids.py unit_data.osm -

It would turn negative identifiers into positive, keeping object relations.

Add `wip=yes` tag on new tests you are debugging, so that you can single them out
by running `./unit.sh wip`.

## Load and admin testing

The other two scripts in this directory execute tests on a running geocoder,
which has a database populated with data for at least the East Coast states,
including NY, NJ, MA and few others.

`load.sh` simply spends a few seconds doing random queries, and fails if
the calculated RPS falls below 30 for geocoding queries and 45 for object
lookup queries.

`admin.sh` tests that all New York and neighboring states' borders are correctly
mapped. If it fails, time to open JOSM and do some fixing.

These scripts expect a `.venv` directory created above this one with either
`../run.sh` or `unit.sh`. If you have your own environment with `behave`
installed, do not forget to use it for running the scripts.
