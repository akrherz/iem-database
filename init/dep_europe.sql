-- Daily Erosion Project Europe
CREATE EXTENSION postgis;

-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version (
    version int,
    updated timestamptz
);
ALTER TABLE iem_schema_manager_version OWNER TO mesonet;
INSERT INTO iem_schema_manager_version VALUES (-1, now());

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


CREATE TABLE scenarios (
    scenario_id int UNIQUE,
    label varchar,
    climate_scenario int,
    huc12_scenario int,
    flowpath_scenario int,
    dep_version_label text
);
GRANT SELECT ON scenarios TO nobody;
ALTER TABLE scenarios OWNER TO mesonet;

-- Storage of DEP Climate Files
CREATE TABLE climate_file (
    climate_file_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    scenario_id int REFERENCES scenario (scenario_id) NOT NULL,
    filepath text NOT NULL,
    geom GEOMETRY (POINT, 4326)
);
ALTER TABLE climate_file OWNER TO mesonet;
GRANT SELECT ON climate_file TO nobody;
CREATE UNIQUE INDEX ON climate_file (scenario_id, filepath);

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

-- Log clifile requests
CREATE TABLE clifile_requests (
    valid timestamptz DEFAULT now(),
    climate_file_id int REFERENCES climate_file (climate_file_id),
    client_addr text,
    geom GEOMETRY (POINT, 4326),
    distance_degrees float
);
ALTER TABLE clifile_requests OWNER TO mesonet;
GRANT INSERT ON clifile_requests TO nobody;

-- Default entry that is used for testing.
INSERT INTO scenarios VALUES (0, 'Production', 0, 0, 0);
INSERT INTO scenarios VALUES (-1, 'Testing', 0, 0, 0);
