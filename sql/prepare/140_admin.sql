-- Extract all polygons with place or admin_level tags to an admin table.

drop table if exists geocoder_admin;

create table geocoder_admin as
select case when osm_id < 0 then 'relation' else 'way' end as osm_type,
    abs(osm_id) as osm_id, name, way as geom, place, admin_level,
    null::geometry as center, null::text as type, null::integer as arank
from geocoder_polygon
where (boundary = 'administrative' and admin_level in ('2', '4', '5', '6', '7', '8', '9', '10'))
    or place in ('city', 'town', 'village', 'hamlet', 'locality', 'suburb', 'neighbourhood')
