FROM mdillon/postgis:11 as builder

ARG VERSION=master
ENV PGUSER=postgres
ENV PGDATABASE=gis
ENV PGDATA=/var/lib/postgresql

RUN apt-get update && apt-get install -y osm2pgsql

COPY input/* /input/
COPY *.sh /

RUN ls /input && osm2pgsql --slim --drop --number-processes 4 --style /input/geocoder.style -d gis --prefix geocoder /input/area_of_interest.osm.pbf \
    && /postinit-postgres-with-data.sh

FROM mdillon/postgis:11

ARG METRICS_PORT=10000
ARG METRICS_DIR=/tmp/metrics

COPY --from=builder --chown=postgres /pgdata/ /pgdata/

COPY geocoder/* /geocoder/

RUN set -x \
    && eatmydata apt-get update \
    && eatmydata apt-get install -y --no-install-recommends \
        python3 python3-psycopg2 python3-pip python3-setuptools python3-wheel python3-dev build-essential nginx supervisor \
    && rm /etc/nginx/sites-enabled/default \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt/archives/* \
    && pip3 install -r /geocoder/requirements.txt \
# Forward nginx logs to supervisord
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisor-geocoder.conf /etc/supervisor/conf.d/

# Port 5432 is exposed by inheritance
EXPOSE 80
ENTRYPOINT []
CMD ["supervisord", "-n"]
