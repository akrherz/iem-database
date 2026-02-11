-- NOTE: The provenance of the schema was not clean, thus the upgrade scripts
-- are generally all now empty.
CREATE EXTENSION postgis;

-- bandaid
insert into spatial_ref_sys
select 9311 as srid, 'EPSG' as auth_name, 9311 as auth_srid, srtext, proj4text
from spatial_ref_sys
where srid = 2163;

-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
    "version" int,
    updated timestamptz
);
ALTER TABLE iem_schema_manager_version OWNER to mesonet;
insert into iem_schema_manager_version values (36, now());

-- Storage of DEP versioning dailyerosion/dep#179
create table dep_version(
    label text unique not null,
    wepp text not null,
    acpf text not null,
    flowpath text not null,
    gssurgo text not null,
    software text not null,
    tillage text not null
);
alter table dep_version owner to mesonet;
grant select on dep_version to nobody;
create unique index dep_version_idx
on dep_version(label, wepp, acpf, flowpath, gssurgo, software);

create table scenarios(
    id int UNIQUE,
    label varchar,
    climate_scenario int,
    huc12_scenario int,
    flowpath_scenario int,
    dep_version_label text
);
GRANT SELECT on scenarios to nobody;
ALTER TABLE scenarios OWNER to mesonet;

-- Storage of DEP Climate Files
create table climate_files(
    id serial primary key,
    scenario int references scenarios(id),
    filepath text,
    geom geometry(Point,4326)
);
alter table climate_files owner to mesonet;
grant select on climate_files to nobody;

-- storage of yearly summaries
create table climate_file_yearly_summary(
    climate_file_id int references climate_files(id),
    "year" int,
    rfactor real,
    rfactor_storms int
);
create index climate_file_yearly_summary_climate_file_id_idx
    on climate_file_yearly_summary(climate_file_id);
alter table climate_file_yearly_summary owner to mesonet;
grant select on climate_file_yearly_summary to nobody;

-- Log clifile requests
create table clifile_requests(
    "valid" timestamptz default now(),
    climate_file_id int references climate_files(id),
    client_addr text,
    geom geometry(Point, 4326),
    distance_degrees float
);
alter table clifile_requests owner to mesonet;
grant insert on clifile_requests to nobody;

-- GSSURGO Metadata
CREATE TABLE gssurgo(
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
ALTER TABLE gssurgo OWNER to mesonet;
GRANT SELECT on gssurgo to nobody;
CREATE INDEX gssurgo_idx on gssurgo(id);
CREATE UNIQUE INDEX gssurgo_mukey_idx on gssurgo(fiscal_year, mukey);


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
    dominant_tillage smallint,
    average_slope_ratio real
);
alter table huc12 owner to mesonet;
CREATE UNIQUE INDEX huc12_idx on huc12(huc_12, scenario);
GRANT SELECT on huc12 to nobody;

---
--- Storage of raw results, temp table, more-or-less
---
CREATE TABLE results(
    huc_12 varchar(12),
    scenario int references scenarios(id),
    hs_id int,
    "valid" date,
    runoff real,
    loss real,
    precip real,
    delivery real
);
alter table results owner to mesonet;
CREATE INDEX results_valid_idx on results(valid);
CREATE INDEX results_huc_12_idx on results(huc_12);

-- Wind Erosion
CREATE TABLE wind_results_by_huc12(
    huc_12 char(12),
    scenario int references scenarios(id),
    "valid" date,
    avg_loss real
);
ALTER TABLE wind_results_by_huc12 OWNER to mesonet;
GRANT SELECT on wind_results_by_huc12 to nobody;
CREATE INDEX wind_results_by_huc12_huc_12_idx on wind_results_by_huc12(huc_12);
CREATE INDEX wind_results_by_huc12_valid_idx on wind_results_by_huc12(valid);

---
--- Storage of huc12 level results
---
CREATE TABLE results_by_huc12(
    huc_12 varchar(12),
    scenario int references scenarios(id),
    "valid" date,
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
) partition by range(scenario);
alter table results_by_huc12 owner to mesonet;
CREATE INDEX results_by_huc12_huc_12_idx on results_by_huc12(huc_12);
CREATE INDEX results_by_huc12_valid_idx on results_by_huc12(valid);
GRANT SELECT on results_by_huc12 to nobody;

create table results_by_huc12_neg partition of results_by_huc12 for values from (-1000) to (0);
grant select on results_by_huc12_neg to nobody;
alter table results_by_huc12_neg owner to mesonet;


create table results_by_huc12_0 partition of results_by_huc12 for values from (0) to (1);
grant select on results_by_huc12_0 to nobody;
alter table results_by_huc12_0 owner to mesonet;

create table results_by_huc12_1_1000 partition of results_by_huc12 for values from (1) to (1000);
create index results_by_huc12_1_1000_scenario_idx on results_by_huc12_1_1000(scenario);
grant select on results_by_huc12_1_1000 to nobody;
alter table results_by_huc12_1_1000 owner to mesonet;

create table results_by_huc12_1000_2000 partition of results_by_huc12 for values from (1000) to (2000);
create index results_by_huc12_1000_2000_scenario_idx on results_by_huc12_1000_2000(scenario);
grant select on results_by_huc12_1000_2000 to nobody;
alter table results_by_huc12_1000_2000 owner to mesonet;

CREATE TABLE flowpaths(
    fid serial UNIQUE,
    scenario int references scenarios(id),
    huc_12 char(12),
    fpath int,
    climate_file_id int references climate_files(id),
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
    id smallint not null,
    label text not null
);
CREATE UNIQUE index general_landuse_idx on general_landuse(id);
ALTER TABLE general_landuse OWNER to mesonet;
GRANT SELECT on general_landuse to nobody;

--- Store Properties used by website and scripts
CREATE TABLE properties(
    "key" varchar UNIQUE NOT NULL,
    "value" varchar
);
alter table properties owner to mesonet;
GRANT SELECT on properties to nobody;

-- Storage of harvest information
CREATE TABLE harvest(
    "valid" date,
    huc12 char(12),
    fpath smallint,
    ofe smallint,
    scenario smallint REFERENCES scenarios(id),
    crop varchar(32),
    yield_kgm2 real
);
CREATE INDEX harvest_huc12_idx on harvest(huc12);
CREATE INDEX harvest_valid_idx on harvest(valid);
alter table harvest owner to mesonet;
GRANT SELECT on harvest to nobody;

--
-- Field Boundaries
CREATE TABLE fields(
    field_id SERIAL UNIQUE,
    scenario smallint REFERENCES scenarios(id),
    huc12 char(12),
    fbndid int,
    acres real,
    geom geometry(MultiPolygon, 5070),
    landuse varchar(32),
    management varchar(32),
    genlu smallint references general_landuse(id) not null,
    man_2017_2022 char(6),
    residue2017 smallint,
    residue2018 smallint,
    residue2019 smallint,
    residue2020 smallint,
    residue2021 smallint,
    residue2022 smallint,
    isag int
);
ALTER TABLE fields OWNER to mesonet;
GRANT SELECT on fields to nobody;
CREATE INDEX fields_huc12_idx on fields(huc12);
CREATE INDEX fields_geom_idx on fields USING GIST(geom);

-- Storage of wind results by field
create table field_wind_erosion_results(
    field_id int references fields(field_id),
    scenario int references scenarios(id),
    "valid" date,
    erosion_kgm2 real,
    avg_wmps real,
    max_wmps real,
    drct real
) partition by range(valid);
alter table field_wind_erosion_results owner to mesonet;
grant select on field_wind_erosion_results to nobody;
create index field_wind_erosion_results_valid_idx
   on field_wind_erosion_results(valid);
create index field_wind_erosion_results_field_idx
   on field_wind_erosion_results(field_id);

do
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
CREATE TABLE flowpath_ofes(
    flowpath int REFERENCES flowpaths(fid),
    field_id int REFERENCES fields(field_id) not null,
    ofe smallint not null,
    geom geometry(LineStringZ, 5070),
    bulk_slope real,
    max_slope real,
    fbndid int,
    management varchar(32),
    landuse varchar(32),
    gssurgo_id int REFERENCES gssurgo(id),
    real_length real,
    groupid text
);
ALTER TABLE flowpath_ofes OWNER to mesonet;
GRANT SELECT on flowpath_ofes to nobody;
CREATE INDEX on flowpath_ofes(field_id);
CREATE INDEX flowpath_ofes_idx on flowpath_ofes(flowpath);

--
-- Dates of tillage and planting operations
create table field_operations(
    field_id int REFERENCES fields(field_id),
    "year" int,
    till1 date,
    till2 date,
    till3 date,
    plant date
);
alter table field_operations owner to mesonet;
grant select on field_operations to nobody;
create index field_operations_idx on field_operations(field_id);
