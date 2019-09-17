# Old osm2pgsql Scripts

Here lie old, unmaintained scripts that work on an unmodified osm2pgsql database.
They require some indices (see `000_indices.sql`), but besides these — nothing.
You can even do minutely updates to the database.

The drawback is that the speed is low, ~5 requests per second. Maybe more, depends
on your luck, area served and the hardware.

## Maintenance

These scripts were published for demonstration purposes. They miss at least two
months of improvements done to the production scripts, and sure can be improved
to work faster and produce better results. We, as in Juno employees, will not do that.
We are fine with a non-live preprocessed database we have now, for it enables
better searching and higher speeds.

Pull requests to these scripts will be reviewed solely on their performance
in tests and compatibility to the current web API. So first you would need to
bring them to the same interface the current scripts have, so that they can
replace all other sql scripts and work on the rendering database, providing
the same API and serving the same tests as the master version.

## Author and License

Written by Ilya Zverev for Juno Lab, published under an Apache 2.0 License.
