-- For address points without a street, get the name from the roads table.

update geocoder_addresses point set (street, street_extra) = (
    select name, name_extra from geocoder_roads road
    where ST_DWithin(road.way, point.geom, 200)
    order by road.way <-> point.geom limit 1
)
where street is null;
