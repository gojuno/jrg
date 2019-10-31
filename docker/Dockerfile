FROM postgres:12
MAINTAINER Juno Inc <gojuno.com>

# this stage was inspired by https://github.com/appropriate/docker-postgis/blob/master/11-2.5/Dockerfile
# that wasn't maintained any more and we do not need some migration stuff from it

ENV POSTGIS_MAJOR 3
ENV POSTGIS_VERSION 3.0.0+dfsg-2~exp1.pgdg100+1

#TODO switch to versions when we will have they similar with mdillon postgis repo
# https://hub.docker.com/r/mdillon/postgis/dockerfile
ENV GEOCODER_BRANCH master

RUN apt-get update \
      && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
      && apt-get install -y --no-install-recommends \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts=$POSTGIS_VERSION \
           postgis=$POSTGIS_VERSION \
           wget python3 python3-psycopg2 python3-pip python3-setuptools python3-wheel python3-dev build-essential nginx supervisor osm2pgsql\
      && rm -rf /var/lib/apt/lists/* \
      && rm -rf /var/cache/apt/archives/* \
      && wget -O /geocoder.tar.gz https://github.com/gojuno/jrg/tarball/$GEOCODER_BRANCH \
      && mkdir -p /usr/src/jrg/ \
      && mkdir -p /etc/supervisord/conf.d/ \
      && tar xzvf /geocoder.tar.gz --directory /usr/src/jrg --strip-components 1 \
      && rm /geocoder.tar.gz \
      && pip3 install -r /usr/src/jrg/web/requirements.txt \
      && mv /usr/src/jrg/docker/supervisor-geocoder.conf /etc/supervisor/conf.d/ \
      && mv /usr/src/jrg/docker/nginx.conf /etc/nginx/nginx.conf \
      && mv /usr/src/jrg/docker/init.sh /init.sh \
      # Forward nginx logs to supervisord
      && ln -sf /dev/stdout /var/log/nginx/access.log \
      && ln -sf /dev/stderr /var/log/nginx/error.log

# Port 5432 is exposed by inheritance
EXPOSE 80
ENTRYPOINT []
CMD ["supervisord", "-n"]
