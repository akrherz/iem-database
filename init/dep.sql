-- NOTE: On 22 Jun 2026, the legacy `idep` database was forklifted to this
-- schema.
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
INSERT INTO iem_schema_manager_version VALUES (0, now());

-- Storage of DEP versioning dailyerosion/dep#179
CREATE TABLE dep_version (
    label text PRIMARY KEY,
    wepp text NOT NULL,
    acpf text NOT NULL,
    flowpath text NOT NULL,
    gssurgo text NOT NULL,
    software text NOT NULL,
    tillage text NOT NULL
);
ALTER TABLE dep_version OWNER TO mesonet;
GRANT SELECT ON dep_version TO nobody;

-- Just some placeholder stuff
INSERT INTO dep_version VALUES
('20260612', '20260612', '20260612', '20260612', '20260612', '20260612', '20260612');

-- The scenario id is fully controlled
CREATE TABLE scenario (
    scenario_id int PRIMARY KEY,
    label varchar,
    climate_scenario int,
    huc12_scenario int,
    flowpath_scenario int,
    dep_version_label text REFERENCES dep_version (label)
);
GRANT SELECT ON scenario TO nobody;
ALTER TABLE scenario OWNER TO mesonet;

-- Default entry that is used for testing.
INSERT INTO scenario VALUES (0, 'Production', 0, 0, 0, '20260612');
INSERT INTO scenario VALUES (-1, 'Testing', 0, 0, 0, '20260612');


-- Storage of DEP Climate Files
CREATE TABLE climate_file (
    climate_file_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    scenario_id int REFERENCES scenario (scenario_id),
    filepath text,
    geom GEOMETRY (POINT, 4326)
);
ALTER TABLE climate_file OWNER TO mesonet;
GRANT SELECT ON climate_file TO nobody;

-- storage of yearly summaries
CREATE TABLE climate_file_yearly_summary (
    climate_file_id int REFERENCES climate_file (climate_file_id),
    year int,
    rfactor real,
    rfactor_storms int
);
CREATE UNIQUE INDEX ON climate_file_yearly_summary (climate_file_id, year);
ALTER TABLE climate_file_yearly_summary OWNER TO mesonet;
GRANT SELECT ON climate_file_yearly_summary TO nobody;

-- Log climate file requests
CREATE TABLE climate_file_requests (
    valid timestamptz DEFAULT now(),
    climate_file_id int REFERENCES climate_file (climate_file_id),
    client_addr inet,
    geom GEOMETRY (POINT, 4326),
    distance_degrees float
);
ALTER TABLE climate_file_requests OWNER TO mesonet;
GRANT INSERT ON climate_file_requests TO nobody;

-- GSSURGO Metadata
CREATE TABLE gssurgo (
    gssurgo_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fiscal_year int NOT NULL,
    mukey int NOT NULL,
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
CREATE UNIQUE INDEX gssurgo_mukey_idx ON gssurgo (fiscal_year, mukey);

CREATE TABLE huc12 (
    huc12_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    huc12_code char(12) NOT NULL,
    name text,
    states text,
    geom GEOMETRY (MULTIPOLYGON, 5070),
    simple_geom GEOMETRY (POLYGON, 5070),
    scenario_id int REFERENCES scenario (scenario_id),
    ugc char(6),
    mlra_id smallint,
    dominant_tillage smallint,
    avg_slope_ratio real
);
ALTER TABLE huc12 OWNER TO mesonet;
CREATE UNIQUE INDEX huc12_idx ON huc12 (huc12_code, scenario_id);
GRANT SELECT ON huc12 TO nobody;

-- Wind Erosion
CREATE TABLE wind_results_by_huc12 (
    huc12_id int REFERENCES huc12 (huc12_id) NOT NULL,
    scenario_id int REFERENCES scenario (scenario_id) NOT NULL,
    valid date NOT NULL,
    avg_loss real
);
ALTER TABLE wind_results_by_huc12 OWNER TO mesonet;
GRANT SELECT ON wind_results_by_huc12 TO nobody;
CREATE INDEX ON wind_results_by_huc12 (huc12_id);
CREATE INDEX ON wind_results_by_huc12 (valid);

---
--- Storage of huc12 level results
---
CREATE TABLE water_results_by_huc12 (
    huc12_id int REFERENCES huc12 (huc12_id) NOT NULL,
    scenario_id int REFERENCES scenario (scenario_id) NOT NULL,
    valid date NOT NULL,
    min_precip_mm real,
    avg_precip_mm real,
    max_precip_mm real,
    min_loss_kgm2 real,
    avg_loss_kgm2 real,
    max_loss_kgm2 real,
    min_runoff_mm real,
    avg_runoff_mm real,
    max_runoff_mm real,
    min_delivery_mm real,
    avg_delivery_mm real,
    max_delivery_mm real,
    qc_precip_mm real
) PARTITION BY RANGE (scenario_id);
ALTER TABLE water_results_by_huc12 OWNER TO mesonet;
CREATE INDEX ON water_results_by_huc12 (huc12_id);
CREATE INDEX ON water_results_by_huc12 (valid);
GRANT SELECT ON water_results_by_huc12 TO nobody;

CREATE TABLE water_results_by_huc12_neg PARTITION OF water_results_by_huc12 FOR VALUES FROM (
    -1000
) TO (0);
GRANT SELECT ON water_results_by_huc12_neg TO nobody;
ALTER TABLE water_results_by_huc12_neg OWNER TO mesonet;


CREATE TABLE water_results_by_huc12_0 PARTITION OF water_results_by_huc12 FOR VALUES FROM (
    0
) TO (1);
GRANT SELECT ON water_results_by_huc12_0 TO nobody;
ALTER TABLE water_results_by_huc12_0 OWNER TO mesonet;

CREATE TABLE water_results_by_huc12_1_1000 PARTITION OF water_results_by_huc12 FOR VALUES FROM (
    1
) TO (1000);
CREATE INDEX ON water_results_by_huc12_1_1000 (scenario_id);
GRANT SELECT ON water_results_by_huc12_1_1000 TO nobody;
ALTER TABLE water_results_by_huc12_1_1000 OWNER TO mesonet;

CREATE TABLE water_results_by_huc12_1000_2000 PARTITION OF water_results_by_huc12 FOR VALUES FROM (
    1000
) TO (2000);
CREATE INDEX ON water_results_by_huc12_1000_2000 (scenario_id);
GRANT SELECT ON water_results_by_huc12_1000_2000 TO nobody;
ALTER TABLE water_results_by_huc12_1000_2000 OWNER TO mesonet;

CREATE TABLE flowpath (
    flowpath_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    scenario_id int REFERENCES scenario (scenario_id),
    huc12_id int REFERENCES huc12 (huc12_id),
    huc12_fpath_num int NOT NULL,
    climate_file_id int REFERENCES climate_file (climate_file_id),
    geom GEOMETRY (LINESTRING, 5070),
    avg_slope_ratio real,
    max_slope_ratio real,
    irrigated boolean DEFAULT false,
    length_m real
);
ALTER TABLE flowpath OWNER TO mesonet;
CREATE UNIQUE INDEX ON flowpath (huc12_id, huc12_fpath_num);
GRANT SELECT ON flowpath TO nobody;
CREATE INDEX flowpath_idx ON flowpath USING gist (geom);

--
CREATE TABLE general_landuse (
    general_landuse_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    label text NOT NULL
);
ALTER TABLE general_landuse OWNER TO mesonet;
GRANT SELECT ON general_landuse TO nobody;

--- Store Properties used by website and scripts
CREATE TABLE properties (
    key varchar UNIQUE NOT NULL,
    value varchar
);
ALTER TABLE properties OWNER TO mesonet;
GRANT SELECT ON properties TO nobody;

--
-- Field Boundaries
CREATE TABLE field (
    field_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    scenario_id int REFERENCES scenario (scenario_id),
    huc12_id int REFERENCES huc12 (huc12_id),
    huc12_fbndid_num int NOT NULL,
    acres real,
    geom GEOMETRY (MULTIPOLYGON, 5070),
    landuse varchar(32),
    management varchar(32),
    general_landuse_id int REFERENCES general_landuse (general_landuse_id) NOT NULL,
    management_2017_2022 char(6),
    agriculture_code smallint
);
ALTER TABLE field OWNER TO mesonet;
GRANT SELECT ON field TO nobody;
CREATE INDEX ON field (huc12_id);
CREATE INDEX field_geom_idx ON field USING gist (geom);

-- Storage of computed residue values
CREATE TABLE field_residue (
    field_id int REFERENCES field (field_id),
    scenario_id int REFERENCES scenario (scenario_id),
    year int NOT NULL,
    residue_percent smallint
);
CREATE UNIQUE INDEX ON field_residue (field_id, scenario_id, year);
ALTER TABLE field_residue OWNER TO mesonet;
GRANT SELECT ON field_residue TO nobody;

-- Storage of wind results by field
CREATE TABLE field_wind_erosion_results (
    field_id int REFERENCES field (field_id),
    scenario_id int REFERENCES scenario (scenario_id),
    valid date NOT NULL,
    erosion_kgm2 real,
    avg_wind_speed_mps real,
    max_wind_speed_mps real,
    drct real
) PARTITION BY RANGE (valid);
ALTER TABLE field_wind_erosion_results OWNER TO mesonet;
GRANT SELECT ON field_wind_erosion_results TO nobody;
CREATE INDEX ON field_wind_erosion_results (valid);
CREATE INDEX ON field_wind_erosion_results (field_id);

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
CREATE TABLE flowpath_ofe (
    flowpath_ofe_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    flowpath_id int REFERENCES flowpath (flowpath_id) NOT NULL,
    field_id int REFERENCES field (field_id) NOT NULL,
    ofe smallint NOT NULL CHECK (ofe > 0),
    geom GEOMETRY (LINESTRINGZ, 5070),
    avg_slope_ratio real,
    max_slope_ratio real,
    gssurgo_id int REFERENCES gssurgo (gssurgo_id),
    length_m real,
    groupid text
);
COMMENT ON COLUMN flowpath_ofe.ofe IS 'WEPP Overland Flow Element (starts at 1).';
ALTER TABLE flowpath_ofe OWNER TO mesonet;
GRANT SELECT ON flowpath_ofe TO nobody;
CREATE INDEX ON flowpath_ofe (field_id);
CREATE INDEX flowpath_ofe_idx ON flowpath_ofe (flowpath_id);

--
-- Dates of tillage and planting operations
CREATE TABLE field_operations (
    field_id int REFERENCES field (field_id) NOT NULL,
    year int NOT NULL,
    till1 date,
    till2 date,
    till3 date,
    plant date
);
ALTER TABLE field_operations OWNER TO mesonet;
GRANT SELECT ON field_operations TO nobody;
CREATE UNIQUE INDEX ON field_operations (field_id, year);
