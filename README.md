# Juno Reverse Geocoder

This is a set of SQL scripts working on a PostGIS database that for a given
location return a structured address: from a house number up to a country.
Together this makes for a reverse geocoder, which Juno Inc. uses internally.

## Installation

Starting it should be simple:

* Install PostgreSQL, PostGIS, and osm2pgsql.
* Create a `geocoder` database in PostgreSQL.
* Do `create extension postgis` on the database.
* Download an OpenStreetMap extract for your area.
* Run `run.sh <file.osm.pbf>` to upload the area into the database and start the geocoder.

### Docker container

Check docker container [section](./docker/README.md)

## Usage

The REST API is generally compatible with
[Nominatim's](https://nominatim.org/release-docs/develop/api/Reverse/).
No details or language modifiers work. Only `jsonv2` format
is supported (no need to specify it). Coordinates and identifiers
are output as strings.

Sample call:

    http://localhost:5000/reverse?lon=-73.80401&lat=40.97230

Sample response:

```json
{
    "address": {
        "country": "United States",
        "state": "New York",
        "county": "Westchester County",
        "locality": "Eastchester",
        "town": "Town of Eastchester",
        "postcode": "10583",
        "road": "White Plains Road",
        "house_number": "750"
    },
    "lat": "40.972219900389",
    "lon": "-73.8037561",
    "name": "Lord and Taylor",
    "display_name": "750 White Plains Road",
    "osm_id": 3111837409,
    "osm_type": "node",
    "type": "poi"
}
```

Note that non-address tags are dropped, and the only information that remains
is whether a point is a POI or not. The `type` can be one of `admin`, `road`,
`building`, `address`, or `poi`.

### Error Messages

When there is an error in URL arguments (e.g. non-numeric coordinate or `osm_id`),
you'll get HTTP 400 with a json containing a single `"message"` key.

When an object has not been found, you'll get HTTP 404 with a json containing a single
`"error"` key.

Server errors obviously lead to HTTP 500 errors, although these should not happen.

## Contributing

The reverse geocoder is basically two sets of SQL scripts inside the `sql` directory:
one for preprocessing an osm2pgsql database (`sql/prepare`) and another for
doing queries (`sql/query`). If you aim to improve the quality, go there.

Other scripts and files are merely interfaces to use and access a database with
these scripts. They should just work.

Tests reside in the `tests` directory and are written with
[behave](https://behave.readthedocs.io/en/latest/). Look into `tests/features` to get
human-readable test cases. Feel free to add tests if you think they should cover
more cases. Have a look at tests marked `@wip`: maybe you'll have an idea how to
update SQL scripts to accomodate these.

At the moment tests rely on actual OpenStreetMap data
which might be not great, since OSM is being constantly improved, so some of these
cases would get simpler with time. A good task would be to extract data for each of
these tests into a separate osm.pbf file and make the testing framework install
a separate instance of a database.

## Author and License

The geocoder was written by Ilya Zverev for Juno, published under the Apache 2.0 License.
