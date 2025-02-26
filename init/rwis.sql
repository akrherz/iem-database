CREATE EXTENSION postgis;
-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
    version int,
    updated timestamptz);
INSERT into iem_schema_manager_version values (9, now());

CREATE TABLE stations(
    id varchar(64),
    synop int,
    name varchar(64),
    state char(2),
    country char(2),
    elevation real,
    network varchar(20),
    online boolean,
    params varchar(300),
    county varchar(50),
    plot_name varchar(64),
    climate_site varchar(6),
    remote_id int,
    nwn_id int,
    spri smallint,
    wfo varchar(3),
    archive_begin date,
    archive_end date,
    modified timestamp with time zone,
    tzname varchar(32),
    iemid SERIAL,
    metasite boolean,
    sigstage_low real,
    sigstage_action real,
    sigstage_bankfull real,
    sigstage_flood real,
    sigstage_moderate real,
    sigstage_major real,
    sigstage_record real,
    ugc_county char(6),
    ugc_zone char(6),
    ncdc81 varchar(11),
    ncei91 varchar(11),
    temp24_hour smallint,
    precip24_hour smallint,
    wigos varchar(64),
    geom geometry(POINT, 4326)
);
alter table stations owner to mesonet;
grant select on stations to ldm,nobody;
CREATE UNIQUE index stations_idx on stations(id, network);
create UNIQUE index stations_iemid_idx on stations(iemid);


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
  vsby real,
  feel real,
  relh real
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
