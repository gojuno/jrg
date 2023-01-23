-- Extract all polygons with a building tag to a buildings table.

drop table if exists geocoder_buildings;

create table geocoder_buildings as
select osm_id, coalesce("name", "addr:housename") as name,
    "addr:street" as street, "addr:housenumber" as housenumber,
    coalesce("addr:postcode", postal_code) as postcode,
    way as geom, ST_Centroid(way) as center, way_area as area,
    "name:" as name_extra, null::hstore as street_extra
from geocoder_polygon
where building is not null;

-- Sometimes centroid is outside a building
update geocoder_buildings
set center = ST_PointOnSurface(geom)
where not ST_Intersects(geom, center);

-- Fill addr:street where empty
update geocoder_buildings building set (street, street_extra) = (
    select name, name_extra from geocoder_roads road
    where ST_DWithin(road.way, building.geom, 200)
    order by road.way <-> building.geom limit 1
)
where housenumber is not null and street is null;

-- Create indices for geospatial joins and id lookups
create index on geocoder_buildings using gist (geom);
create index on geocoder_buildings (osm_id);
