-- Calculate type and rank for each object in the admin table.

update geocoder_admin
set type = case
    when place is not null then place
    when arank = 20 then 'country'
    when arank = 40 then 'state'
    when arank = 50 then 'state_district'
    when arank = 60 then 'county'
    when arank = 70 then 'township'
    when arank = 80 then 'municipality'
    when arank = 100 then 'neighbourhood'
    when arank is not null then 'level' || arank::text
    else null
end, arank = coalesce(arank, case
    when place = 'city' then 55
    when place = 'town' then 65
    when place = 'village' then 67
    when place = 'hamlet' then 68
    when place = 'locality' then 69
    when place = 'suburb' then 75
    when place = 'neighbourhood' then 105
end);

alter table geocoder_admin drop column place;

create index on geocoder_admin using gist (geom);
create index on geocoder_admin (osm_id);
