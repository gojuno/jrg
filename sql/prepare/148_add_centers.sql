-- Precalculate centers for each polygon in the admin table.

update geocoder_admin
set center = ST_PointOnSurface(geom)
where center is null;
