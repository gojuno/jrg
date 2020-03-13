# Juno Reverse Geocoder docker image

This file describes how to build and use JRG image

## Building image

    docker build . -t jrg --no-cache

# Image with mounted volume usage

1. Create volume for geodata.

    docker volume create jrg_data

2. Convert OSM file to geocoder format

    docker run --rm -t -v "/local/path/to/osm/data/dir:/data" -v jrg_data:/pgdata -e POSTGRES_PASSWORD=mysecretpassword jrg /init.sh /data/your_extract.osm.pbf

3. Run container to serve geocoder requests

    docker run --rm --name geocoder -v jrg_data:/pgdata -d -p 8080:80 jrg

4. Test that the container works

    curl 'http://localhost:8080/reverse?lon=-73.80401&lat=40.97230'

5. Stop the geocoder when done

    docker stop geocoder
