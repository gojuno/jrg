create or replace function geocode_admin_ml(lon numeric, lat numeric) returns table (
    type text,
    name json,
    osm_type text,
    osm_id bigint,
    lon double precision,
    lat double precision
) as $$

select type, geocode_ml(name, name_extra), osm_type, osm_id,
       ST_X(ST_Transform(center, 4326)) as lon,
       ST_Y(ST_Transform(center, 4326)) as lat
from geocoder_admin
where ST_Intersects(geom,
    ST_Transform(ST_SetSRID(ST_MakePoint(lon, lat), 4326), 3857))
order by arank;

$$ language sql stable strict parallel safe;
