create or replace function geocode_translate(name text, name_extra hstore, lang text) returns text as $$
  select case when lang is null then name
              when lang = '' then name
              when name_extra is null then name
              when name_extra->lang is not null then name_extra->lang
              when name_extra->'en' is not null then name_extra->'en'
              else name
       end;
$$ language sql 
  called on null input 
  immutable
  parallel safe;
