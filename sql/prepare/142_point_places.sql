-- Convert place nodes to polygons using context, and add these to the admin table.

-- 0. For places with place points inside them, add these points as centers
update geocoder_admin admin
set center = point.way
from geocoder_point point
where ST_Intersects(admin.geom, point.way)
and admin.place = point.place
and admin.name = point.name;


-- 1. Collect places with no polygons, group by "place" tag and enclosing county (admin_level=6).
create temporary table place_polygons_tmp as
with place_nodes as (
    -- First selecting all place nodes that do not have outer place polygons
    select place, way from geocoder_point node
    where not exists (
        select * from geocoder_polygon place_poly
        where ST_Intersects(place_poly.way, node.way)
        and place_poly.place = node.place
    )
    and place in ('city', 'town', 'village', 'hamlet', 'locality', 'suburb', 'neighbourhood')
), nodes_with_enclosing as (
    -- Adding to these enclosing admin polygons
    select node.place, node.way, coalesce(e6.way, e4.way, ST_Buffer(node.way, 20000, 1)) as enclosing
    from place_nodes node
    left join geocoder_polygon e6 on ST_Intersects(e6.way, node.way) and e6.admin_level = '6'
    left join geocoder_polygon e4 on ST_Intersects(e4.way, node.way) and e4.admin_level = '4'
)
-- 2. Build voronoi polygons for each group and assign "place" tag to these for matching.
select place, null::bigint as osm_id,
    -- a. Collecting all points with similar place=* tag inside each of the enclosing polygon.
    -- b. Building voronoi polygons for these groups separately -> GeometryCollections.
    --    If there is a single point, use the enclosing geometry instead.
    -- c. Splitting GeometryCollections into separate polygons.
    -- d. Intersecting each polygon with the corresponding enclosing polygon to cut these.
    -- e. After intersection we might get a MultiPolygon: splitting these again into polygons.
    -- f. The resulting polygons (place, null as osm_id, geom) go into table place_polygons_tmp.
    (ST_Dump(ST_Intersection(enclosing,
        (ST_Dump(case when count(way) > 1 then ST_VoronoiPolygons(ST_Collect(way), 10, enclosing) else enclosing end)).geom
    ))).geom as geom
from nodes_with_enclosing
group by place, enclosing;


-- 3. Subtract from these polygons existing polygons with the same "place" tag.
update place_polygons_tmp tmp
    set geom = coalesce(ST_Difference(geom, (
        select ST_Union(way) from geocoder_polygon poly
        where ST_Intersects(poly.way, tmp.geom)
        and poly.place = tmp.place
    )), geom)
where exists (
    select 1 from geocoder_polygon poly
    where ST_Intersects(geom, way) and poly.place = tmp.place
);


-- 4. Find place points inside each polygon and copy tags from them, adding the result to the geocoder_admin table.
update place_polygons_tmp poly
set osm_id = (
    select osm_id from geocoder_point node
    where poly.place = node.place and ST_Intersects(poly.geom, node.way)
    limit 1
);


-- 4.1. We would need to query this table by osm_id later.
create index on geocoder_point (osm_id);


-- 5. Limit these polygons to a buffer radius dependent on the "place" tag.
-- It was CTE but due to pg12 CTE materialized behavior and backward uncompatible
-- materialized statemnt we rewrote in to temporary table
create temporary table place_sizes as (
-- Calculating 80% percentile median place sizes for buffer values
select place,
    round(percentile_cont(0.8) within group (order by ST_MaxDistance(way, way)) / 2) as radius
from geocoder_polygon
where place in ('city', 'town', 'village', 'hamlet', 'locality', 'suburb', 'neighbourhood')
group by place
);

update place_polygons_tmp poly
set geom = ST_Intersection(geom, ST_Buffer(
        (select way from geocoder_point node where node.osm_id = poly.osm_id),
        (select radius from place_sizes where place_sizes.place = poly.place),
        4
    ));


-- 6. Limit suburbs and neighbourhoods to a bigger place (should be mapped as a polygon).
delete from place_polygons_tmp tmp
where place in ('suburb', 'neighbourhood')
and not exists (
    -- first deleting suburbs that are not inside a city
    select 1 from geocoder_polygon place_poly
    where ST_Intersects(tmp.geom, place_poly.way)
    and place_poly.place in ('city', 'town', 'village', 'locality')
);

update place_polygons_tmp tmp
set geom = ST_Intersection(geom, (
    -- then intersecting suburbs with containing cities boundaries
    select way from geocoder_polygon place_poly
    where ST_Intersects(tmp.geom, place_poly.way)
    -- in case polygon intersects multiple cities, choose the one the center lies in
    and ST_Contains(place_poly.way, (select node.way from geocoder_point node where node.osm_id = tmp.osm_id))
    and place_poly.place in ('city', 'town', 'village', 'locality')
    order by way_area desc limit 1
))  -- null is okay, we filter these later
where place in ('suburb', 'neighbourhood');


-- 7. Simplify stray GeometryCollections of different geometries
update place_polygons_tmp
set geom = ST_CollectionExtract(geom, 3)  -- "3" means Polygon
where ST_GeometryType(geom) = 'ST_GeometryCollection';


-- 8. Copy the result to the geocoder_admin table.
insert into geocoder_admin (osm_type, osm_id, name, name_extra, geom, center, place)
select 'node', poly.osm_id, node.name, node."name:", poly.geom, node.way, poly.place
from place_polygons_tmp poly inner join geocoder_point node using (osm_id)
where geom is not null and osm_id is not null;
