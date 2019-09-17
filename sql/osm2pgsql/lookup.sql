create or replace function osm_lookup(osmtype text, osmid bigint) returns table (
    type text,
    osm_type text,
    osm_id bigint,
    "addr:street" text,
    "addr:housenumber" text,
    lon double precision,
    lat double precision,
    "name" text,
    geom text
) as $$

select
    'lookup',
    case when osmtype = 'n' then 'node' when osmtype = 'w' then 'way' else 'relation' end,
    coalesce(point.osm_id, line.osm_id, abs(poly.osm_id)),
    coalesce(point."addr:street", line."addr:street", line."name", poly."addr:street"),
    coalesce(point."addr:housenumber", poly."addr:housenumber"),
    ST_X(ST_Transform(ST_PointOnSurface(coalesce(point.way, line.way, poly.way)), 4326)),
    ST_Y(ST_Transform(ST_PointOnSurface(coalesce(point.way, line.way, poly.way)), 4326)),
    coalesce(point."name", point."addr:housename", line."name", poly."name", poly."addr:housename"),
    ST_AsGeoJSON(ST_Transform(ST_Centroid(coalesce(point.way, line.way, poly.way)), 4326))
from
    (select 1 as num) source
    left join geocoder_point point on point.osm_id = case when osmtype = 'n' then osmid else null end
    left join geocoder_line line on line.osm_id = case when osmtype = 'w' then osmid else null end
    left join geocoder_polygon poly on poly.osm_id = case when osmtype = 'w' then osmid when osmtype = 'r' then -osmid else null end

$$ language sql stable strict parallel safe;
