-- Extract all polygons with place or admin_level tags to an admin table.

drop table if exists geocoder_admin;

create table geocoder_admin as
select case when osm_id < 0 then 'relation' else 'way' end as osm_type,
    abs(osm_id) as osm_id, name, "name:" as name_extra, way as geom, place,
    null::geometry as center, null::text as type, 10*admin_level::integer as arank
from geocoder_polygon
where (boundary = 'administrative' and admin_level in ('2', '4', '5', '6', '7', '8', '9', '10'))
    or place in ('city', 'town', 'village', 'hamlet', 'locality', 'suburb', 'neighbourhood');


-- Decouple cities from counties
insert into geocoder_admin
select osm_type, osm_id, name, name_extra, geom, null as place, center, type, arank
from geocoder_admin
where place = 'city' and arank in (60, 80);

update geocoder_admin set arank = null
where place = 'city' and arank in (60, 80);
