-- Extract all named lines with highway tags to a roads table.

drop table geocoder_roads;

create table geocoder_roads as
select osm_id, way, name, bridge is not null or tunnel is not null as is_bridge
from geocoder_line
where highway in ('service', 'residential', 'pedestrian', 'unclassified', 'tertiary', 'secondary', 'primary', 'trunk', 'motorway')
      and "name" is not null
union all
-- We need pedestrian squares, which are commonly mapped with a closed way highway=pedestrian
select osm_id, way, name, false as is_bridge
from geocoder_polygon
where highway = 'pedestrian' and name is not null and osm_id > 0;

drop table geocoder_line;

create index on geocoder_roads using gist (way);
create index on geocoder_roads (osm_id);
