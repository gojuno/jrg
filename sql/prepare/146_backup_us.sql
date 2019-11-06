-- Add backup regions for NY, NJ and USA in case the import did not contain the states

do $$
begin
    if not exists (select 1 from geocoder_admin where arank = 20) then
        insert into geocoder_admin (osm_type, osm_id, type, arank, name, geom)
        values (
            'relation', 148838, 'country', 20, 'United States',
            ST_Transform(ST_GeomFromEWKT('SRID=4326;POLYGON((-125.5 28.9, -67.8 28.9, -67.8 43.5, -125.5 43.5, -125.5 28.9))'), 3857)
        );
    end if;

    if not exists (select 1 from geocoder_admin where arank = 40 and name = 'New York') then
        insert into geocoder_admin (osm_type, osm_id, type, arank, name, geom)
        values (
            'relation', 61320, 'state', 40, 'New York',
            ST_Transform(ST_GeomFromEWKT('SRID=4326;POLYGON((-74.338989 40.42395, -73.22113 40.42395, -73.22113 41.584634, -74.338989 41.584634, -74.338989 40.42395))'), 3857)
        ), (
            'relation', 224951, 'state', 40, 'New Jersey',
            ST_Transform(ST_GeomFromEWKT('SRID=4326;POLYGON((-74.62188 41.32938, -73.89541 40.99233, -73.95652 40.83303, -74.01489 40.75818, -74.04098 40.65720, -74.14157 40.64157, -74.18346 40.64652, -74.20269 40.63063, -74.21298 40.55998, -74.24526 40.55450, -74.26071 40.49187, -73.91052 40.48978, -74.23187 39.42346, -75.01464 40.73060, -74.62188 41.32938))'), 3857)
        );
        -- New York state covers NJ, so we cut the latter out
        update geocoder_admin
        set geom = ST_Difference(geom, (select geom from geocoder_admin where osm_id = 224951))
        where osm_id = 61320;
    end if;
end;
$$ language plpgsql;
