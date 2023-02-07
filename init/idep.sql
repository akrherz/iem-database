-- NOTE: The provenance of the schema was not clean, thus the upgrade scripts
-- are generally all now empty.
CREATE EXTENSION postgis;

-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
	version int,
	updated timestamptz);
ALTER TABLE iem_schema_manager_version OWNER to mesonet;
INSERT into iem_schema_manager_version values (26, now());

-- GSSURGO Metadata
CREATE TABLE gssurgo(
    id serial UNIQUE NOT NULL,
    fiscal_year int,
    mukey int,
    label text,
    kwfact real,
    hydrogroup varchar(8)
);
ALTER TABLE gssurgo OWNER to mesonet;
GRANT SELECT on gssurgo to nobody;
CREATE INDEX gssurgo_idx on gssurgo(id);
CREATE UNIQUE INDEX gssurgo_mukey_idx on gssurgo(fiscal_year, mukey);

create table scenarios(
    id int UNIQUE,
    label varchar,
    climate_scenario int,
    huc12_scenario int,
    flowpath_scenario int
    );
GRANT SELECT on scenarios to nobody;
ALTER TABLE scenarios OWNER to mesonet;

-- Default entry that is used for testing.
insert into scenarios values (0, 'Production', 0, 0, 0);
insert into scenarios values (-1, 'Testing', 0, 0, 0);

CREATE TABLE huc12(
    huc_12 varchar(12),
    name text,
    states text,
    geom geometry(MultiPolygon, 5070),
    simple_geom geometry(Polygon, 5070),
    scenario int REFERENCES scenarios(id),
    ugc char(6),
    mlra_id smallint,
    dominant_tillage smallint
);
CREATE UNIQUE INDEX huc12_idx on huc12(huc_12, scenario);
GRANT SELECT on huc12 to nobody;

---
--- Storage of raw results, temp table, more-or-less
---
CREATE TABLE results(
  huc_12 varchar(12),
  scenario int references scenarios(id),
  hs_id int,
  valid date,
  runoff real,
  loss real,
  precip real,
  delivery real
);
CREATE INDEX results_valid_idx on results(valid);
CREATE INDEX results_huc_12_idx on results(huc_12);

---
--- Storage of huc12 level results
---
CREATE TABLE results_by_huc12(
  huc_12 varchar(12),
  scenario int references scenarios(id),
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
);
CREATE INDEX results_by_huc12_huc_12_idx on results_by_huc12(huc_12);
CREATE INDEX results_by_huc12_valid_idx on results_by_huc12(valid);

GRANT SELECT on results_by_huc12 to nobody;

CREATE TABLE flowpaths(
  fid serial UNIQUE,
  scenario int references scenarios(id),
  huc_12 char(12),
  fpath int,
  climate_file varchar(128),
  geom geometry(LINESTRING, 5070),
  bulk_slope real,
  max_slope real,
  irrigated boolean DEFAULT false,
  ofe_count smallint,
  real_length real
);
ALTER TABLE flowpaths OWNER to mesonet;
create index flowpaths_huc12_fpath_idx on flowpaths(huc_12,fpath);
GRANT SELECT on flowpaths to nobody;
CREATE INDEX flowpaths_idx on flowpaths USING GIST(geom);

--
-- genlu column in flowpath_points
--
CREATE TABLE general_landuse(
    id smallint,
    label text
);
CREATE UNIQUE index general_landuse_idx on general_landuse(id);
ALTER TABLE general_landuse OWNER to mesonet;
GRANT SELECT on general_landuse to nobody;

-- Store of Flowpath OFE information
CREATE TABLE flowpath_ofes(
    flowpath int REFERENCES flowpaths(fid),
    ofe smallint not null,
    geom geometry(LineString, 5070),
    bulk_slope real,
    max_slope real,
    fbndid int,
    management varchar(32),
    landuse varchar(32),
    gssurgo_id int REFERENCES gssurgo(id),
    genlu smallint references general_landuse(id),
    real_length real
);
ALTER TABLE flowpath_ofes OWNER to mesonet;
GRANT SELECT on flowpath_ofes to nobody;
CREATE INDEX flowpath_ofes_idx on flowpath_ofes(flowpath);

---
--- Raw Points on each flowpath
---
CREATE  TABLE flowpath_points(
  flowpath int references flowpaths(fid),
  segid int,
  elevation real,
  length real,
  slope real,
  geom geometry(POINT, 5070),
  gridorder smallint,
  ofe smallint,
  gssurgo_id int references gssurgo(id)
);
create index flowpath_points_flowpath_idx on flowpath_points(flowpath);
GRANT SELECT on flowpath_points to nobody;

--- Store Properties used by website and scripts
CREATE TABLE properties(
  key varchar UNIQUE NOT NULL,
  value varchar
);
GRANT SELECT on properties to nobody;

-- Storage of harvest information
CREATE TABLE harvest(
  valid date,
  huc12 char(12),
  fpath smallint,
  ofe smallint,
  scenario smallint REFERENCES scenarios(id),
  crop varchar(32),
  yield_kgm2 real
);
CREATE INDEX harvest_huc12_idx on harvest(huc12);
CREATE INDEX harvest_valid_idx on harvest(valid);
GRANT ALL on harvest to ldm,mesonet;
GRANT SELECT on harvest to nobody;

--
-- Field Boundaries
CREATE TABLE fields(
    field_id SERIAL UNIQUE,
    scenario smallint REFERENCES scenarios(id),
    huc12 char(12),
    fbndid int,
    acres real,
    isag bool,
    geom geometry(Polygon, 5070)
);
ALTER TABLE fields OWNER to mesonet;
GRANT SELECT on fields to nobody;
CREATE INDEX fields_huc12_idx on fields(huc12);
CREATE INDEX fields_geom_idx on fields USING GIST(geom);
