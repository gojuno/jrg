#!/bin/sh
chmod 700 /pgdata/
pg_ctl -D /pgdata/ -w start
