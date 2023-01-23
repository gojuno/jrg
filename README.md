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

Sample call (without language):

    http://localhost:5000/reverse?lat=50.2537&lon=7.0099

Sample multilanguage response:

```json
{
    "type": "building",
    "osm_type": "way",
    "osm_id": 499933205,
    "address": {
        "road": {
            "def": "Kirchstra\u00dfe"
        },
        "house_number": "2a",
        "country": {
            "de": "Deutschland",
            "en": "Germany",
            "es": "Alemania",
            "fr": "Allemagne",
            "pl": "Niemcy",
        },
        "state": {
            "de": "Rheinland-Pfalz",
            "en": "Rhineland-Palatinate",
            "es": "Renania-Palatinado",
            "fr": "Rh\u00e9nanie-Palatinat",
            "prefix": "Bundesland"
        },
        "county": {
            "def": "Landkreis Vulkaneifel"
        },
        "village": {
            "def": "Uersfeld"
        },
        "township": {
            "def": "Kelberg",
            "prefix": "Verbandsgemeinde"
        },
        "municipality": {
            "def": "Uersfeld"
        }
    },
    "lon": "7.0097705",
    "lat": "50.25373089939598",
    "name": {},
    "display_name": "2a Kirchstra\u00dfe"
}
```

Call with language:

    http://localhost:5000/reverse?lat=50.2537&lon=7.00996&lang=en"
    
```json
{
    "type": "building",
    "osm_type": "way",
    "osm_id": 499933205,
    "address": {
        "road": "Kirchstra\u00dfe",
        "house_number": "2a",
        "country": "Germany",
        "state": "Rhineland-Palatinate",
        "county": "Landkreis Vulkaneifel",
        "village": "Uersfeld",
        "township": "Kelberg",
        "municipality": "Uersfeld"
    },
    "lon": "7.0097705",
    "lat": "50.25373089939598",
    "display_name": "2a Kirchstra\u00dfe"
}
```

Response will be translated to the desired language (if the translation exists in the source OSM files).

WARNING: for use this feature you need to re-load the OSM into the database. This version is not compatible with the old DB.


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
