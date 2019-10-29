#!/bin/bash
set -e -u
psql=( psql -v ON_ERROR_STOP=1 )
PGHOST=localhost

for f in /docker-entrypoint-initdb.d/* /input/prepare/* /input/query/*; do
	case "$f" in
		*.sh)      echo "$0: running $f"; . "$f" ;;
		*.sql)     echo "$0: running $f"; "${psql[@]}" < "$f"; echo ;;
		*.sqld.gz) echo "$0: running $f"; gunzip -c "$f" | "${psql[@]}"; echo ;;
		*)         echo "$0: ignoring $f" ;;
	esac
	echo
done

# minimize container size
su postgres vacuumdb --full --freeze --analyze --all

su postgres pg_ctl -D "$PGDATA" -w stop

su postgres pg_ctl -D "$PGDATA" \
     -o "-c listen_addresses='' -c checkpoint_completion_target=0.1 -c wal_buffers=32kB" \
     -w start

"${psql[@]}" --username postgres -c "checkpoint;"
sleep 5;

# increase shared buffers
sed -i -e "s/^shared_buffers =.*$/shared_buffers = 256MB/" $PGDATA/postgresql.conf

# limit query time to 1 second
sed -i -e "s/^#statement_timeout =.*$/statement_timeout = 1000/" $PGDATA/postgresql.conf

# allow socket connections
sed -i -e "s!^#unix_socket_directories =.*$$!unix_socket_directories = '/var/run/postgresql'!" $PGDATA/postgresql.conf

su postgres pg_ctl -D "$PGDATA" -w stop || su postgres pg_ctl -D "$PGDATA" -w stop
su postgres pg_resetwal "$PGDATA"

echo
echo 'PostgreSQL init process complete; ready for start up.'
echo
