--- Add scenario support

alter table flowpath_points add scenario int references scenarios(id);
alter table flowpaths add scenario int references scenarios(id);
alter table results add scenario int references scenarios(id);
alter table results_by_huc12 add scenario int references scenarios(id);

update flowpath_points set scenario = 0;
update flowpaths set scenario = 0;
update results set scenario = 0;
update results_by_huc12 set scenario = 0;