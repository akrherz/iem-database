CREATE TABLE cwa(
  gid int,
  wfo varchar,
  cwa varchar,
  lon numeric,
  lat numeric,
  the_geom geometry(MultiPolygon, 4326),
  avg_county_size real,
  region varchar(2)
);
ALTER TABLE cwa OWNER to mesonet;
GRANT ALL on cwa to ldm;
GRANT SELECT on cwa to nobody,apache;

