CREATE EXTENSION postgis;

-- bandaid
insert into spatial_ref_sys select 9311, 'EPSG', 9311, srtext, proj4text from spatial_ref_sys where srid = 2163;

-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
    version int,
    updated timestamptz);
INSERT into iem_schema_manager_version values (5, now());

---
--- Store grid point geometries
---
CREATE TABLE grid(
  idx int UNIQUE,
  gridx int,
  gridy int,
  geom geometry(Point, 4326)
  );
  CREATE index grid_idx on grid(idx);
 GRANT SELECT on grid to nobody;
 
 ---
 --- Lookup table of observation events
 ---
 CREATE TABLE obtimes(
   valid timestamp with time zone UNIQUE
 );
 GRANT SELECT on obtimes to nobody;
 
 ---
 --- Store the actual data, will have partitioned tables
 --- 
 CREATE TABLE data(
   grid_idx int REFERENCES grid(idx),
   valid timestamp with time zone,
   soil_moisture real,
   optical_depth real
 ) PARTITION by range(valid);
 ALTER TABLE data OWNER to mesonet;
 GRANT ALL on data to ldm;
 GRANT SELECT on data to nobody;
 
 do
$do$
declare
     year int;
     month int;
     mytable varchar;
begin
    for year in 2010..2030
    loop
        for month in 1..12
        loop
            mytable := format($f$data_%s_%s$f$,
                year, lpad(month::text, 2, '0'));
            execute format($f$
                create table %s partition of data
                for values from ('%s-%s-01 00:00+00') to ('%s-%s-01 00:00+00')
                $f$, mytable,
                year, month,
                case when month = 12 then year + 1 else year end,
                case when month = 12 then 1 else month + 1 end);
            execute format($f$
                ALTER TABLE %s OWNER to mesonet
            $f$, mytable);
            execute format($f$
                GRANT ALL on %s to ldm
            $f$, mytable);
            execute format($f$
                GRANT SELECT on %s to nobody
            $f$, mytable);
            execute format($f$
                CREATE INDEX %s_grid_idx on %s(grid_idx)
            $f$, mytable, mytable);
            execute format($f$
                CREATE INDEX %s_valid_idx on %s(valid)
            $f$, mytable, mytable);
        end loop;
    end loop;
end;
$do$;
