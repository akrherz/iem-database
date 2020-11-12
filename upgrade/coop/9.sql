ALTER TABLE alldata RENAME estimated to precip_estimated;
ALTER TABLE alldata ADD temp_estimated boolean;
alter table alldata add temp_hour smallint;
alter table alldata add precip_hour smallint;
