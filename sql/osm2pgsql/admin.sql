create or replace function geocode_admin(lon numeric, lat numeric) returns table (
    type text,
    "name" text,
    osm_type text,
    osm_id bigint,
    lon double precision,
    lat double precision
) as $$

with source as (
    select ST_Transform(ST_SetSRID(ST_MakePoint(lon, lat), 4326), 3857) as pt

), nj_tmp as (
    select ST_Transform(ST_GeomFromEWKT('SRID=4326;POLYGON((-74.62188 41.32938, -73.89541 40.99233, -73.95652 40.83303, -74.01489 40.75818, -74.04098 40.65720, -74.14157 40.64157, -74.18346 40.64652, -74.20269 40.63063, -74.21298 40.55998, -74.24526 40.55450, -74.26071 40.49187, -73.91052 40.48978, -74.23187 39.42346, -75.01464 40.73060, -74.62188 41.32938))'), 3857) as nj

), enclosing as (
    select * from geocoder_polygon, source where ST_Intersects(way, pt)
), admins as (
    (
        -- Country or USA by default
        (select 'way' as osm_type, osm_id, "name", 'country' as type, way
        from enclosing where admin_level = '2' order by way_area desc)
        union all
        select 'relation', 0, 'United States', 'country', null
        limit 1
    )
    union all
    (
        -- State or NY/NJ by default
        (select 'way' as osm_type, osm_id, "name", 'state' as type, way
        from enclosing where admin_level = '4' order by way_area desc)
        union all
        select 'relation', 0, case when ST_Intersects(nj, pt) then 'New Jersey' else 'New York' end, 'state', null
        from nj_tmp, source
        limit 1
    )
    union all
    (
        -- Smaller administrative units
        select 'way' as osm_type, osm_id, "name", case
            when admin_level = '5' then 'state_district'
            when admin_level = '6' then 'county'
            when admin_level = '7' then 'township'
            when admin_level = '8' then 'municipality'
            else 'level' || admin_level
        end as type, way
        from enclosing
        where boundary = 'administrative' and admin_level in ('6', '7', '8', '9')
        order by way_area desc
    )
    union all
    (
        -- City or town or smaller place
        (
            -- As a polygon
            select 'way' as osm_type, osm_id, "name", place, way
            from enclosing
            where place in ('city', 'town', 'village', 'hamlet')
            order by way_area
            limit 1
        )
        union all
        (
            -- From the closest point
            -- TODO: this query is effectively disabled by distance;
            -- need to calculate proper distances based on place type
            select 'node' as osm_type, osm_id, "name", place, ST_Buffer(way, 100)
            from geocoder_point, source
            where ST_DWithin(way, pt, 10)
            and place in ('city', 'town', 'village', 'hamlet')
            limit 1
        )
        limit 1
    )
    union all
    (
        -- Suburb
        (
            -- As a polygon
            select 'way' as osm_type, osm_id, "name", place, way
            from enclosing
            where place = 'suburb'
            order by way_area
            limit 1
        )
        union all
        (
            -- From the closest point
            with enclosing_city as (
                -- Either a city or a smaller administrative area, since suburb boundaries rarely cross administrative boundaries
                select way as city from enclosing
                where place in ('city', 'town', 'village') or (boundary = 'administrative' and admin_level in ('6', '7'))
                order by way_area limit 1
            )
            select 'node' as osm_type, osm_id, "name", place, way
            from geocoder_point cross join source left join enclosing_city on ST_Intersects(city, way)
            where place = 'suburb' and (city is not null or ST_DWithin(way, pt, 10000))
            order by city nulls last, way <-> pt limit 1
        )
        limit 1
    )
    union all
    (
        -- Neighbourhood
        (
            -- As a polygon
            select 'way' as osm_type, osm_id, "name", 'neighbourhood', way
            from enclosing
            where place = 'neighbourhood' or (boundary = 'administrative' and admin_level = '10')
            order by way_area
            limit 1
        )
        union all
        (
            -- From the closest point
            with enclosing_city as (
                select way as city from enclosing
                where place in ('city', 'town', 'village') or (boundary = 'administrative' and admin_level in ('6', '7', '8', '9', '10'))
                order by way_area limit 1
            )
            select 'node' as osm_type, osm_id, "name", place, way
            from geocoder_point cross join source left join enclosing_city on ST_Intersects(city, way)
            where place = 'neighbourhood' and (city is not null or ST_DWithin(way, pt, 2000))
            order by city nulls last, way <-> pt limit 1
        )
        limit 1
    )
)
select type, "name",
    case when osm_id < 0 then 'relation' else osm_type end as osm_type, abs(osm_id),
    ST_X(ST_Transform(ST_PointOnSurface(way), 4326)),
    ST_Y(ST_Transform(ST_PointOnSurface(way), 4326))
from admins;

$$ language sql stable strict parallel safe;
