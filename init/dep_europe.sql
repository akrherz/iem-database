-- Daily Erosion Project Europe
CREATE EXTENSION postgis;

-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
    "version" int,
    updated timestamptz
);
ALTER TABLE iem_schema_manager_version OWNER to mesonet;
insert into iem_schema_manager_version values (-1, now());

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

-- Default entry that is used for testing.
insert into scenarios values (0, 'Production', 0, 0, 0);
insert into scenarios values (-1, 'Testing', 0, 0, 0);
