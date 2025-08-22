-- akrherz/iem/issues/1359
alter table sensors add iemid int references stations(iemid);
alter table alldata add iemid int references stations(iemid);
alter table alldata_soil add iemid int references stations(iemid);
alter table alldata_traffic add iemid int references stations(iemid);
