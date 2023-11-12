-- US Climate Reference Network

CREATE TABLE alldata(
  station varchar(5),
  valid timestamptz,
  tmpc real,
  precip_mm real,
  srad real,
  srad_flag char(1),
  skinc real,
  skinc_flag char(1),
  skinc_type char(1),
  rh real,
  rh_flag real,
  vsm5 real,
  soilc5 real,
  wetness real,
  wetness_flag char(1),
  wind_mps real,
  wind_mps_flag char(1))
  PARTITION by range(valid);
ALTER TABLE alldata OWNER to mesonet;
GRANT ALL on alldata to ldm;
GRANT SELECT on alldata to nobody;

do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2001..2030
    loop
        mytable := format($f$t%s$f$, year);
        execute format($f$
            create table %s partition of alldata
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
            $f$, mytable, year, year + 1);
        execute format($f$
            ALTER TABLE %s OWNER to mesonet
        $f$, mytable);
        execute format($f$
            GRANT ALL on %s to ldm
        $f$, mytable);
        execute format($f$
            GRANT SELECT on %s to nobody
        $f$, mytable);
        -- Indices
        execute format($f$
            CREATE INDEX %s_station_idx on %s(station)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_valid_idx on %s(valid)
        $f$, mytable, mytable);
    end loop;
end;
$do$;