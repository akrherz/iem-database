CREATE EXTENSION postgis;

-- bandaid
insert into spatial_ref_sys
    select 9311, 'EPSG', 9311, srtext, proj4text from spatial_ref_sys
    where srid = 2163;

-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
    version int,
    updated timestamptz);
INSERT into iem_schema_manager_version values (72, now());

---
--- TABLES THAT ARE LOADED VIA shp2pgsql
---   + cities
---   + climate_div
---   + counties
---   + iacounties
---   + iowatorn
---   + placepoly
---   + tz
---   + uscounties
---   + warnings_import

-- FEMA Regions
-- Manual load from https://www.fema.gov/api/open/v2/FemaRegions.geojson
create table fema_regions(
    region int,
    states varchar[],
    geom geometry(MultiPolygon, 4326)
);
alter table fema_regions owner to mesonet;
grant select on fema_regions to nobody;

-- Placeholder as it is bootstrapped via shp2psql
create table rfc(
    gid serial,
    objectid real,
    site_id varchar(3),
    state varchar(2),
    rfc_name varchar(18),
    rfc_city varchar(25),
    basin_id varchar(5),
    geom geometry(MultiPolygon, 4326)
);
ALTER TABLE rfc OWNER to mesonet;
GRANT ALL on rfc to ldm;
GRANT SELECT on rfc to nobody;

-- Bootstraped via scripts in akrherz/DEV repo, pireps folder
CREATE TABLE airspaces(
    ident varchar(8),
    type_code varchar(8) not null,
    name text,
    geom geography(multipolygon)
);
ALTER TABLE airspaces OWNER to mesonet;
GRANT ALL on airspaces to ldm;
GRANT SELECT on airspaces to nobody;

-- Storage of Center Weather Advisories

CREATE TABLE cwas(
    center varchar(4),
    issue timestamptz,
    expire timestamptz,
    product_id varchar(35),
    narrative text,
    num smallint,
    geom geometry(Polygon,4326)
);
ALTER TABLE cwas OWNER to mesonet;
GRANT SELECT ON TABLE cwas TO nobody;
GRANT ALL ON TABLE cwas to ldm;
CREATE INDEX cwas_issue_idx on cwas(issue);
CREATE INDEX cwas_gist_idx on cwas USING GIST(geom);

-- Storage of AIRMETs / Graphical AIRMET

CREATE TABLE airmets(
    gml_id varchar(32),
    label varchar(4) NOT NULL,
    valid_from timestamptz,
    valid_to timestamptz,
    valid_at timestamptz,
    issuetime timestamptz,
    product_id text,
    hazard_type text,
    weather_conditions text[],
    status text,
    geom geometry(Polygon, 4326)
);
CREATE INDEX airmets_idx on airmets(label, valid_at);
CREATE INDEX airmets_geom_idx on airmets USING gist(geom);
CREATE INDEX airmets_product_id_idx on airmets(product_id);
ALTER TABLE airmets OWNER to mesonet;
GRANT SELECT ON TABLE airmets TO nobody;
GRANT ALL on TABLE airmets to ldm;

-- Storage of Freezing Level found in AIRMETs

CREATE TABLE airmet_freezing_levels(
    gml_id varchar(32),
    valid_at timestamptz,
    product_id text,
    level int,
    lower_level int,
    upper_level int,
    geom geometry(MultiLineString, 4326)
);
CREATE INDEX airmet_freezing_levels_idx on airmet_freezing_levels(valid_at);
ALTER TABLE airmet_freezing_levels OWNER to mesonet;
GRANT SELECT ON TABLE airmet_freezing_levels TO nobody;
GRANT ALL on TABLE airmet_freezing_levels to ldm;


-- Grid Population of the World
-- https://sedac.ciesin.columbia.edu/data/set/gpw-v4-population-count-rev11/data-download
CREATE TABLE gpw2020(
    geom geometry(Point,4326),
    population int
);
create index gpw2020_gix on gpw2020 USING GIST(geom);
ALTER TABLE gpw2020 OWNER to mesonet;
GRANT ALL on gpw2020 to ldm;
GRANT SELECT on gpw2020 to nobody;

--
CREATE TABLE gpw2015(
    geom geometry(Point,4326),
    population int
);
create index gpw2015_gix on gpw2015 USING GIST(geom);
ALTER TABLE gpw2015 OWNER to mesonet;
GRANT ALL on gpw2015 to ldm;
GRANT SELECT on gpw2015 to nobody;

--
CREATE TABLE gpw2010(
    geom geometry(Point,4326),
    population int
);
create index gpw2010_gix on gpw2010 USING GIST(geom);
ALTER TABLE gpw2010 OWNER to mesonet;
GRANT ALL on gpw2010 to ldm;
GRANT SELECT on gpw2010 to nobody;

--
CREATE TABLE gpw2005(
    geom geometry(Point,4326),
    population int
);
create index gpw2005_gix on gpw2005 USING GIST(geom);
ALTER TABLE gpw2005 OWNER to mesonet;
GRANT ALL on gpw2005 to ldm;
GRANT SELECT on gpw2005 to nobody;

--
CREATE TABLE gpw2000(
    geom geometry(Point,4326),
    population int
);
create index gpw2000_gix on gpw2000 USING GIST(geom);
ALTER TABLE gpw2000 OWNER to mesonet;
GRANT ALL on gpw2000 to ldm;
GRANT SELECT on gpw2000 to nobody;

--
CREATE TABLE cwa(
  gid int,
  wfo varchar,
  cwa varchar,
  lon numeric,
  lat numeric,
  the_geom geometry(MultiPolygon, 4326),
  avg_county_size real,
  region varchar(2)
);
ALTER TABLE cwa OWNER to mesonet;
GRANT ALL on cwa to ldm;
GRANT SELECT on cwa to nobody;

--- states table is loaded by some shp2pgsql load that has unknown origins :(
CREATE TABLE states(
  gid int,
  state_name varchar,
  state_fips varchar,
  state_abbr varchar,
  the_geom geometry(MultiPolygon, 4326),
  simple_geom geometry(MultiPolygon, 4326)
);
alter table states owner to mesonet;
GRANT ALL on states to ldm;
GRANT SELECT on states to nobody;

-- CWSU Boundaries, circa 2005 providence
CREATE TABLE cwsu(
    gid serial,
    id varchar(3),
    geom geometry(MultiPolygon, 4326)
);
ALTER TABLE cwsu OWNER to mesonet;
GRANT ALL on cwsu to ldm;
GRANT SELECT on cwsu to nobody;

---
--- Quasi synced from mesosite database
---
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
    wigos varchar(64)
);
CREATE UNIQUE index stations_idx on stations(id, network);
create UNIQUE index stations_iemid_idx on stations(iemid);
SELECT AddGeometryColumn('stations', 'geom', 4326, 'POINT', 2);
GRANT SELECT on stations to nobody;
grant all on stations_iemid_seq to nobody;
GRANT ALL on stations to mesonet,ldm;
GRANT ALL on stations_iemid_seq to mesonet,ldm;


---
--- Cruft from the old days
---
CREATE TABLE iemchat_room_participation(
  room varchar(100),
  valid timestamptz,
  users smallint
);

---
--- Bot Warnings
---
CREATE TABLE bot_warnings(
  issue timestamptz,
  expire timestamptz,
  report text,
  type char(3),
  gtype char(1),
  wfo char(3),
  eventid smallint,
  status char(3),
  fips int,
  updated timestamptz,
  fcster varchar(24),
  svs text,
  ugc varchar(6),
  phenomena char(2),
  significance char(1),
  hvtec_nwsli varchar(5),
  hailtag int,
  windtag int
);
SELECT AddGeometryColumn('bot_warnings', 'geom', 4326, 'MULTIPOLYGON', 2);
GRANT SELECT on bot_warnings to nobody;

CREATE TABLE robins(
  id SERIAL,
  name varchar,
  city varchar,
  day date);
SELECT AddGeometryColumn('robins', 'the_geom', 4326, 'POINT', 2);

---
--- NWS Forecast / WWA Zones / Boundaries
---
CREATE TABLE ugcs(
    gid SERIAL UNIQUE NOT NULL,
    ugc char(6) NOT NULL,
    name varchar(256),
    state char(2),
    tzname varchar(32),
    wfo varchar(9),
    begin_ts timestamptz NOT NULL,
    end_ts timestamptz,
    area2163 real,
    source varchar(2),
    gpw_population_2000 int,
    gpw_population_2005 int,
    gpw_population_2010 int,
    gpw_population_2015 int,
    gpw_population_2020 int
);
ALTER TABLE ugcs OWNER to mesonet;
GRANT ALL on ugcs to ldm;
GRANT ALL on ugcs_gid_seq to ldm;
SELECT AddGeometryColumn('ugcs', 'geom', 4326, 'MULTIPOLYGON', 2);
SELECT AddGeometryColumn('ugcs', 'simple_geom', 4326, 'MULTIPOLYGON', 2);
SELECT AddGeometryColumn('ugcs', 'centroid', 4326, 'POINT', 2);
GRANT SELECT on ugcs to nobody;
CREATE INDEX ugcs_ugc_idx on ugcs(ugc);
create index ugcs_gix on ugcs USING GIST(geom);
alter table ugcs add constraint _ugcs_no_ampersand_in_name
    check (strpos(name, '&') = 0);

---
--- Helper function to find a GID for a given UGC code and date!
---
CREATE OR REPLACE FUNCTION get_gid(varchar, timestamptz)
RETURNS int
LANGUAGE sql
AS $_$
  select gid from ugcs WHERE ugc = $1 and begin_ts <= $2 and
  (end_ts is null or end_ts > $2) and
  (source != 'fz' or source is null) LIMIT 1
$_$;

CREATE OR REPLACE FUNCTION get_gid(text, timestamptz)
RETURNS int
LANGUAGE sql
AS $_$
  select gid from ugcs WHERE ugc = $1 and begin_ts <= $2 and
  (end_ts is null or end_ts > $2) and
  (source != 'fz' or source is null) LIMIT 1
$_$;

-- Explicit source version
CREATE OR REPLACE FUNCTION get_gid(varchar, timestamptz, varchar)
RETURNS int
LANGUAGE sql
AS $_$
  select gid from ugcs WHERE ugc = $1 and begin_ts <= $2 and
  (end_ts is null or end_ts > $2) and source = $3 LIMIT 1
$_$;

-- is_firewx version
CREATE OR REPLACE FUNCTION get_gid(varchar, timestamptz, bool)
RETURNS int
LANGUAGE sql
AS $_$
  select gid from ugcs WHERE ugc = $1 and begin_ts <= $2 and
  (end_ts is null or end_ts > $2) and
  (case when $3 then source = 'fz' else source != 'fz' end) LIMIT 1
$_$;

--
-- Version for LSR table to get by a name
--   end_ts is null to get only current entries
--   order by to prioritize counties before zones, hopefully
CREATE OR REPLACE FUNCTION get_gid_by_name_state(varchar, char(2))
RETURNS int
LANGUAGE sql
AS $_$
    select gid from ugcs where state = $2 and upper($1) = upper(name)
    and end_ts is null
    ORDER by ugc ASC LIMIT 1
$_$;

---
--- Store IDOT dashcam stuff
---
CREATE TABLE idot_dashcam_current(
    label varchar(20) UNIQUE not null,
    valid timestamptz,
    idnum int
);
SELECT AddGeometryColumn('idot_dashcam_current', 'geom', 4326, 'POINT', 2);
GRANT SELECT on idot_dashcam_current to nobody;

CREATE TABLE idot_dashcam_log(
    label varchar(20) not null,
    valid timestamptz,
    idnum int
);
SELECT AddGeometryColumn('idot_dashcam_log', 'geom', 4326, 'POINT', 2);
CREATE INDEX idot_dashcam_log_valid_idx on idot_dashcam_log(valid);
CREATE INDEX idot_dashcam_log_label_idx on idot_dashcam_log(label);
GRANT SELECT on idot_dashcam_current to nobody;

CREATE OR REPLACE FUNCTION idot_dashcam_insert_before_F()
RETURNS TRIGGER
 AS $BODY$
DECLARE
    result INTEGER; 
BEGIN
    result = (select count(*) from idot_dashcam_current
                where label = new.label 
               );

    -- Label exists, update table
    IF result = 1 THEN
        UPDATE idot_dashcam_current SET idnum = new.idnum, geom = new.geom,
        valid = new.valid WHERE label = new.label;
    END IF;

    -- Insert into log
    INSERT into idot_dashcam_log(label, valid, idnum, geom) VALUES
    (new.label, new.valid, new.idnum, new.geom);
    
    -- Stop insert from happening
    IF result = 1 THEN
        RETURN null;
    END IF;
    
    -- Allow insert to happen
    RETURN new;

END; $BODY$
LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE TRIGGER idot_dashcam_current_insert_before_T
   before insert
   ON idot_dashcam_current
   FOR EACH ROW
   EXECUTE PROCEDURE idot_dashcam_insert_before_F();

---
--- Store DOT snowplow data
---
CREATE TABLE idot_snowplow_current(
    label varchar(20) UNIQUE not null,
    valid timestamptz not null,
    heading real,
    velocity real,
    roadtemp real,
    airtemp real,
    solidmaterial varchar(256),
    liquidmaterial varchar(256),
    prewetmaterial varchar(256),
    solidsetrate real,
    liquidsetrate real,
    prewetsetrate real,
    leftwingplowstate smallint,
    rightwingplowstate smallint,
    frontplowstate smallint,
    underbellyplowstate smallint,
    solid_spread_code smallint,
    road_temp_code smallint
);
SELECT AddGeometryColumn('idot_snowplow_current', 'geom', 4326, 'POINT', 2);
GRANT SELECT on idot_snowplow_current to nobody;

CREATE TABLE idot_snowplow_archive(
    label varchar(20) not null,
    valid timestamptz not null,
    heading real,
    velocity real,
    roadtemp real,
    airtemp real,
    solidmaterial varchar(256),
    liquidmaterial varchar(256),
    prewetmaterial varchar(256),
    solidsetrate real,
    liquidsetrate real,
    prewetsetrate real,
    leftwingplowstate smallint,
    rightwingplowstate smallint,
    frontplowstate smallint,
    underbellyplowstate smallint,
    solid_spread_code smallint,
    road_temp_code smallint,
    geom geometry(Point, 4326)
) PARTITION by RANGE (valid);
CREATE INDEX on idot_snowplow_archive(label);
CREATE INDEX on idot_snowplow_archive(valid);
ALTER TABLE idot_snowplow_archive OWNER to mesonet;
GRANT ALL on idot_snowplow_archive to ldm;
GRANT SELECT on idot_snowplow_archive to nobody;

do
$do$
declare
     year int;
begin
    for year in 2013..2030
    loop
        execute format($f$
            create table idot_snowplow_%s partition of idot_snowplow_archive
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
        $f$, year, year, year + 1);
        execute format($f$
            GRANT ALL on idot_snowplow_%s to mesonet,ldm
        $f$, year);
        execute format($f$
            GRANT SELECT on idot_snowplow_%s to nobody
        $f$, year);
    end loop;
end;
$do$;

---
--- Missing VTEC eventids
---
CREATE TABLE vtec_missing_events(
  year smallint,
  wfo char(3),
  phenomena char(2),
  significance char(1),
  eventid int
);
GRANT ALL on vtec_missing_events to mesonet,ldm;
GRANT select on vtec_missing_events to nobody;

-- Legacy table supporting NWSChat, sigh
CREATE TABLE text_products (
    product_id varchar(35),
    geom geometry(MultiPolygon, 4326),
    issue timestamptz,
    expire timestamptz,
    pil char(6)
);
ALTER TABLE text_products OWNER to mesonet;
GRANT ALL on text_products to ldm;
grant select on text_products to nobody;

create index text_products_idx  on text_products(product_id);
CREATE INDEX text_products_issue_idx on text_products(issue);
CREATE INDEX text_products_expire_idx on text_products(expire);
create index text_products_pil_idx  on text_products(pil);

-- Special Weather Statements
CREATE TABLE sps(
    product_id varchar(35),
    segmentnum smallint,
    pil char(6),
    wfo char(3),
    issue timestamptz,
    expire timestamptz,
    geom geometry(Polygon, 4326),
    ugcs char(6)[],
    landspout text,
    waterspout text,
    max_hail_size text,
    max_wind_gust text,
    tml_valid timestamp with time zone,
    tml_direction smallint,
    tml_sknt smallint,
    tml_geom geometry(Point, 4326),
    tml_geom_line geometry(Linestring, 4326)
) PARTITION by range(issue);
ALTER TABLE sps OWNER to mesonet;
GRANT ALL on sps to ldm;
GRANT SELECT on sps to nobody;

do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 1993..2030
    loop
        mytable := format($f$sps_%s$f$, year);
        execute format($f$
            create table %s partition of sps
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
            CREATE INDEX %s_issue_idx on %s(issue)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_expire_idx on %s(expire)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_product_id_idx on %s(product_id)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_wfo_idx on %s(wfo)
        $f$, mytable, mytable);
    end loop;
end;
$do$;

---
--- riverpro
---
CREATE TABLE riverpro (
    nwsli character varying(5),
    stage_text text,
    flood_text text,
    forecast_text text,
    severity character(1),
    impact_text text
);

grant select on riverpro to nobody;

CREATE UNIQUE INDEX riverpro_nwsli_idx ON riverpro USING btree (nwsli);

CREATE RULE replace_riverpro
 AS ON INSERT TO riverpro WHERE
 (EXISTS (SELECT 1 FROM riverpro
 WHERE ((riverpro.nwsli)::text = (new.nwsli)::text)))
 DO INSTEAD UPDATE riverpro SET stage_text = new.stage_text,
 flood_text = new.flood_text, forecast_text = new.forecast_text,
 severity = new.severity, impact_text = new.impact_text
 WHERE ((riverpro.nwsli)::text = (new.nwsli)::text);

---
--- VTEC Table
---
CREATE TABLE warnings (
    issue timestamp with time zone not null,
    expire timestamp with time zone not null,
    updated timestamp with time zone not null,
    wfo character(3) NOT NULL,
    eventid smallint NOT NULL,
    status character(3) NOT NULL,
    fcster character varying(24),
    ugc character varying(6) NOT NULL,
    phenomena character(2) NOT NULL,
    significance character(1) NOT NULL,
    hvtec_nwsli character(5),
    hvtec_severity char(1),
    hvtec_cause char(2),
    hvtec_record char(2),
    gid int references ugcs(gid),
    init_expire timestamp with time zone not null,
    product_issue timestamp with time zone not null,
    is_emergency boolean,
    is_pds boolean,
    purge_time timestamptz,
    product_ids varchar(36)[] not null default '{}',
    vtec_year smallint not null
) partition by list(vtec_year);
ALTER TABLE warnings OWNER to mesonet;
GRANT ALL on warnings to ldm;
grant select on warnings to nobody;

do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 1986..2030
    loop
        mytable := format($f$warnings_%s$f$, year);
        execute format($f$
            create table %s partition of warnings for values in (%s)
            $f$, mytable, year);
        execute format($f$
            alter table %s alter vtec_year set default %s
            $f$, mytable, year);
        execute format($f$
            alter table %s ADD CONSTRAINT %s_gid_fkey
            FOREIGN KEY(gid) REFERENCES ugcs(gid)
        $f$, mytable, mytable);
        execute format($f$
            alter table %s ALTER WFO SET NOT NULL;
            alter table %s ALTER eventid SET NOT NULL;
            alter table %s ALTER status SET NOT NULL;
            alter table %s ALTER ugc SET NOT NULL;
            alter table %s ALTER phenomena SET NOT NULL;
            alter table %s ALTER significance SET NOT NULL;
        $f$, mytable, mytable, mytable, mytable, mytable, mytable);
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
            CREATE INDEX %s_combo_idx
            on %s(wfo, phenomena, eventid, significance)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_expire_idx
            on %s(expire)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_issue_idx
            on %s(issue)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_ugc_idx
            on %s(ugc)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_wfo_idx
            on %s(wfo)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_gid_idx
            on %s(gid)
        $f$, mytable, mytable);
    end loop;
end;
$do$;

---
--- Storm Based Warnings Geo Tables
---
create table sbw(
  wfo char(3),
  eventid smallint,
  significance char(1),
  phenomena char(2),
  status char(3),
  issue timestamp with time zone,
  init_expire timestamp with time zone,
  expire timestamp with time zone,
  polygon_begin timestamp with time zone,
  polygon_end timestamp with time zone,
  windtag real,
  hailtag real,
  tornadotag varchar(64),
  damagetag text,
  waterspouttag varchar(64),
  tml_valid timestamp with time zone,
  tml_direction smallint,
  tml_sknt smallint,
  updated timestamptz,
  is_emergency boolean,
  is_pds boolean,
  floodtag_heavyrain varchar(64),
  floodtag_flashflood varchar(64),
  floodtag_damage varchar(64),
  floodtag_leeve varchar(64),
  floodtag_dam varchar(64),
  geom geometry(MultiPolygon, 4326),
  tml_geom geometry(Point, 4326),
  tml_geom_line geometry(Linestring, 4326),
  hvtec_nwsli text,
  hvtec_severity char(1),
  hvtec_cause char(2),
  hvtec_record char(2),
  windthreat text,
  hailthreat text,
  squalltag text,
  product_id varchar(36),
  vtec_year smallint not null,
  product_signature text
) partition by list(vtec_year);
ALTER TABLE sbw OWNER to mesonet;
GRANT ALL on sbw to ldm;
grant select on sbw to nobody;

do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 1986..2030
    loop
        mytable := format($f$sbw_%s$f$, year);
        execute format($f$
            create table %s partition of sbw for values in (%s)
            $f$, mytable, year);
        execute format($f$
            alter table %s alter vtec_year set default %s
            $f$, mytable, year);
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
            CREATE INDEX %s_idx on %s(wfo, eventid, significance, phenomena)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_expire_idx on %s(expire)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_issue_idx on %s(issue)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_wfo_idx on %s(wfo)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_gix ON %s USING GIST (geom)
        $f$, mytable, mytable);
    end loop;
end;
$do$;

--
-- Local Storm Reports
CREATE TABLE lsrs (
    valid timestamp with time zone,
    type character(1),
    magnitude numeric,
    city character varying(32),
    county character varying(32),
    state character(2),
    source character varying(32),
    remark text,
    wfo character(3),
    typetext character varying(40),
    geom geometry(Point, 4326),
    product_id text,
    product_id_summary text,
    updated timestamptz DEFAULT now(),
    unit varchar(32),
    qualifier char(1),
    gid int references ugcs(gid)
) PARTITION by range(valid);
ALTER TABLE lsrs OWNER to mesonet;
GRANT ALL on lsrs to ldm;
grant select on lsrs to nobody;


do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 1986..2030
    loop
        mytable := format($f$lsrs_%s$f$, year);
        execute format($f$
            create table %s partition of lsrs
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
            CREATE INDEX %s_valid_idx on %s(valid)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_wfo_idx on %s(wfo)
        $f$, mytable, mytable);
    end loop;
end;
$do$;

---
--- HVTEC Table
---
CREATE TABLE hvtec_nwsli (
    nwsli character(5),
    river_name character varying(128),
    proximity character varying(16),
    name character varying(128),
    state character(2),
    geom geometry(Point, 4326)
);
ALTER TABLE hvtec_nwsli OWNER to mesonet;
GRANT ALL on hvtec_nwsli to ldm;
grant select on hvtec_nwsli to nobody;

---
--- UGC Lookup Table
---
CREATE TABLE nws_ugc (
    gid serial,
    polygon_class character varying(1),
    ugc character varying(6),
    name character varying(238),
    state character varying(2),
    time_zone character varying(2),
    wfo character varying(9),
    fe_area character varying(2),
    geom geometry(MultiPolygon, 4326),
    centroid geometry(Point, 4326),
    simple_geom geometry(MultiPolygon, 4326)
);

grant select on nws_ugc to nobody;

---
--- SIGMET Convective Outlook
---
CREATE TABLE sigmets_current(
    sigmet_type char(1),
    label varchar(16),
    issue timestamp with time zone,
    expire timestamp with time zone,
    raw text, -- removeme after pyiem release
    product_id varchar(36)
);
ALTER TABLE sigmets_current OWNER to mesonet;
GRANT ALL on sigmets_current to ldm;
SELECT AddGeometryColumn('sigmets_current', 'geom', 4326, 'POLYGON', 2);
GRANT SELECT on sigmets_current to nobody;

CREATE TABLE sigmets_archive(
    sigmet_type char(1),
    label varchar(16),
    issue timestamp with time zone,
    expire timestamp with time zone,
    raw text, -- removeme after pyiem release
    product_id varchar(36)
);
SELECT AddGeometryColumn('sigmets_archive', 'geom', 4326, 'POLYGON', 2);
alter table sigmets_archive owner to mesonet;
grant all on sigmets_archive to ldm;
GRANT SELECT on sigmets_archive to nobody;

---
--- NEXRAD N0R Composites 
---
CREATE TABLE nexrad_n0r_tindex(
 datetime timestamp without time zone,
 filepath varchar
 );
SELECT AddGeometryColumn('nexrad_n0r_tindex', 'the_geom', 4326, 'MULTIPOLYGON', 2);
GRANT SELECT on nexrad_n0r_tindex to nobody;
CREATE INDEX nexrad_n0r_tindex_idx on nexrad_n0r_tindex(datetime);
create index nexrad_n0r_tindex_date_trunc on nexrad_n0r_tindex( date_trunc('minute', datetime) );


---
--- NEXRAD N0Q Composites 
---
CREATE TABLE nexrad_n0q_tindex(
 datetime timestamp without time zone,
 filepath varchar
 );
SELECT AddGeometryColumn('nexrad_n0q_tindex', 'the_geom', 4326, 'MULTIPOLYGON', 2);
GRANT SELECT on nexrad_n0q_tindex to nobody;
CREATE INDEX nexrad_n0q_tindex_idx on nexrad_n0q_tindex(datetime);
create index nexrad_n0q_tindex_date_trunc on nexrad_n0q_tindex( date_trunc('minute', datetime) );

---
---
---
CREATE table roads_base(
    segid SERIAL unique,
    major varchar(32),
    minor varchar(128),
    us1 smallint,
    st1 smallint,
    int1 smallint,
    type smallint,
    wfo char(3),
    longname varchar(256),
    idot_id int,
    archive_begin timestamptz,
    archive_end timestamptz
);

SELECT AddGeometryColumn('roads_base', 'geom', 26915, 'MULTILINESTRING', 2);
SELECT AddGeometryColumn('roads_base', 'simple_geom', 26915, 'MULTILINESTRING', 2);

GRANT SELECT on roads_base to nobody;

CREATE TABLE roads_conditions(
  code smallint unique,
  label varchar(128),
  color char(7) DEFAULT '#000000' NOT NULL
  );
ALTER TABLE roads_conditions OWNER to mesonet;
GRANT SELECT on roads_conditions TO nobody;

CREATE TABLE roads_current(
  segid int REFERENCES roads_base(segid),
  valid timestamp with time zone,
  cond_code smallint REFERENCES roads_conditions(code),
  towing_prohibited boolean,
  limited_vis boolean,
  raw varchar);
GRANT SELECT on roads_current to nobody;

---
--- road conditions archive
---
CREATE TABLE roads_log(
    segid int REFERENCES roads_base(segid),
    valid timestamptz,
    cond_code smallint REFERENCES roads_conditions(code),
    towing_prohibited bool,
    limited_vis bool,
    raw text
) PARTITION by range(valid);
CREATE INDEX on roads_log(valid);
CREATE INDEX on roads_log(segid);
ALTER TABLE roads_log OWNER to mesonet;
GRANT ALL on roads_log to ldm;
GRANT SELECT on roads_log to nobody;

do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2003..2030
    loop
        mytable := format($f$roads_%s_%s_log$f$, year, year + 1);
        execute format($f$
            create table %s partition of roads_log
            for values from ('%s-07-01 00:00+00') to ('%s-07-01 00:00+00')
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
    end loop;
end;
$do$;

--
-- SPC Convective Outlooks
CREATE TABLE spc_outlook(
    id SERIAL UNIQUE NOT NULL,
    issue timestamptz NOT NULL,
    product_issue timestamptz NOT NULL,
    expire timestamptz NOT NULL,
    updated timestamptz DEFAULT now(),
    product_id varchar(35) NOT NULL,
    outlook_type char(1) NOT NULL,
    day smallint NOT NULL,
    cycle smallint NOT NULL
);
CREATE INDEX spc_outlook_product_issue on spc_outlook(product_issue);
CREATE INDEX spc_outlook_issue on spc_outlook(issue);
CREATE INDEX spc_outlook_expire on spc_outlook(expire);
create index spc_outlook_combo_idx
     on spc_outlook(outlook_type, day, cycle);
ALTER TABLE spc_outlook OWNER to mesonet;
GRANT ALL on spc_outlook to ldm;
GRANT SELECT on spc_outlook to nobody;
GRANT ALL on spc_outlook_id_seq to mesonet,ldm;

-- Numeric prioritization of SPC Outlook Thresholds
CREATE TABLE spc_outlook_thresholds(
  priority smallint UNIQUE,
  threshold varchar(4) UNIQUE);
GRANT SELECT on spc_outlook_thresholds to nobody;
GRANT ALL on spc_outlook_thresholds to ldm,mesonet;

INSERT into spc_outlook_thresholds VALUES 
 (10, '0.02'),
 (20, '0.05'),
 (30, '0.10'),
 (40, '0.15'),
 (50, '0.25'),
 (60, '0.30'),
 (70, '0.35'),
 (80, '0.40'),
 (90, '0.45'),
 (100, '0.60'),
 (101, 'SIGN'),
 (110, 'TSTM'),
 (120, 'MRGL'),
 (130, 'SLGT'),
 (140, 'ENH'),
 (150, 'MDT'),
 (160, 'HIGH'),
 (165, 'ELEV'),
 (170, 'CRIT'),
 (180, 'EXTM'),
 (185, 'IDRT'),
 (190, 'SDRT');

CREATE TABLE spc_outlook_geometries(
    spc_outlook_id int REFERENCES spc_outlook(id),
    threshold varchar(4) REFERENCES spc_outlook_thresholds(threshold),
    category varchar(64),
    geom geometry(MultiPolygon, 4326) CONSTRAINT _sog_geom_isvalid CHECK (ST_IsValid(geom)),
    geom_layers geometry(MultiPolygon, 4326) CONSTRAINT _sog_geom_layers_isvalid CHECK (ST_IsValid(geom_layers))
);
CREATE INDEX spc_outlook_geometries_idx
    on spc_outlook_geometries(spc_outlook_id);
CREATE INDEX spc_outlook_geometries_gix
    ON spc_outlook_geometries USING GIST (geom);
CREATE INDEX spc_outlook_geometries_layers_gix
    ON spc_outlook_geometries USING GIST (geom_layers);
create index spc_outlook_geometries_combo_idx
    on spc_outlook_geometries(threshold, category);
ALTER TABLE spc_outlook_geometries OWNER to mesonet;
GRANT ALL on spc_outlook_geometries to ldm;
GRANT SELECT on spc_outlook_geometries to nobody;

--
-- SPC Outlooks View joining the two tables together
CREATE OR REPLACE VIEW spc_outlooks AS
    select id, issue, product_issue, expire, threshold, category, day,
    outlook_type, geom, geom_layers, product_id, updated, cycle,
    date(expire at time zone 'UTC' - '24 hours'::interval) as outlook_date
    from spc_outlook o LEFT JOIN spc_outlook_geometries g
    on (o.id = g.spc_outlook_id);
ALTER VIEW spc_outlooks OWNER to mesonet;
GRANT SELECT on spc_outlooks to ldm,nobody;

--
-- Convective Watches
CREATE TABLE watches (
    fid serial,
    sel character(5),
    issued timestamp with time zone,
    expired timestamp with time zone,
    type character(3),
    num smallint,
    geom geometry(MultiPolygon, 4326),
    tornadoes_2m smallint,
    tornadoes_1m_strong smallint,
    wind_10m smallint,
    wind_1m_65kt smallint,
    hail_10m smallint,
    hail_1m_2inch smallint,
    hail_wind_6m smallint,
    max_hail_size float,
    max_wind_gust_knots float,
    max_tops_feet int,
    storm_motion_drct int,
    storm_motion_sknt int,
    is_pds bool not null default 'f',
    product_id_wwp varchar(36),
    product_id_saw varchar(36),
    product_id_sel varchar(36)
);
ALTER TABLE watches OWNER to mesonet;
GRANT ALL on watches to ldm;
grant all on watches_fid_seq to ldm;
grant select on watches to nobody;

CREATE UNIQUE INDEX watches_idx ON watches USING btree (issued, num);

CREATE TABLE watches_current (
    sel character(5),
    issued timestamp with time zone,
    expired timestamp with time zone,
    type character(3),
    report text,
    num smallint,
    geom geometry(MultiPolygon, 4326)
);
GRANT ALL on watches_current to mesonet,ldm;
grant select on watches_current to nobody;

--
-- Storage of PIREPs
--
CREATE TABLE pireps(
  valid timestamptz,
  geom geography(POINT,4326),
  is_urgent boolean,
  aircraft_type text,
  report text,
  artcc varchar(3),
  flight_level int,
  product_id varchar(36))
  PARTITION by range(valid);
ALTER TABLE pireps OWNER to mesonet;
GRANT SELECT on pireps to nobody;
GRANT ALL on pireps to ldm;

do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2000..2030
    loop
        mytable := format($f$pireps_%s$f$, year);
        execute format($f$
            create table %s partition of pireps
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
            CREATE INDEX %s_valid_idx on %s(valid)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_geom_idx on %s USING GIST (geom)
        $f$, mytable, mytable);
    end loop;
end;
$do$;

--
CREATE TABLE ffg(
  ugc char(6),
  valid timestamptz,
  hour01 real,
  hour03 real,
  hour06 real,
  hour12 real,
  hour24 real)
  PARTITION by range(valid);
ALTER TABLE ffg OWNER to mesonet;
GRANT SELECT on ffg to nobody;
GRANT ALL on ffg to ldm;

do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2000..2030
    loop
        mytable := format($f$ffg_%s$f$, year);
        execute format($f$
            create table %s partition of ffg
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
            CREATE INDEX %s_ugc_idx on %s(ugc)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_valid_idx on %s(valid)
        $f$, mytable, mytable);
    end loop;
end;
$do$;



-- Storage of USDM
CREATE TABLE usdm(
  valid date,
  dm smallint,
  geom geometry(MultiPolygon, 4326));
CREATE INDEX usdm_valid_idx on usdm(valid);
GRANT SELECT on usdm to nobody;
GRANT ALL on usdm to mesonet,ldm;

-- Storage of MCDs
CREATE TABLE mcd(
    product_id varchar(35),
    geom geometry(Polygon,4326),
    product text,
    year int NOT NULL,
    num int NOT NULL,
    issue timestamptz,
    expire timestamptz,
    watch_confidence smallint,
    concerning text
);
ALTER TABLE mcd OWNER to mesonet;
GRANT ALL on mcd to ldm;
GRANT SELECT on mcd to nobody;

CREATE INDEX ON mcd(issue);
CREATE INDEX ON mcd(num);
CREATE INDEX mcd_geom_index on mcd USING GIST(geom);
create unique index mcd_idx on mcd(year, num);

-- Storage of MPDs
CREATE TABLE mpd(
    product_id varchar(35),
    geom geometry(Polygon,4326),
    product text,
    year int NOT NULL,
    num int NOT NULL,
    issue timestamptz,
    expire timestamptz,
    watch_confidence smallint,
    concerning text
);
ALTER TABLE mpd OWNER to mesonet;
GRANT ALL on mpd to ldm;
GRANT SELECT on mpd to nobody;

CREATE INDEX ON mpd(issue);
CREATE INDEX ON mpd(num);
CREATE INDEX mpd_geom_index on mpd USING GIST(geom);
