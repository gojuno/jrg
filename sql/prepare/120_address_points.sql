-- Extract all points with addresses to an addresses table.

drop table if exists geocoder_addresses;

create table geocoder_addresses as
select osm_id, 'node' as osm_type,
    coalesce("name", "addr:housename") as name,
    "addr:street" as street, "addr:housenumber" as housenumber,
    way as geom, null::bigint as building_id,
    (shop is not null or amenity is not null or tourism is not null or
     historic is not null or office is not null or craft is not null or
     leisure is not null) as is_poi
from geocoder_point
where "addr:housenumber" is not null;


-- Match points with enclosing buildings
update geocoder_addresses point set building_id = (
    select building.osm_id
    from geocoder_buildings building
    where ST_Intersects(building.geom, point.geom)
    order by building.area limit 1
);
