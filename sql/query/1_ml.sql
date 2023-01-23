create or replace function geocode_ml(name text, name_extra hstore) returns json as $$
begin
  if (name_extra is null) then
    return hstore_to_json(hstore('def', name));
  end if;
  return hstore_to_json(hstore('def', name) || name_extra);
end
$$ language plpgsql 
  called on null input 
  immutable
  parallel safe;
