-- Extract all points with addresses to an addresses table.

drop table if exists geocoder_addresses;

create table geocoder_addresses as
select osm_id, 'node' as osm_type,
    coalesce("name", "addr:housename") as name,
    "addr:street" as street, "addr:housenumber" as housenumber,
    coalesce("addr:postcode", postal_code) as postcode,
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


-- Move postal codes from buildings to enclosed points
update geocoder_addresses set postcode = (
    -- limit 1 if for multipoligonal cases like -6846284
    -- for such cases postcode duplicates for each way in relation so we can pick any
    -- but for cases when postcode can be specified at ways I add ordering
    select postcode from geocoder_buildings where osm_id = building_id
    order by postcode nulls last limit 1
)
where building_id is not null and postcode is null;
