-- akrherz/iem/issues/1359
alter table sensors add iemid int references stations(iemid);
alter table alldata add iemid int references stations(iemid);
create index alldata_iemid_idx on alldata(iemid);
alter table alldata_soil add iemid int references stations(iemid);
create index alldata_soil_iemid_idx on alldata_soil(iemid);
alter table alldata_traffic add iemid int references stations(iemid);
create index alldata_traffic_iemid_idx on alldata_traffic(iemid);
