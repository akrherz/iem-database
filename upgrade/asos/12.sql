-- Reorg alldata_1minute as per akrherz/iem#254

ALTER TABLE alldata_1minute RENAME to alldata_1minute_old;

CREATE TABLE alldata_1minute(
  station char(4),
  valid timestamptz,
  vis1_coeff real,
  vis1_nd char(1),
  vis2_coeff real,
  vis2_nd char(1),
  drct smallint,
  sknt smallint,
  gust_drct smallint,
  gust_sknt smallint,
  ptype char(2),
  precip real,
  pres1 real,
  pres2 real,
  pres3 real,
  tmpf smallint,
  dwpf smallint
) PARTITION by range(valid);
ALTER TABLE alldata_1minute OWNER to mesonet;
GRANT ALL on alldata_1minute to ldm;
GRANT SELECT on alldata_1minute to nobody,apache;

do
$do$
declare
     year int;
     month int;
begin
    for year in 2000..2030
    loop
        for month in 1..12
        loop
            execute format($f$
                create table t%s%s_1minute partition of alldata_1minute
                for values from ('%s-%s-01 00:00+00') to ('%s-%s-01 00:00+00')
            $f$, year, lpad(month::text, 2, '0'), year, month,
            case when month = 12 then year + 1 else year end,
            case when month = 12 then 1 else month + 1 end);
            execute format($f$
                GRANT ALL on t%s%s_1minute to mesonet,ldm
            $f$, year, lpad(month::text, 2, '0'));
            execute format($f$
                GRANT SELECT on t%s%s_1minute to nobody,apache
            $f$, year, lpad(month::text, 2, '0'));
            execute format($f$
                CREATE INDEX on t%s%s_1minute(station, valid)
            $f$, year, lpad(month::text, 2, '0'));
        end loop;
    end loop;
end;
$do$;

-- Copy over the old data
do
$do$
declare
     year int;
begin
    for year in 2000..2030
    loop
        execute format($f$
            INSERT into alldata_1minute SELECT * from t%s_1minute
            $f$, year, year);
    end loop;
end;
$do$;
