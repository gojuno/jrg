create or replace function geocode_poi(lon numeric, lat numeric) returns table (
    type text,
    osm_type text,
    osm_id bigint,
    "addr:street" text,
    "addr:housenumber" text,
    lon double precision,
    lat double precision,
    "name" text,
    distance numeric
) as $$

with source as (
    -- Transform the source point to web mercator and calculate the distance modifier
    select ST_Transform(geom, 3857) as pt, cos(radians(ST_Y(geom))) as cos_mod
    from (select ST_SetSRID(ST_MakePoint(lon, lat), 4326) as geom) g

), buildings as (
    -- The enclosing building
    select osm_id, 'way' as osm_type, way, coalesce("name", "addr:housename") as "name", "addr:street", "addr:housenumber", building
    from (select p.* from geocoder_polygon p, source where ST_Intersects(way, pt)) p
    where building is not null or shop is not null or amenity is not null or highway is not null or leisure is not null
    order by way_area
    limit 1

), anystreet as (
    -- Any street with a name, no matter how far away
    select osm_id, 'way' as osm_type, way, "name", "name" as "addr:street", null as "addr:housenumber"
    from (select * from geocoder_line, source where ST_DWithin(way, pt, 1000 / cos_mod)) p
    where highway in ('residential', 'unclassified', 'tertiary', 'secondary', 'primary', 'trunk', 'motorway')
      and "name" is not null and bridge is null and tunnel is null
    order by way <-> pt
    limit 4

), streets as (
    -- Nearest street with a name
    select s.*, ST_Distance(s.way, pt) * cos_mod as distance from anystreet s, source
    where ST_DWithin(way, pt, 200/cos_mod) order by way <-> pt limit 1

), close_poi as (
    -- Merge points and polygons into a single table, convert polygons to centroids
    select osm_id, 'way' as osm_type,
           case when building is not null then way else ST_Centroid(way) end as way,
           coalesce("name", "addr:housename") as "name", shop, amenity, building,
           coalesce(b_street, "addr:street") as "addr:street",
           coalesce(b_house, "addr:housenumber") as "addr:housenumber"
    from geocoder_polygon p cross join source
    left join lateral (
        select pp."addr:street" as b_street, pp."addr:housenumber" as b_house
        from geocoder_point pp
        where p.building is not null
            and not ST_Contains(p.way, pt)
            and ST_Contains(p.way, pp.way)
            and pp."addr:housenumber" is not null
        order by pp.way <-> pt
        limit 1
    ) pp on true
    where "addr:housenumber" is not null -- only objects with full addresses
        and ST_DWithin(way, pt, 200) -- arbitrary high enough radius

    union all
    -- Specifically address points for buildings
    select b.osm_id, 'way' as osm_type,
           case when s."name" = b."addr:street" then
               coalesce(ST_ClosestPoint(ST_Intersection(b.way, ST_ShortestLine(ST_PointOnSurface(b.way), s.way)), s.way), ST_Centroid(b.way))
               else ST_PointOnSurface(b.way) end as way,
           coalesce(b."name", b."addr:housename") as "name", b.shop, b.amenity, b.building,
           b."addr:street", b."addr:housenumber"
    from geocoder_polygon b cross join source left join anystreet s on s."name" = b."addr:street"
    where b.building is not null
        and b."addr:housenumber" is not null
        and ST_DWithin(b.way, pt, 200)

    union all
    -- All point features
    select osm_id, 'node' as osm_type, way, "name", shop, amenity, null as building,
           "addr:street", "addr:housenumber"
    from geocoder_point, source
    where "addr:housenumber" is not null and ST_DWithin(way, pt, 200)

), pois_tmp as (
    -- Nearest POIs with addresses, including buildings
    select p.*, b.osm_id is not null as inside
    from close_poi p cross join source left join buildings b on true
    where true
      -- Skip the building that encloses the source point, since it will always be the closest
      and (b.osm_id is null or ST_GeometryType(p.way) = 'ST_Point' or p.osm_id is distinct from b.osm_id)
      -- If there is an enclosing building, then the POI should be inside the enclosing building
      and (b.building is null or ((ST_GeometryType(p.way) = 'ST_Point' or p.building is null) and ST_Intersects(b.way, p.way)))
      -- POI should be within 50 (30 for a building when it's not an address point) meters,
      -- but if the enclosing building has no address, then any point inside it (see above) is okay
      and ((b.osm_id is not null and b."addr:housenumber" is null)
          or ST_DWithin(p.way, pt, case when b.building is not null and not (p.amenity is null and p.shop is null) then 30 else 50 end / cos_mod))
    order by p.way <-> pt
    limit 5

), pois as (
    -- Select the closest POI preferring these that match the road name
    (
        select p.* from pois_tmp p cross join source left join streets r on true
        order by ST_Distance(p.way, pt) / (case when p."addr:street" = r."name" and (not inside or r.distance < 30) then 1.5 else 1.0 end)
    )
    union all
    (
        select p.*, false
        from close_poi p cross join source left join buildings b on true
        where b."addr:housenumber" is null
        and ST_DWithin(p.way, pt, 30 / cos_mod)
        order by p.way <-> pt limit 1
    )
    limit 10

), anyclosest as (
    -- If there are no POI and the enclosing building has no address, add any closest object with address
    select p.* from close_poi p, source order by way <-> pt limit 1

), united as (
    -- Priority: POI, then the enclosing building, then the closes road
    select 'poi' as t, osm_id, osm_type, way, "name",
        coalesce("addr:street", (select "name" from streets limit 1)) as "addr:street", "addr:housenumber" from pois
    union all
    select 'bldg' as t, osm_id, osm_type, way, "name", "addr:street", "addr:housenumber" from buildings where "addr:street" is not null
    union all
    select 'road' as t, osm_id, osm_type, way, null as "name", "addr:street", "addr:housenumber" from streets
    union all
    select 'any' as t, osm_id, osm_type, way, "name", "addr:street", "addr:housenumber" from anyclosest
    union all
    select 'far' as t, osm_id, osm_type, way, null as "name", "addr:street", "addr:housenumber" from anystreet
)

select t, case when osm_id < 0 then 'relation' else osm_type end, abs(osm_id),
    "addr:street", "addr:housenumber",
    ST_X(ST_Transform(st_closestpoint(way, pt), 4326)),
    ST_Y(ST_Transform(ST_ClosestPoint(way, pt), 4326)),
    "name", trunc(ST_Distance(way, pt)::numeric * cos_mod::numeric, 2)
from united, source;

$$ language sql stable strict parallel safe;
