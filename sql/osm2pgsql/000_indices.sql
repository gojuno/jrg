drop table geocoder_roads;
delete from geocoder_line where highway is null or "name" is null;
delete from geocoder_point where "addr:housenumber" is null and place is null;
create index on geocoder_point (osm_id);
create index on geocoder_line (osm_id);
create index on geocoder_polygon (osm_id);
create index on geocoder_point (place);
