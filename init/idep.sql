-- NOTE: The provenance of the schema was not clean, thus the upgrade scripts
-- are generally all now empty.
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
ALTER TABLE iem_schema_manager_version OWNER TO mesonet;
INSERT INTO iem_schema_manager_version VALUES (36, now());

-- Storage of DEP versioning dailyerosion/dep#179
CREATE TABLE dep_version (
    label text UNIQUE NOT NULL,
    wepp text NOT NULL,
    acpf text NOT NULL,
    flowpath text NOT NULL,
    gssurgo text NOT NULL,
    software text NOT NULL,
    tillage text NOT NULL
);
ALTER TABLE dep_version OWNER TO mesonet;
GRANT SELECT ON dep_version TO nobody;
CREATE UNIQUE INDEX dep_version_idx
ON dep_version (label, wepp, acpf, flowpath, gssurgo, software);

CREATE TABLE scenarios (
    id int UNIQUE,
    label varchar,
    climate_scenario int,
    huc12_scenario int,
    flowpath_scenario int,
    dep_version_label text
);
GRANT SELECT ON scenarios TO nobody;
ALTER TABLE scenarios OWNER TO mesonet;

-- Storage of DEP Climate Files
CREATE TABLE climate_files (
    id serial PRIMARY KEY,
    scenario int REFERENCES scenarios (id),
    filepath text,
    geom GEOMETRY (POINT, 4326)
);
ALTER TABLE climate_files OWNER TO mesonet;
GRANT SELECT ON climate_files TO nobody;

-- storage of yearly summaries
CREATE TABLE climate_file_yearly_summary (
    climate_file_id int REFERENCES climate_files (id),
    year int,
    rfactor real,
    rfactor_storms int
);
CREATE INDEX climate_file_yearly_summary_climate_file_id_idx
ON climate_file_yearly_summary (climate_file_id);
ALTER TABLE climate_file_yearly_summary OWNER TO mesonet;
GRANT SELECT ON climate_file_yearly_summary TO nobody;

-- Log clifile requests
CREATE TABLE clifile_requests (
    valid timestamptz DEFAULT now(),
    climate_file_id int REFERENCES climate_files (id),
    client_addr text,
    geom GEOMETRY (POINT, 4326),
    distance_degrees float
);
ALTER TABLE clifile_requests OWNER TO mesonet;
GRANT INSERT ON clifile_requests TO nobody;

-- GSSURGO Metadata
CREATE TABLE gssurgo (
    id serial UNIQUE NOT NULL,
    fiscal_year int,
    mukey int,
    label text,
    kwfact real,
    hydrogroup varchar(8),
    plastic_limit real,
    wepp_min_sw real,
    wepp_max_sw real,
    wepp_min_sw1 real,
    wepp_max_sw1 real,
    textureclass text
);
ALTER TABLE gssurgo OWNER TO mesonet;
GRANT SELECT ON gssurgo TO nobody;
CREATE INDEX gssurgo_idx ON gssurgo (id);
CREATE UNIQUE INDEX gssurgo_mukey_idx ON gssurgo (fiscal_year, mukey);


-- Default entry that is used for testing.
INSERT INTO scenarios VALUES (0, 'Production', 0, 0, 0);
INSERT INTO scenarios VALUES (-1, 'Testing', 0, 0, 0);

CREATE TABLE huc12 (
    huc_12 varchar(12),
    name text,
    states text,
    geom GEOMETRY (MULTIPOLYGON, 5070),
    simple_geom GEOMETRY (POLYGON, 5070),
    scenario int REFERENCES scenarios (id),
    ugc char(6),
    mlra_id smallint,
    dominant_tillage smallint,
    average_slope_ratio real
);
ALTER TABLE huc12 OWNER TO mesonet;
CREATE UNIQUE INDEX huc12_idx ON huc12 (huc_12, scenario);
GRANT SELECT ON huc12 TO nobody;

---
--- Storage of raw results, temp table, more-or-less
---
CREATE TABLE results (
    huc_12 varchar(12),
    scenario int REFERENCES scenarios (id),
    hs_id int,
    valid date,
    runoff real,
    loss real,
    precip real,
    delivery real
);
ALTER TABLE results OWNER TO mesonet;
CREATE INDEX results_valid_idx ON results (valid);
CREATE INDEX results_huc_12_idx ON results (huc_12);

-- Wind Erosion
CREATE TABLE wind_results_by_huc12 (
    huc_12 char(12),
    scenario int REFERENCES scenarios (id),
    valid date,
    avg_loss real
);
ALTER TABLE wind_results_by_huc12 OWNER TO mesonet;
GRANT SELECT ON wind_results_by_huc12 TO nobody;
CREATE INDEX wind_results_by_huc12_huc_12_idx ON wind_results_by_huc12 (huc_12);
CREATE INDEX wind_results_by_huc12_valid_idx ON wind_results_by_huc12 (valid);

---
--- Storage of huc12 level results
---
CREATE TABLE results_by_huc12 (
    huc_12 varchar(12),
    scenario int REFERENCES scenarios (id),
    valid date,
    min_precip real,
    avg_precip real,
    max_precip real,
    min_loss real,
    avg_loss real,
    max_loss real,
    ve_loss real,
    min_runoff real,
    avg_runoff real,
    max_runoff real,
    ve_runoff real,
    min_delivery real,
    avg_delivery real,
    max_delivery real,
    qc_precip real
) PARTITION BY RANGE (scenario);
ALTER TABLE results_by_huc12 OWNER TO mesonet;
CREATE INDEX results_by_huc12_huc_12_idx ON results_by_huc12 (huc_12);
CREATE INDEX results_by_huc12_valid_idx ON results_by_huc12 (valid);
GRANT SELECT ON results_by_huc12 TO nobody;

CREATE TABLE results_by_huc12_neg PARTITION OF results_by_huc12 FOR VALUES FROM (
    -1000
) TO (0);
GRANT SELECT ON results_by_huc12_neg TO nobody;
ALTER TABLE results_by_huc12_neg OWNER TO mesonet;


CREATE TABLE results_by_huc12_0 PARTITION OF results_by_huc12 FOR VALUES FROM (
    0
) TO (1);
GRANT SELECT ON results_by_huc12_0 TO nobody;
ALTER TABLE results_by_huc12_0 OWNER TO mesonet;

CREATE TABLE results_by_huc12_1_1000 PARTITION OF results_by_huc12 FOR VALUES FROM (
    1
) TO (1000);
CREATE INDEX results_by_huc12_1_1000_scenario_idx ON results_by_huc12_1_1000 (
    scenario
);
GRANT SELECT ON results_by_huc12_1_1000 TO nobody;
ALTER TABLE results_by_huc12_1_1000 OWNER TO mesonet;

CREATE TABLE results_by_huc12_1000_2000 PARTITION OF results_by_huc12 FOR VALUES FROM (
    1000
) TO (2000);
CREATE INDEX results_by_huc12_1000_2000_scenario_idx ON results_by_huc12_1000_2000 (
    scenario
);
GRANT SELECT ON results_by_huc12_1000_2000 TO nobody;
ALTER TABLE results_by_huc12_1000_2000 OWNER TO mesonet;

CREATE TABLE flowpaths (
    fid serial UNIQUE,
    scenario int REFERENCES scenarios (id),
    huc_12 char(12),
    fpath int,
    climate_file_id int REFERENCES climate_files (id),
    geom GEOMETRY (LINESTRING, 5070),
    bulk_slope real,
    max_slope real,
    irrigated boolean DEFAULT false,
    ofe_count smallint,
    real_length real
);
ALTER TABLE flowpaths OWNER TO mesonet;
CREATE INDEX flowpaths_huc12_fpath_idx ON flowpaths (huc_12, fpath);
GRANT SELECT ON flowpaths TO nobody;
CREATE INDEX flowpaths_idx ON flowpaths USING gist (geom);

--
-- genlu column in flowpath_points
--
CREATE TABLE general_landuse (
    id smallint NOT NULL,
    label text NOT NULL
);
CREATE UNIQUE INDEX general_landuse_idx ON general_landuse (id);
ALTER TABLE general_landuse OWNER TO mesonet;
GRANT SELECT ON general_landuse TO nobody;

--- Store Properties used by website and scripts
CREATE TABLE properties (
    key varchar UNIQUE NOT NULL,
    value varchar
);
ALTER TABLE properties OWNER TO mesonet;
GRANT SELECT ON properties TO nobody;

-- Storage of harvest information
CREATE TABLE harvest (
    valid date,
    huc12 char(12),
    fpath smallint,
    ofe smallint,
    scenario smallint REFERENCES scenarios (id),
    crop varchar(32),
    yield_kgm2 real
);
CREATE INDEX harvest_huc12_idx ON harvest (huc12);
CREATE INDEX harvest_valid_idx ON harvest (valid);
ALTER TABLE harvest OWNER TO mesonet;
GRANT SELECT ON harvest TO nobody;

--
-- Field Boundaries
CREATE TABLE fields (
    field_id serial UNIQUE,
    scenario smallint REFERENCES scenarios (id),
    huc12 char(12),
    fbndid int,
    acres real,
    geom GEOMETRY (MULTIPOLYGON, 5070),
    landuse varchar(32),
    management varchar(32),
    genlu smallint REFERENCES general_landuse (id) NOT NULL,
    man_2017_2022 char(6),
    residue2017 smallint,
    residue2018 smallint,
    residue2019 smallint,
    residue2020 smallint,
    residue2021 smallint,
    residue2022 smallint,
    isag int
);
ALTER TABLE fields OWNER TO mesonet;
GRANT SELECT ON fields TO nobody;
CREATE INDEX fields_huc12_idx ON fields (huc12);
CREATE INDEX fields_geom_idx ON fields USING gist (geom);

-- Storage of wind results by field
CREATE TABLE field_wind_erosion_results (
    field_id int REFERENCES fields (field_id),
    scenario int REFERENCES scenarios (id),
    valid date,
    erosion_kgm2 real,
    avg_wmps real,
    max_wmps real,
    drct real
) PARTITION BY RANGE (valid);
ALTER TABLE field_wind_erosion_results OWNER TO mesonet;
GRANT SELECT ON field_wind_erosion_results TO nobody;
CREATE INDEX field_wind_erosion_results_valid_idx
ON field_wind_erosion_results (valid);
CREATE INDEX field_wind_erosion_results_field_idx
ON field_wind_erosion_results (field_id);

DO
$do$
declare
     year int;
begin
    for year in 2007..2030
    loop
        execute format($f$
            create table field_wind_erosion_results_%s partition of field_wind_erosion_results
            for values from ('%s-01-01') to ('%s-01-01')
            $f$, year, year, year + 1);
        execute format($f$
            alter table field_wind_erosion_results_%s owner to mesonet
        $f$, year);
        execute format($f$
            grant select on field_wind_erosion_results_%s to nobody
        $f$, year);
    end loop;
end;
$do$;


-- Store of Flowpath OFE information
CREATE TABLE flowpath_ofes (
    flowpath int REFERENCES flowpaths (fid),
    field_id int REFERENCES fields (field_id) NOT NULL,
    ofe smallint NOT NULL,
    geom GEOMETRY (LINESTRINGZ, 5070),
    bulk_slope real,
    max_slope real,
    fbndid int,
    management varchar(32),
    landuse varchar(32),
    gssurgo_id int REFERENCES gssurgo (id),
    real_length real,
    groupid text
);
ALTER TABLE flowpath_ofes OWNER TO mesonet;
GRANT SELECT ON flowpath_ofes TO nobody;
CREATE INDEX ON flowpath_ofes (field_id);
CREATE INDEX flowpath_ofes_idx ON flowpath_ofes (flowpath);

--
-- Dates of tillage and planting operations
CREATE TABLE field_operations (
    field_id int REFERENCES fields (field_id),
    year int,
    till1 date,
    till2 date,
    till3 date,
    plant date
);
ALTER TABLE field_operations OWNER TO mesonet;
GRANT SELECT ON field_operations TO nobody;
CREATE INDEX field_operations_idx ON field_operations (field_id);
