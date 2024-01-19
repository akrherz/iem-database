alter table rwis_soil_data add updated timestamptz default now();
alter table rwis_soil_data_log add updated timestamptz default now();
alter table rwis_traffic_data add updated timestamptz default now();
alter table rwis_traffic_data_log add updated timestamptz default now();
