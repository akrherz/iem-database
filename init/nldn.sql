CREATE EXTENSION postgis;

-- bandaid
INSERT INTO spatial_ref_sys
SELECT
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
INSERT INTO iem_schema_manager_version VALUES (-1, now());

-- Storage of NLDN data, in monthly partitions!
CREATE TABLE nldn_all (
    valid timestamptz,
    geom GEOMETRY (POINT, 4326),
    signal real,
    multiplicity smallint,
    axis smallint,
    eccentricity smallint,
    ellipse smallint,
    chisqr smallint
) PARTITION BY RANGE (valid);
GRANT ALL ON nldn_all TO mesonet, ldm;
GRANT SELECT ON nldn_all TO nobody;
CREATE INDEX ON nldn_all (valid);

DO
$do$
declare
     year int;
begin
    for year in 2016..2030
    loop
        for month in 1..12
        loop
            execute format($f$
                create table nldn%s_%s partition of nldn_all
                for values from ('%s-%s-01 00:00+00') to ('%s-%s-01 00:00+00')
            $f$, year, lpad(month::text, 2, '0'), year, month,
            case when month = 12 then year + 1 else year end,
            case when month = 12 then 1 else month + 1 end);
            execute format($f$
                GRANT ALL on nldn%s_%s to mesonet,ldm
            $f$, year, lpad(month::text, 2, '0'));
            execute format($f$
                GRANT SELECT on nldn%s_%s to nobody
            $f$, year, lpad(month::text, 2, '0'));
        end loop;
    end loop;
end;
$do$;
