-- Storage of more SHEF stuff

ALTER TABLE raw add depth smallint;
ALTER TABLE raw add unit_convention char(1);
ALTER TABLE raw add qualifier char(1);
ALTER TABLE raw add dv_interval interval;

ALTER TABLE raw_inbound add depth smallint;
ALTER TABLE raw_inbound add unit_convention char(1);
ALTER TABLE raw_inbound add qualifier char(1);
ALTER TABLE raw_inbound add dv_interval interval;

ALTER TABLE raw_inbound_tmp add depth smallint;
ALTER TABLE raw_inbound_tmp add unit_convention char(1);
ALTER TABLE raw_inbound_tmp add qualifier char(1);
ALTER TABLE raw_inbound_tmp add dv_interval interval;
