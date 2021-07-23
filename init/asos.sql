CREATE EXTENSION postgis;

-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
	version int,
	updated timestamptz);
INSERT into iem_schema_manager_version values (15, now());

---
--- Store unknown stations
---
CREATE TABLE unknown(
  id varchar(5),
  valid timestamptz
);
ALTER TABLE unknown OWNER to mesonet;
GRANT ALL on unknown to ldm;
GRANT SELECT on unknown to nobody,apache;

---
--- Some skycoverage metadata
---
CREATE TABLE skycoverage(
  code char(3),
  value smallint);
GRANT SELECT on skycoverage to nobody,apache;
INSERT into skycoverage values('CLR', 0);
INSERT into skycoverage values('FEW', 25);
INSERT into skycoverage values('SCT', 50);
INSERT into skycoverage values('BKN', 75);
INSERT into skycoverage values('OVC', 100);


CREATE FUNCTION getskyc(character varying) RETURNS smallint
    LANGUAGE sql
    AS $_$select value from skycoverage where code = $1$_$;


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

-- Storage of Type of Observation this is
CREATE TABLE alldata_report_type(
  id smallint UNIQUE NOT NULL,
  label varchar);
GRANT SELECT on alldata_report_type to nobody,apache;

INSERT into alldata_report_type VALUES
        (0, 'Unknown'),
        (1, 'MADIS HFMETAR'),
        (2, 'Routine'),
        (3, 'Special');


CREATE TABLE alldata(
 station        character varying(4),    
 valid          timestamp with time zone,
 tmpf           real,          
 dwpf           real,          
 drct           real,        
 sknt           real,         
 alti           real,      
 gust           real,       
 vsby           real,      
 skyc1          character(3),     
 skyc2          character(3),    
 skyc3          character(3),   
 skyl1          integer,  
 skyl2          integer, 
 skyl3          integer,
 metar          character varying(256),
 skyc4          character(3),
 skyl4          integer,
 p03i           real,
 p06i           real,
 p24i           real,
 max_tmpf_6hr   real,
 min_tmpf_6hr   real,
 max_tmpf_24hr  real,
 min_tmpf_24hr  real,
 mslp           real,
 p01i           real,
 wxcodes        varchar(12)[],
  report_type smallint REFERENCES alldata_report_type(id),
  ice_accretion_1hr real,
  ice_accretion_3hr real,
  ice_accretion_6hr real,
  feel real,
  relh real,
  peak_wind_gust real,
  peak_wind_drct real,
  peak_wind_time timestamptz
) PARTITION by range(valid);
ALTER TABLE alldata OWNER to mesonet;
GRANT ALL on alldata to ldm;
GRANT SELECT on alldata to nobody,apache;

do
$do$
declare
     year int;
begin
    for year in 1928..2030
    loop
        execute format($f$
            create table t%s partition of alldata
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
            $f$, year, year, year + 1);
        execute format($f$
            ALTER TABLE t%s OWNER to mesonet
        $f$, year);
        execute format($f$
            GRANT ALL on t%s to ldm
        $f$, year);
        execute format($f$
            GRANT SELECT on t%s to nobody,apache
        $f$, year);
        -- Indices
        execute format($f$
            CREATE INDEX t%s_valid_idx on t%s(valid)
        $f$, year, year);
        execute format($f$
            CREATE INDEX t%s_station_idx on t%s(station)
        $f$, year, year);
    end loop;
end;
$do$;

CREATE TABLE scp_alldata(
 station varchar(5),    
 valid timestamptz,
 mid varchar(3),
 high varchar(3),
 cldtop1 int,
 cldtop2 int,
 eca smallint,
 source char(1)
) PARTITION by range(valid);
ALTER TABLE scp_alldata OWNER to mesonet;
GRANT ALL on scp_alldata to ldm;
GRANT SELECT on scp_alldata to nobody,apache;

do
$do$
declare
     year int;
begin
    for year in 1993..2030
    loop
        execute format($f$
            create table scp%s partition of scp_alldata
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
            $f$, year, year, year + 1);
        execute format($f$
            ALTER TABLE scp%s OWNER to mesonet
        $f$, year);
        execute format($f$
            GRANT ALL on scp%s to ldm
        $f$, year);
        execute format($f$
            GRANT SELECT on scp%s to nobody,apache
        $f$, year);
        -- Indices
        execute format($f$
            CREATE INDEX scp%s_valid_idx on scp%s(valid)
        $f$, year, year);
        execute format($f$
            CREATE INDEX scp%s_station_idx on scp%s(station)
        $f$, year, year);
    end loop;
end;
$do$;

-- Storage of TAF Information

CREATE TABLE taf(
    id SERIAL UNIQUE,
    station char(4),
    valid timestamptz,
    product_id varchar(32)
);
ALTER TABLE taf OWNER to mesonet;
GRANT ALL on taf to ldm;
GRANT SELECT on taf to nobody,apache;
CREATE INDEX taf_idx on taf(station, valid);
grant all on taf_id_seq to ldm;

CREATE TABLE taf_forecast(
    taf_id int REFERENCES taf(id),
    valid timestamptz,
    raw text,
    is_tempo boolean,
    end_valid timestamptz,
    sknt smallint,
    drct smallint,
    gust smallint,
    visibility float,
    presentwx text[],
    skyc varchar(3)[],
    skyl int[],
    ws_level int,
    ws_drct smallint,
    ws_sknt smallint
) PARTITION by range(valid);
ALTER TABLE taf_forecast OWNER to mesonet;
GRANT ALL on taf_forecast to ldm;
GRANT SELECT on taf_forecast to nobody,apache;

do
$do$
declare
     year int;
begin
    for year in 1995..2030
    loop
        execute format($f$
            create table taf%s partition of taf_forecast
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
            $f$, year, year, year + 1);
        execute format($f$
            ALTER TABLE taf%s ADD foreign key(taf_id)
            references taf(id);
        $f$, year);
        execute format($f$
            ALTER TABLE taf%s OWNER to mesonet
        $f$, year);
        execute format($f$
            GRANT ALL on taf%s to ldm
        $f$, year);
        execute format($f$
            GRANT SELECT on taf%s to nobody,apache
        $f$, year);
        -- Indices
        execute format($f$
            CREATE INDEX taf%s_valid_idx on taf%s(valid)
        $f$, year, year);
        execute format($f$
            CREATE INDEX taf%s_id_idx on taf%s(taf_id)
        $f$, year, year);
    end loop;
end;
$do$;
