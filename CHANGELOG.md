# Juno Reverse Geocoder Changelog

## 1.0.1 (2020-03-13)

* Updated documentation to reflect the
  [password policy change](https://github.com/docker-library/postgres/issues/681)
  in the upstream postgres image.
* Fixed possible issue with PostgreSQL not started before using it.

## 1.0.0 (2019-11-20)

The first public release. Differences from the initially published version:

* Docker image.
* Postal codes in response.
* Integration tests were converted to stand-alone unit tests.
* 88 tests for counties in and around New York state.
* Testing via GitHub actions.
