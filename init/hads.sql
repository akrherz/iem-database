CREATE EXTENSION postgis;

-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
	version int,
	updated timestamptz);
INSERT into iem_schema_manager_version values (16, now());

CREATE TABLE stations(
	id varchar(20),
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
	archive_begin timestamptz,
	archive_end timestamp with time zone,
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
	precip24_hour smallint
);
CREATE UNIQUE index stations_idx on stations(id, network);
create UNIQUE index stations_iemid_idx on stations(iemid);
SELECT AddGeometryColumn('stations', 'geom', 4326, 'POINT', 2);
GRANT SELECT on stations to apache,nobody;
grant all on stations_iemid_seq to nobody,apache;
GRANT ALL on stations to mesonet,ldm;
GRANT ALL on stations_iemid_seq to mesonet,ldm;


CREATE TABLE unknown(
	nwsli varchar(8),
	product varchar(64),
	network varchar(24)
);

-- Create the raw partitioned tables
CREATE TABLE raw(
    station varchar(8),
    valid timestamptz,
    key varchar(11),
    value real
) PARTITION by range(valid);
ALTER TABLE raw OWNER to mesonet;
GRANT ALL on raw to ldm;
GRANT SELECT on raw to nobody,apache;

do
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
            GRANT SELECT on raw%s to nobody,apache
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
                GRANT SELECT on %s to nobody,apache
            $f$, mytable);

        end loop;
    end loop;
end;
$do$;

-- Storage of common / instantaneous data values
CREATE TABLE alldata(
	station varchar(8),
	valid timestamptz,
	tmpf real,
	dwpf real,
	sknt real,
	drct real)
    PARTITION by range(valid);
ALTER TABLE alldata OWNER to mesonet;
GRANT ALL on alldata to ldm;
GRANT SELECT on alldata to nobody,apache;

do
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
            GRANT SELECT on %s to nobody,apache
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
