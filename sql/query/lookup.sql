create or replace function osm_lookup(osmtype text, osmid bigint) returns table (
    type text,
    osm_type text,
    osm_id bigint,
    street text,
    housenumber text,
    postcode text,
    lon double precision,
    lat double precision,
    name text,
    geom text
) as $$

with fulltype_const as (
    select case when osmtype = 'n' then 'node' when osmtype = 'w' then 'way' else 'relation' end as fulltype
)
select
    case
        when road.osm_id is not null then 'road'
        when admin.osm_id is not null then 'admin'
        when bldg.osm_id is not null then 'building'
        when point.osm_id is not null and point.is_poi then 'poi'
        when point.osm_id is not null and not point.is_poi then 'address'
        else 'lookup'
    end,
    fulltype,
    coalesce(point.osm_id, road.osm_id, abs(bldg.osm_id), admin.osm_id),
    coalesce(point.street, road.name, bldg.street),
    coalesce(point.housenumber, bldg.housenumber),
    coalesce(point.postcode, bldg.postcode),
    ST_X(ST_Transform(ST_PointOnSurface(coalesce(point.geom, road.way, bldg.geom, admin.geom)), 4326)),
    ST_Y(ST_Transform(ST_PointOnSurface(coalesce(point.geom, road.way, bldg.geom, admin.geom)), 4326)),
    coalesce(point.name, bldg.name, road.name, admin.name),
    ST_AsGeoJSON(ST_Transform(ST_Centroid(coalesce(point.geom, road.way, bldg.geom, admin.geom)), 4326))
from
    fulltype_const
    left join geocoder_buildings bldg  on bldg.osm_id = case when osmtype = 'w' then osmid when osmtype = 'r' then -osmid else null end
    left join geocoder_roads road      on road.osm_id = case when osmtype = 'w' then osmid else null end
    left join geocoder_addresses point on point.osm_type = fulltype and point.osm_id = osmid
    left join geocoder_admin admin     on admin.osm_type = fulltype and admin.osm_id = osmid

$$ language sql stable strict parallel safe;
