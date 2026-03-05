CREATE EXTENSION postgis;

-- bandaid
INSERT INTO spatial_ref_sys
SELECT
    9311 AS srid,
    'EPSG' AS auth_name,
    9311 AS auth_srid,
    srtext,
    proj4text
FROM spatial_ref_sys
WHERE srid = 2163;

-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version (
    version int,
    updated timestamptz
);
INSERT INTO iem_schema_manager_version VALUES (17, now());

CREATE TABLE stations (
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
    wigos varchar(64)
);
CREATE UNIQUE INDEX stations_idx ON stations (id, network);
CREATE UNIQUE INDEX stations_iemid_idx ON stations (iemid);
SELECT addgeometrycolumn('stations', 'geom', 4326, 'POINT', 2);
GRANT SELECT ON stations TO nobody;
GRANT ALL ON stations_iemid_seq TO nobody;
GRANT ALL ON stations TO mesonet, ldm;
GRANT ALL ON stations_iemid_seq TO mesonet, ldm;


CREATE TABLE unknown (
    nwsli varchar(8),
    product varchar(64),
    network varchar(24)
);
ALTER TABLE unknown OWNER TO mesonet;
GRANT ALL ON unknown TO ldm;
GRANT SELECT ON unknown TO nobody;

CREATE TABLE raw_inbound (
    station varchar(8),
    valid timestamptz,
    key varchar(11),
    value real,
    depth smallint,
    unit_convention char(1),
    qualifier char(1),
    dv_interval interval,
    updated timestamptz DEFAULT now()
);
ALTER TABLE raw_inbound OWNER TO mesonet;
GRANT ALL ON raw_inbound TO ldm;

-- Create the raw partitioned tables
CREATE TABLE raw (
    station varchar(8),
    valid timestamptz,
    key varchar(11),
    value real,
    depth smallint,
    unit_convention char(1),
    qualifier char(1),
    dv_interval interval
) PARTITION BY RANGE (valid);
ALTER TABLE raw OWNER TO mesonet;
GRANT ALL ON raw TO ldm;
GRANT SELECT ON raw TO nobody;

DO
$do$
declare
     year int;
     month int;
     mytable varchar;
begin
    for year in 2002..2030
    loop
        execute format($f$
            create table raw%s partition of raw
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
            PARTITION by range(valid)
            $f$, year, year, year + 1);
        execute format($f$
            ALTER TABLE raw%s OWNER to mesonet
        $f$, year);
        execute format($f$
            GRANT ALL on raw%s to ldm
        $f$, year);
        execute format($f$
            GRANT SELECT on raw%s to nobody
        $f$, year);
        -- Indices
        execute format($f$
            CREATE INDEX raw%s_idx on raw%s(station, valid)
        $f$, year, year);
        execute format($f$
            CREATE INDEX raw%s_station_idx on raw%s(station)
        $f$, year, year);
        for month in 1..12
        loop
            mytable := format($f$raw%s_%s$f$,
                year, lpad(month::text, 2, '0'));
            execute format($f$
                create table %s partition of raw%s
                for values from ('%s-%s-01 00:00+00') to ('%s-%s-01 00:00+00')
                $f$, mytable,
                year,
                year, month,
                case when month = 12 then year + 1 else year end,
                case when month = 12 then 1 else month + 1 end);
            execute format($f$
                ALTER TABLE %s OWNER to mesonet
            $f$, mytable);
            execute format($f$
                GRANT ALL on %s to ldm
            $f$, mytable);
            execute format($f$
                GRANT SELECT on %s to nobody
            $f$, mytable);

        end loop;
    end loop;
end;
$do$;

-- Storage of common / instantaneous data values
CREATE TABLE alldata (
    station varchar(8),
    valid timestamptz,
    tmpf real,
    dwpf real,
    sknt real,
    drct real
)
PARTITION BY RANGE (valid);
ALTER TABLE alldata OWNER TO mesonet;
GRANT ALL ON alldata TO ldm;
GRANT SELECT ON alldata TO nobody;

DO
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2002..2030
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
            CREATE INDEX %s_idx on %s(station, valid)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_valid_idx on %s(valid)
        $f$, mytable, mytable);
    end loop;
end;
$do$;
