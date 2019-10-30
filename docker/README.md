Juno Reverse Geocoder docker image
==================================

This file describes how to build and use JRG image

Building image
--------------

```
docker build ./ -t jrg --no-cache
```

Image with mounted volume usage
-----------

If you will mound postgres data as docker volume:

1. Create volume for geodata.

```
docker volume create pgdata
```

2. Convert OSM file to geocoder format

```
docker run -t -v "/local/path/to/osm/data/dir:/data" -v "pgdata:/pgdata" jrg /init.sh /data/your_extract.osm.pbf
```

3. Run container to serve geocoder requests

```
docker run -v "pgdata:/pgdata" -d -p 8080:80 jrg
```
