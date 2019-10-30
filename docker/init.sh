#!/bin/bash

# Scirt to init container with data.
# $1 for osm.pbf file

PGUSER=postgres
PGDATABASE=postgres
PGDATA=/pgdata/

JRG_SRC=/usr/src/jrg

/docker-entrypoint.sh postgres &

psql=( psql -U postgres -v ON_ERROR_STOP=1 )

for i in `seq 1 120`; do
  echo "Waiting for PostgreSQL start, attempt $i..."
  ${psql[@]} -c 'select 1;' && break
  sleep 1
done

${psql[@]} -c "create extension postgis"

osm2pgsql --slim --drop --number-processes 4 --style=/usr/src/jrg/sql/geocoder.style -U postgres -d postgres --prefix geocoder $1


for f in ${JRG_SRC}/sql/prepare/* ${JRG_SRC}/sql/query/*; do
	echo "$0: running $f"; "${psql[@]}" < "$f"; echo
done

# minimize container size
su postgres -c "vacuumdb --full --freeze --analyze --all"

su postgres -c "pg_ctl -D "$PGDATA" -w stop"

su postgres -c "pg_ctl -D \"$PGDATA\" \
     -o \"-c listen_addresses='' -c checkpoint_completion_target=0.1 -c wal_buffers=32kB\" \
     -w start"

"${psql[@]}" --username postgres -c "checkpoint;"
sleep 5;
su postgres -c "pg_ctl -D "$PGDATA" -w stop"
