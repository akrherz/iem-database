CREATE EXTENSION postgis;

-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
	version int,
	updated timestamptz);
INSERT into iem_schema_manager_version values (1, now());


---
--- Quasi synced from mesosite database
---
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
ALTER TABLE stations OWNER to mesonet;
CREATE UNIQUE index stations_idx on stations(id, network);
create UNIQUE index stations_iemid_idx on stations(iemid);
SELECT AddGeometryColumn('stations', 'geom', 4326, 'POINT', 2);
GRANT SELECT on stations to apache,nobody;
grant all on stations_iemid_seq to nobody,apache;
GRANT ALL on stations to mesonet,ldm;
GRANT ALL on stations_iemid_seq to mesonet,ldm;

---
--- One Minute ASOS data
---
CREATE TABLE alldata_1minute(
  station varchar(4),
  valid timestamptz,
  vis1_coeff real,
  vis1_nd char(1),
  vis2_coeff real,
  vis2_nd char(1),
  vis3_coeff real,
  vis3_nd char(1),
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
