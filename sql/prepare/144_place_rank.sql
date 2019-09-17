-- Calculate type and rank for each object in the admin table.

update geocoder_admin
set type = case
    when place is not null then place
    when admin_level = '2' then 'country'
    when admin_level = '4' then 'state'
    when admin_level = '5' then 'state_district'
    when admin_level = '6' then 'county'
    when admin_level = '7' then 'township'
    when admin_level = '8' then 'municipality'
    when admin_level = '10' then 'neighbourhood'
    when admin_level is not null then 'level' || admin_level
    else null
end, arank = case
    when admin_level in ('2', '3', '4', '5', '6', '7', '8', '9', '10') then 10 * (admin_level::integer)
    when place = 'city' then 55
    when place = 'town' then 65
    when place = 'village' then 67
    when place = 'hamlet' then 68
    when place = 'locality' then 69
    when place = 'suburb' then 75
    when place = 'neighbourhood' then 105
end;

alter table geocoder_admin drop column admin_level, drop column place;

create index on geocoder_admin using gist (geom);
create index on geocoder_admin (osm_id);
