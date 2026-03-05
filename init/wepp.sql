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
INSERT INTO iem_schema_manager_version VALUES (5, now());

--- Tables loaded by shp2pgsql
---   + counties
---   + hrap_polygons
---   + hrap_utm
---   + iacounties
---   + iatwp

CREATE TABLE waterbalance (
    run_id bigint,
    valid date,
    vsm real,
    s10cm real,
    s20cm real,
    et real
);
CREATE TABLE waterbalance_by_twp (
    valid date,
    model_twp varchar(10),
    vsm real,
    vsm_stddev real,
    vsm_range real,
    s10cm real,
    s20cm real,
    et real
);

CREATE TABLE soils (
    soil_id int,
    name varchar(100),
    texture varchar(25),
    layers int,
    albedo real,
    sat real,
    interrill real,
    rill real,
    shear real,
    conduct real,
    kfact real,
    kffact real,
    tfact real
);
CREATE UNIQUE INDEX soils_idx ON soils (soil_id);

CREATE TABLE nri (
    id bigint,
    model_twp varchar,
    psu_id int,
    sample int,
    county_id int,
    town_id int,
    range_id int,
    len real,
    steep real,
    soil_id int,
    man_id int,
    ucfact real,
    upfact real,
    soil_depth int,
    slope real
);
CREATE UNIQUE INDEX nri_id_idx ON nri (id);
CREATE INDEX nri_man_id ON nri (man_id);
CREATE INDEX nri_model_twp_idx ON nri (model_twp);
GRANT SELECT ON nri TO nobody;

CREATE TABLE layers (
    soil_id int,
    depth real,
    sand real,
    clay real,
    om real,
    cec real,
    rock real
);

CREATE TABLE managements (
    man_id int UNIQUE,
    name varchar(100)
);

CREATE TABLE mandetails (
    man_id int,
    seq int,
    mon int,
    day int,
    year int,
    op varchar(32),
    type varchar(100),
    comm varchar(64)
);

CREATE TABLE job_queue (
    id serial UNIQUE,
    combo_id int,
    queued timestamptz,
    answered boolean,
    request_id int
);
CREATE INDEX job_combo_queue_id_key ON job_queue (combo_id);

CREATE TABLE erosion_log (
    valid date UNIQUE
);

---
--- Climate Sector wx data
CREATE TABLE climate_sectors (
    sector smallint,
    day date,
    high real DEFAULT 0,
    low real DEFAULT 0,
    rad real DEFAULT 0,
    wvl real DEFAULT 0,
    drct smallint DEFAULT 0,
    dewp real DEFAULT 0
);
CREATE INDEX climate_sectors_idx ON climate_sectors (sector, day);

---
--- Results by township by year
---
CREATE TABLE results_twp_year (
    model_twp varchar(9),
    valid date,
    avg_loss real,
    avg_runoff real,
    min_loss real,
    max_loss real,
    min_runoff real,
    max_runoff real,
    ve_runoff real,
    ve_loss real
);
GRANT SELECT ON results_twp_year TO nobody;

---
--- Results by township by month
---
CREATE TABLE results_twp_month (
    model_twp varchar(9),
    valid date,
    avg_loss real,
    avg_runoff real,
    min_loss real,
    max_loss real,
    min_runoff real,
    max_runoff real,
    ve_runoff real,
    ve_loss real
);
GRANT SELECT ON results_twp_month TO nobody;

---
--- Combinations
---
CREATE TABLE combos (
    id serial UNIQUE,
    nri_id bigint,
    model_twp varchar(9),
    hrap_i int,
    mkrun boolean,
    erosivity_idx real
);
CREATE UNIQUE INDEX combos_idx ON combos (nri_id, model_twp, hrap_i);
CREATE INDEX combos_hrap_i_idx ON combos (hrap_i);
CREATE INDEX combos_model_twp_idx ON combos (model_twp);
CREATE INDEX combos_nri_id_idx ON combos (nri_id);
GRANT SELECT ON combos TO nobody;

---
--- Store run results
---
CREATE TABLE results (
    run_id bigint,
    valid date,
    runoff real,
    loss real,
    precip real
);
CREATE INDEX results_run_id_idx ON results (run_id);
CREATE INDEX results_valid_idx ON results (valid);
GRANT SELECT ON results TO nobody;

---
--- Store Results by Township
---
CREATE TABLE results_by_twp (
    model_twp varchar(9),
    valid date,
    avg_precip real,
    max_precip real,
    min_loss real,
    avg_loss real,
    max_loss real,
    min_runoff real,
    max_runoff real,
    avg_runoff real,
    bogus real,
    run_points int,
    min_precip real,
    ve_runoff real,
    ve_loss real
);
CREATE INDEX results_by_twp_model_twp_idx ON results_by_twp (model_twp);
CREATE INDEX results_by_twp_valid_idx ON results_by_twp (valid);
GRANT SELECT ON results_by_twp TO nobody;

---
--- Rainfall log
---
CREATE TABLE rainfall_log (
    valid date,
    max_rainfall real
);
GRANT SELECT ON rainfall_log TO nobody;

---
--- Yearly Rainfall
---
CREATE TABLE yearly_rainfall (
    hrap_i smallint,
    valid date,
    rainfall real,
    peak_15min real,
    hr_cnt smallint
);
GRANT SELECT ON yearly_rainfall TO nobody;

---
--- Monthly Rainfall
---
CREATE TABLE monthly_rainfall (
    hrap_i smallint,
    valid date,
    rainfall real,
    peak_15min real,
    hr_cnt smallint
) PARTITION BY RANGE (valid);
ALTER TABLE monthly_rainfall OWNER TO mesonet;
GRANT SELECT ON monthly_rainfall TO nobody;


DO
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 1997..2030
    loop
        mytable := format($f$monthly_rainfall_%s$f$,
            year);
        execute format($f$
            create table %s partition of monthly_rainfall
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
            $f$, mytable,
            year, year +1);
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
            CREATE INDEX %s_valid_idx on %s(valid)
        $f$, mytable, mytable);
    end loop;
end;
$do$;

---
--- Daily Rainfall
---
CREATE TABLE daily_rainfall (
    hrap_i smallint,
    valid date,
    rainfall real,
    peak_15min real,
    hr_cnt smallint
) PARTITION BY RANGE (valid);
ALTER TABLE daily_rainfall OWNER TO mesonet;
GRANT SELECT ON daily_rainfall TO nobody;

DO
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 1997..2030
    loop
        mytable := format($f$daily_rainfall_%s$f$,
            year);
        execute format($f$
            create table %s partition of daily_rainfall
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
            $f$, mytable,
            year, year +1);
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
            CREATE INDEX %s_valid_idx on %s(valid)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_hrap_i_idx on %s(hrap_i)
        $f$, mytable, mytable);
    end loop;
end;
$do$;
