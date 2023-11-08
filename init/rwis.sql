-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
    version int,
    updated timestamptz);
INSERT into iem_schema_manager_version values (7, now());

CREATE TABLE sensors(
  station varchar(5),
  sensor0 varchar(100),
  sensor1 varchar(100),
  sensor2 varchar(100),
  sensor3 varchar(100)
);
GRANT SELECT on sensors to nobody;
  

CREATE TABLE alldata(
  station varchar(6),
  valid timestamptz,
  tmpf real,
  dwpf real,
  drct smallint,
  sknt real,
  tfs0 real,
  tfs1 real,
  tfs2 real,
  tfs3 real,
  subf real,
  gust real,
  tfs0_text text,
  tfs1_text text,
  tfs2_text text,
  tfs3_text text,
  pcpn real,
  vsby real
) PARTITION by range(valid);
ALTER TABLE alldata OWNER to mesonet;
GRANT ALL on alldata to ldm;
GRANT SELECT on alldata to nobody;

CREATE TABLE alldata_traffic(
  station char(5),
  valid timestamp with time zone,
  lane_id smallint,
  avg_speed real,
  avg_headway real,
  normal_vol real,
  long_vol real,
  occupancy real
) PARTITION by range(valid);
ALTER TABLE alldata_traffic OWNER to mesonet;
GRANT ALL on alldata_traffic to ldm;
GRANT select on alldata_traffic to nobody;


CREATE TABLE alldata_soil(
  station char(5),
  valid timestamp with time zone,
  tmpf_1in real,
  tmpf_3in real,
  tmpf_6in real,
  tmpf_9in real,
  tmpf_12in real,
  tmpf_18in real,
  tmpf_24in real,
  tmpf_30in real,
  tmpf_36in real,
  tmpf_42in real,
  tmpf_48in real,
  tmpf_54in real,
  tmpf_60in real,
  tmpf_66in real,
  tmpf_72in real
) PARTITION by range(valid);
ALTER TABLE alldata_soil OWNER to mesonet;
GRANT ALL on alldata_soil to ldm;
GRANT select on alldata_soil to nobody;

do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 1994..2030
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

do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2008..2030
    loop
        mytable := format($f$t%s_traffic$f$, year);
        execute format($f$
            create table %s partition of alldata_traffic
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

do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2008..2030
    loop
        mytable := format($f$t%s_soil$f$, year);
        execute format($f$
            create table %s partition of alldata_soil
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
