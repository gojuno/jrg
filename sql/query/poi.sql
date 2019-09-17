create or replace function geocode_poi(pt_lon numeric, pt_lat numeric) returns table (
    -- These column names start with "r" to not interfere with the query
    rtype text,
    rosm_type text,
    rosm_id bigint,
    rstreet text,
    rhousenumber text,
    rlon double precision,
    rlat double precision,
    rname text,
    rdistance numeric
) as $$

DECLARE
    pt geometry;     -- Source point in 3857 projection
    cos_mod numeric; -- Cos(latitude) for converting mercator meters to real meters

BEGIN
    select ST_Transform(geom, 3857), cos(radians(ST_Y(geom)))
    into pt, cos_mod
    from (select ST_SetSRID(ST_MakePoint(pt_lon, pt_lat), 4326) as geom) g;

    return query
    with building as (
        -- The enclosing building
        select 'building' as type, * from geocoder_buildings
        where ST_Intersects(geom, pt)
        order by area limit 1

    ), roads as (
        -- Any street with a name, no matter how far away (up to 1 km)
        select 'road' as type, *, ST_ClosestPoint(way, pt) as closest from geocoder_roads
        where ST_DWithin(way, pt, 1000 / cos_mod)
        order by way <-> pt limit 5

    ), road as (
        -- Nearest street with a name
        select *, ST_Distance(way, pt) * cos_mod as distance from roads
        where ST_DWithin(way, pt, 100/cos_mod) and not is_bridge
        order by way <-> pt limit 1

    ), close_poi as (
        -- Buildings
        select 'building' as type, osm_id, 'way' as osm_type, name, street, housenumber,
               geom, null::bigint as building_id, false as is_poi,
               ST_ClosestPoint(geom, pt) as center,
               ST_Distance(geom, pt) + 1e-6 as distance -- adding 1 cm to prefer address points inside the building
        from geocoder_buildings
        where ST_DWithin(geom, pt, 100/cos_mod)
        and housenumber is not null
        and osm_id is distinct from (select osm_id from building)

        -- POI inside the current building
        union all
        select case when is_poi then 'poi' else 'address' end,
               *, geom, ST_Distance(geom, pt) / 3.0 as distance
        from geocoder_addresses
        where st_dwithin(geom, pt, 100/cos_mod)
        and building_id = (select osm_id from building)

        -- Group POIs inside other buildings, choose one that's closest to the source point
        -- TODO: what about building addresses???
        union all
        (
            select distinct on (building_id)
                case when is_poi then 'poi' else 'address' end,
                point.*, point.geom, ST_Distance(b.geom, pt) as distance
            from geocoder_addresses point
                left join geocoder_buildings b on building_id = b.osm_id
                left join building enclosing on true
                left join road on true
            where ST_DWithin(point.geom, pt, 100/cos_mod)
                and ST_DWithin(b.geom, pt, 50/cos_mod)
                and building_id is not null
                and building_id is distinct from enclosing.osm_id
            order by building_id, (point.geom <-> pt) / (
                case when point.street = road.name and road.distance < 30 then 3.0 else 1.0 end)
        )

        -- Point addresses
        union all
        select case when is_poi then 'poi' else 'address' end,
               *, geom, ST_Distance(geom, pt) as distance
        from geocoder_addresses
        where ST_DWithin(geom, pt, 100/cos_mod)
            and building_id is null

    ), pois_tmp as (
        -- Nearest POIs with addresses, including buildings
        select poi.*, b.osm_id is not null as inside
        from close_poi poi left join building b on true
        where true
          -- If there is an enclosing building, then the POI should be inside the enclosing building
          -- but if the enclosing building has no address, we allow POIs from nearby buildings
          and (b.osm_id is null or b.osm_id is not distinct from poi.building_id or b.housenumber is null)
          -- Limit points in other buildings to 20m distance, to prefer points in the current building
          and (b.osm_id is null or b.osm_id is not distinct from poi.building_id or ST_DWithin(poi.geom, pt, 20 / cos_mod))
          -- POI should be within 50 (30 for a building when it's not an address point) meters,
          -- but if the enclosing building has no address, then any point inside it (see above) is okay
          and ((b.osm_id is not null and b.housenumber is null)
              or ST_DWithin(poi.geom, pt, case when b.osm_id is not null and poi.is_poi then 30 else 50 end / cos_mod))
        order by poi.distance
        limit 9

    ), pois as (
        -- Select the closest POI preferring these that match the road name
        (
            select poi.* from pois_tmp poi left join road on true
            order by poi.distance / (case when poi.street = road.name and (not inside or road.distance < 30) then 1.5 else 1.0 end)
        )
        union all
        (
            -- A backup POI in case we're in a building without an address
            select poi.*, false
            from close_poi poi left join building b on true
            where b.housenumber is null
            and ST_DWithin(poi.geom, pt, 30 / cos_mod)
            order by poi.distance limit 1
        )
        limit 10

    ), anyclosest as (
        -- If there are no POI and the enclosing building has no address, add any closest object with address
        select * from close_poi where distance <= 50 order by distance limit 5

    ), united as (
        -- Priority: POI, then the enclosing building, then the closest road
        select type, osm_id, osm_type, center, name, street, housenumber from pois
        union all
        -- put "pt" instead of "center" to nullify the distance to the enclosing building
        select type, osm_id, 'way', pt, name, street, housenumber from building
        union all
        select type, osm_id, 'way', closest, null, name, null from road
        union all
        select type, osm_id, osm_type, center, name, street, housenumber from anyclosest
        union all
        select type, osm_id, 'way', closest, null, name, null from roads
    )

    select type, case when osm_id < 0 then 'relation' else osm_type end, abs(osm_id),
        street, housenumber,
        ST_X(ST_Transform(center, 4326)),
        ST_Y(ST_Transform(center, 4326)),
        name, trunc(ST_Distance(center, pt)::numeric * cos_mod::numeric, 2)
    from united;

END
$$ language plpgsql stable strict parallel safe;
