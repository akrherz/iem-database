-- Storage of DEP Climate Files

create table climate_files(
    id serial primary key,
    scenario int references scenarios(id),
    filepath text,
    geom geometry(Point,4326)
);
alter table climate_files owner to mesonet;
grant select on climate_files to nobody;

-- use this for flowpaths
alter table flowpaths add climate_file_id int references climate_files(id);

-- use for logging requests
alter table clifile_requests
    add climate_file_id int references climate_files(id);

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
