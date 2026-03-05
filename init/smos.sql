CREATE EXTENSION postgis;

-- bandaid
INSERT INTO spatial_ref_sys SELECT
    9311 AS srid,
    'EPSG' AS auth_name,
    9311 AS auth_srid,
    srtext,
    proj4text
FROM spatial_ref_sys
WHERE srid = 2163;

-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version (
    version int,
    updated timestamptz
);
INSERT INTO iem_schema_manager_version VALUES (5, now());

---
--- Store grid point geometries
---
CREATE TABLE grid (
    idx int UNIQUE,
    gridx int,
    gridy int,
    geom GEOMETRY (POINT, 4326)
);
ALTER TABLE grid OWNER TO mesonet;
CREATE INDEX grid_idx ON grid (idx);
GRANT SELECT ON grid TO nobody;

---
--- Lookup table of observation events
---
CREATE TABLE obtimes (
    valid timestamp with time zone UNIQUE
);
ALTER TABLE obtimes OWNER TO mesonet;
GRANT SELECT ON obtimes TO nobody;

---
--- Store the actual data, will have partitioned tables
--- 
CREATE TABLE data (
    grid_idx int REFERENCES grid (idx),
    valid timestamp with time zone,
    soil_moisture real,
    optical_depth real
) PARTITION BY RANGE (valid);
ALTER TABLE data OWNER TO mesonet;
GRANT ALL ON data TO ldm;
GRANT SELECT ON data TO nobody;

DO
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
