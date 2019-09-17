drop table geocoder_point;

create index on geocoder_addresses using gist (geom);
create index on geocoder_addresses (osm_id);
