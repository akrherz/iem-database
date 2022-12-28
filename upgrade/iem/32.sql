-- Storage of WPC national high low
CREATE TABLE wpc_national_high_low(
    product_id varchar(35),
    station varchar(24),
    state varchar(2),
    name text,
    date date,
    sts timestamptz,
    ets timestamptz,
    n_x char(1),
    value real
);
ALTER TABLE wpc_national_high_low OWNER to mesonet;
GRANT ALL on wpc_national_high_low to ldm;
GRANT SELECT on wpc_national_high_low to nobody;
CREATE index wpc_national_high_low_date_idx on wpc_national_high_low(date);
