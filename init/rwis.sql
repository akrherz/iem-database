CREATE EXTENSION postgis;
-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version (
    version int, -- noqa
    updated timestamptz
);
INSERT INTO iem_schema_manager_version VALUES (10, now());

CREATE TABLE stations (
    id varchar(64),
    synop int,
    name varchar(64), -- noqa
    state char(2),
    country char(2),
    elevation real,
    network varchar(20),
    online boolean, -- noqa
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
    iemid serial,
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
    geom GEOMETRY (POINT, 4326)
);
ALTER TABLE stations OWNER TO mesonet;
GRANT SELECT ON stations TO ldm, nobody;
CREATE UNIQUE INDEX stations_idx ON stations (id, network);
CREATE UNIQUE INDEX stations_iemid_idx ON stations (iemid);


CREATE TABLE sensors (
    iemid int REFERENCES stations (iemid),
    sensor0 varchar(100),
    sensor1 varchar(100),
    sensor2 varchar(100),
    sensor3 varchar(100)
);
GRANT SELECT ON sensors TO nobody;

CREATE TABLE alldata (
    iemid int REFERENCES stations (iemid),
    valid timestamptz, -- noqa
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
) PARTITION BY RANGE (valid);
ALTER TABLE alldata OWNER TO mesonet;
GRANT ALL ON alldata TO ldm;
GRANT SELECT ON alldata TO nobody;

CREATE TABLE alldata_traffic (
    iemid int REFERENCES stations (iemid),
    valid timestamp with time zone,  --noqa
    lane_id smallint,
    avg_speed real,
    avg_headway real,
    normal_vol real,
    long_vol real,
    occupancy real
) PARTITION BY RANGE (valid);
ALTER TABLE alldata_traffic OWNER TO mesonet;
GRANT ALL ON alldata_traffic TO ldm;
GRANT SELECT ON alldata_traffic TO nobody;


CREATE TABLE alldata_soil (
    iemid int REFERENCES stations (iemid),
    valid timestamp with time zone, -- noqa
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
) PARTITION BY RANGE (valid);
ALTER TABLE alldata_soil OWNER TO mesonet;
GRANT ALL ON alldata_soil TO ldm;
GRANT SELECT ON alldata_soil TO nobody;

DO
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
            CREATE INDEX %s_iemid_idx on %s(iemid)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_valid_idx on %s(valid)
        $f$, mytable, mytable);
    end loop;
end;
$do$;

DO
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
            CREATE INDEX %s_iemid_idx on %s(iemid)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_valid_idx on %s(valid)
        $f$, mytable, mytable);
    end loop;
end;
$do$;

DO
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
            CREATE INDEX %s_iemid_idx on %s(iemid)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_valid_idx on %s(valid)
        $f$, mytable, mytable);
    end loop;
end;
$do$;
