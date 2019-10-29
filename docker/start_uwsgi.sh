#!/bin/sh
for i in `seq 1 20`; do
  echo "Waiting for PostgreSQL start, attempt $i..."
  psql -U postgres -c 'select 1;' && break
  sleep 1
done
/usr/local/bin/uwsgi --ini /geocoder/uwsgi.ini
