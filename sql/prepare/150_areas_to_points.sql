-- Convert non-building areas with addresses to points in the addresses table.

-- 0. Delete buildings and polygons with no addresses from the polygons table
delete from geocoder_polygon
where "addr:housenumber" is null or building is not null;

-- 1. Match areas with biggest non-addressed buildings
alter table geocoder_polygon add column building_id bigint;
update geocoder_polygon poly set building_id = (
    select building.osm_id from geocoder_buildings building
    where ST_Contains(poly.way, building.geom)
    and building.housenumber is null
    order by building.area desc limit 1
);

-- 2. Move addresses to biggest buildings
update geocoder_buildings building
set housenumber = poly."addr:housenumber",
    postcode = coalesce(poly."addr:postcode", postcode),
    street = poly."addr:street"
from geocoder_polygon poly
where building.osm_id = poly.building_id;

-- 3. Convert the rest of the polygons into points
insert into geocoder_addresses
    (osm_id, osm_type, name, street, housenumber, postcode, geom, building_id, is_poi)
select osm_id, 'way',
    coalesce("name", "addr:housename"),
    "addr:street", "addr:housenumber", "addr:postcode",
    ST_PointOnSurface(way), (
        -- Note that here we look for the smallest building that encloses the polygon
        -- where as building_id is the largest building inside the polygon.
        select osm_id from geocoder_buildings building
        where ST_Contains(building.geom, poly.way)
        order by building.area limit 1
    ), true
from geocoder_polygon poly
where building_id is null
    and way_area < 3000; -- ~1775 m², or 30×60 m

-- 4. We don't need the table anymore
drop table geocoder_polygon;

