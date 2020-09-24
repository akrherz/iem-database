CREATE EXTENSION postgis;

-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
	version int,
	updated timestamptz);
INSERT into iem_schema_manager_version values (-1, now());

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


-- Storage of HML forecasts
CREATE TABLE hml_forecast(
  id SERIAL UNIQUE,
  station varchar(8),
  generationtime timestamptz,
  issued timestamptz,
  forecast_sts timestamptz,
  forecast_ets timestamptz,
  originator varchar(8),
  product_id varchar(32),
  primaryname varchar(64),
  primaryunits varchar(64),
  secondaryname varchar(64),
  secondaryunits varchar(64));
CREATE INDEX hml_forecast_idx on hml_forecast(station, generationtime);
GRANT SELECT on hml_forecast to nobody,apache;


CREATE TABLE hml_observed_keys(
  id smallint UNIQUE,
  label varchar(32));
GRANT SELECT on hml_observed_keys to nobody,apache;

INSERT into hml_observed_keys values
 (0, 'Depth Below Sfc[ft]'),
 (1, 'Discharge Velocity[mph]'),
 (2, 'Flow[kcfs]'),
 (3, 'Forebay Elevation[ft]'),
 (4, 'Generator Discharge[kcfs]'),
 (5, 'Inflow Discharge[kcfs]'),
 (6, 'Lake Elev Abv Datum[ft]'),
 (7, 'Lake Elevation[ft]'),
 (8, 'Pool[ft]'),
 (9, 'Precip[inches]'),
 (10, 'Reading Height - MSL[ft]'),
 (11, 'Reading Height - Sfc[ft]'),
 (12, 'River Discharge[kcfs]'),
 (13, 'Spillway Tailwater[ft]'),
 (14, 'Stage[ft]'),
 (15, 'Stage Trnd Indicator[code]'),
 (16, 'Tailwater[ft]'),
 (17, 'Tide Height[ft]'),
 (18, 'Total Discharge[kcfs]');


CREATE FUNCTION get_hml_observed_key(text)
RETURNS smallint
LANGUAGE sql
AS $_$
  SELECT id from hml_observed_keys where label = $1
$_$;

CREATE TABLE hml_observed_data(
	station varchar(8),
	valid timestamptz,
	key smallint REFERENCES hml_observed_keys(id),
	value real)
    PARTITION by range(valid);
ALTER TABLE hml_observed_data OWNER to mesonet;
GRANT ALL on hml_observed_data to ldm;
GRANT SELECT on hml_observed_data to nobody,apache;

do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2012..2030
    loop
        mytable := format($f$hml_observed_data_%s$f$, year);
        execute format($f$
            create table %s partition of hml_observed_data
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
    end loop;
end;
$do$;

CREATE INDEX hml_forecast_issued_idx on hml_forecast(issued);

-- HML forecast data is kind of a one-off with no inheritence
do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2012..2030
    loop
        mytable := format($f$hml_forecast_data_%s$f$, year);
        execute format($f$
            CREATE TABLE %s(
            hml_forecast_id int REFERENCES hml_forecast(id),
            valid timestamptz,
            primary_value real,
            secondary_value real)
        $f$, mytable);
        execute format($f$
            ALTER TABLE %s OWNER to mesonet
        $f$, mytable);
        execute format($f$
            GRANT ALL on %s to ldm
        $f$, mytable);
        execute format($f$
            GRANT SELECT on %s to nobody,apache
        $f$, mytable);
        execute format($f$
            CREATE INDEX on %s(hml_forecast_id)
        $f$, mytable);
    end loop;
end;
$do$;
