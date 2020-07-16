-- NOTE: The provenance of the schema was not clean, thus the upgrade scripts
-- are generally all now empty.
CREATE EXTENSION postgis;

CREATE TABLE iem_version(
  name varchar(50) UNIQUE,
  version int);
  
insert into iem_version values ('schema', 21);

create table scenarios(
    id int UNIQUE,
    label varchar,
    climate_scenario int,
    huc12_scenario int,
    flowpath_scenario int
    );
GRANT SELECT on scenarios to nobody,apache;

insert into scenarios(id, label) values (0, 'Production');


CREATE TABLE huc12(
    gid SERIAL,
    huc_8 varchar(8),
    huc_10 varchar(10),
    huc_12 varchar(12),
    acres numeric,
    hu_10_ds varchar(10),
    hu_10_name text,
    hu_10_mod text,
    hu_10_type char(1),
    hu_12_ds varchar(10),
    hu_12_name text,
    hu_12_mod text,
    hu_12_type char(1),
    meta_id varchar(4),
    states text,
    areapctmea real,
    shape_leng numeric,
    shape_area numeric,
    buffdist smallint,
    geom geometry(MultiPolygon, 5070),
    simple_geom geometry(Polygon, 5070),
    scenario int REFERENCES scenarios(id),
    ugc char(6),
    mlra_id smallint
);
CREATE UNIQUE INDEX huc12_idx on huc12(huc_12, scenario);
GRANT SELECT on huc12 to nobody,apache;

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

GRANT SELECT on results_by_huc12 to nobody,apache;

CREATE TABLE flowpaths(
  fid serial UNIQUE,
  scenario int references scenarios(id),
  huc_12 char(12),
  fpath int,
  climate_file varchar(128),
  geom geometry(LINESTRING, 5070),
  bulk_slope real,
  max_slope real
);
create index flowpaths_huc12_fpath_idx on flowpaths(huc_12,fpath);
GRANT SELECT on flowpaths to nobody,apache;
CREATE INDEX flowpaths_idx on flowpaths USING GIST(geom);

---
--- Raw Points on each flowpath
---
CREATE  TABLE flowpath_points(
  flowpath int references flowpaths(fid),
  scenario int references scenarios(id),
  segid int,
  elevation real,
  length real,
  surgo int,
  management varchar(32),
  slope real,
  landuse varchar(32),
  geom geometry(POINT, 5070),
  gridorder smallint
);
create index flowpath_points_flowpath_idx on flowpath_points(flowpath);
GRANT SELECT on flowpath_points to nobody,apache;

---
--- xref of surgo values to soils file
---
CREATE TABLE xref_surgo(
  surgo int,
  soilfile varchar(24)
);
create index xref_surgo_idx on xref_surgo(surgo);

--- Store Properties used by website and scripts
CREATE TABLE properties(
  key varchar UNIQUE NOT NULL,
  value varchar
);
GRANT SELECT on properties to nobody,apache;

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
GRANT SELECT on harvest to nobody,apache;
