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
INSERT INTO iem_schema_manager_version VALUES (76, now());

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
CREATE TABLE fema_regions (
    region int,
    states varchar [],
    geom GEOMETRY (MULTIPOLYGON, 4326)
);
ALTER TABLE fema_regions OWNER TO mesonet;
GRANT SELECT ON fema_regions TO nobody;

-- Placeholder as it is bootstrapped via shp2psql
CREATE TABLE rfc (
    gid serial,
    objectid real,
    site_id varchar(3),
    state varchar(2),
    rfc_name varchar(18),
    rfc_city varchar(25),
    basin_id varchar(5),
    geom GEOMETRY (MULTIPOLYGON, 4326)
);
ALTER TABLE rfc OWNER TO mesonet;
GRANT ALL ON rfc TO ldm;
GRANT SELECT ON rfc TO nobody;

-- Bootstraped via scripts in akrherz/DEV repo, pireps folder
CREATE TABLE airspaces (
    ident varchar(8),
    type_code varchar(8) NOT NULL,
    name text,
    geom GEOGRAPHY (MULTIPOLYGON)
);
ALTER TABLE airspaces OWNER TO mesonet;
GRANT ALL ON airspaces TO ldm;
GRANT SELECT ON airspaces TO nobody;

-- Storage of Center Weather Advisories

CREATE TABLE cwas (
    center varchar(4),
    issue timestamptz,
    expire timestamptz,
    product_id varchar(35),
    narrative text,
    num smallint,
    geom GEOMETRY (POLYGON, 4326)
);
ALTER TABLE cwas OWNER TO mesonet;
GRANT SELECT ON TABLE cwas TO nobody;
GRANT ALL ON TABLE cwas TO ldm;
CREATE INDEX cwas_issue_idx ON cwas (issue);
CREATE INDEX cwas_gist_idx ON cwas USING gist (geom);

-- Storage of AIRMETs / Graphical AIRMET

CREATE TABLE airmets (
    gml_id varchar(32),
    label varchar(4) NOT NULL,
    valid_from timestamptz,
    valid_to timestamptz,
    valid_at timestamptz,
    issuetime timestamptz,
    product_id text,
    hazard_type text,
    weather_conditions text [],
    status text,
    geom GEOMETRY (POLYGON, 4326)
);
CREATE INDEX airmets_idx ON airmets (label, valid_at);
CREATE INDEX airmets_geom_idx ON airmets USING gist (geom);
CREATE INDEX airmets_product_id_idx ON airmets (product_id);
ALTER TABLE airmets OWNER TO mesonet;
GRANT SELECT ON TABLE airmets TO nobody;
GRANT ALL ON TABLE airmets TO ldm;

-- Storage of Freezing Level found in AIRMETs

CREATE TABLE airmet_freezing_levels (
    gml_id varchar(32),
    valid_at timestamptz,
    product_id text,
    level int,
    lower_level int,
    upper_level int,
    geom GEOMETRY (MULTILINESTRING, 4326)
);
CREATE INDEX airmet_freezing_levels_idx ON airmet_freezing_levels (valid_at);
ALTER TABLE airmet_freezing_levels OWNER TO mesonet;
GRANT SELECT ON TABLE airmet_freezing_levels TO nobody;
GRANT ALL ON TABLE airmet_freezing_levels TO ldm;


-- Grid Population of the World
-- https://sedac.ciesin.columbia.edu
-- /data/set/gpw-v4-population-count-rev11/data-download
CREATE TABLE gpw2020 (
    geom GEOMETRY (POINT, 4326),
    population int
);
CREATE INDEX gpw2020_gix ON gpw2020 USING gist (geom);
ALTER TABLE gpw2020 OWNER TO mesonet;
GRANT ALL ON gpw2020 TO ldm;
GRANT SELECT ON gpw2020 TO nobody;

--
CREATE TABLE gpw2015 (
    geom GEOMETRY (POINT, 4326),
    population int
);
CREATE INDEX gpw2015_gix ON gpw2015 USING gist (geom);
ALTER TABLE gpw2015 OWNER TO mesonet;
GRANT ALL ON gpw2015 TO ldm;
GRANT SELECT ON gpw2015 TO nobody;

--
CREATE TABLE gpw2010 (
    geom GEOMETRY (POINT, 4326),
    population int
);
CREATE INDEX gpw2010_gix ON gpw2010 USING gist (geom);
ALTER TABLE gpw2010 OWNER TO mesonet;
GRANT ALL ON gpw2010 TO ldm;
GRANT SELECT ON gpw2010 TO nobody;

--
CREATE TABLE gpw2005 (
    geom GEOMETRY (POINT, 4326),
    population int
);
CREATE INDEX gpw2005_gix ON gpw2005 USING gist (geom);
ALTER TABLE gpw2005 OWNER TO mesonet;
GRANT ALL ON gpw2005 TO ldm;
GRANT SELECT ON gpw2005 TO nobody;

--
CREATE TABLE gpw2000 (
    geom GEOMETRY (POINT, 4326),
    population int
);
CREATE INDEX gpw2000_gix ON gpw2000 USING gist (geom);
ALTER TABLE gpw2000 OWNER TO mesonet;
GRANT ALL ON gpw2000 TO ldm;
GRANT SELECT ON gpw2000 TO nobody;

--
CREATE TABLE cwa (
    gid int,
    wfo varchar,
    cwa varchar,
    lon numeric,
    lat numeric,
    the_geom GEOMETRY (MULTIPOLYGON, 4326),
    avg_county_size real,
    region varchar(2)
);
ALTER TABLE cwa OWNER TO mesonet;
GRANT ALL ON cwa TO ldm;
GRANT SELECT ON cwa TO nobody;

--- states table is loaded by some shp2pgsql load that has unknown origins :(
CREATE TABLE states (
    gid int,
    state_name varchar,
    state_fips varchar,
    state_abbr varchar,
    the_geom GEOMETRY (MULTIPOLYGON, 4326),
    simple_geom GEOMETRY (MULTIPOLYGON, 4326)
);
ALTER TABLE states OWNER TO mesonet;
GRANT ALL ON states TO ldm;
GRANT SELECT ON states TO nobody;

-- CWSU Boundaries, circa 2005 providence
CREATE TABLE cwsu (
    gid serial,
    id varchar(3),
    geom GEOMETRY (MULTIPOLYGON, 4326)
);
ALTER TABLE cwsu OWNER TO mesonet;
GRANT ALL ON cwsu TO ldm;
GRANT SELECT ON cwsu TO nobody;

---
--- Quasi synced from mesosite database
---
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


---
--- Cruft from the old days
---
CREATE TABLE iemchat_room_participation (
    room varchar(100),
    valid timestamptz,
    users smallint
);

---
--- Bot Warnings
---
CREATE TABLE bot_warnings (
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
SELECT addgeometrycolumn('bot_warnings', 'geom', 4326, 'MULTIPOLYGON', 2);
GRANT SELECT ON bot_warnings TO nobody;

CREATE TABLE robins (
    id serial,
    name varchar,
    city varchar,
    day date
);
ALTER TABLE robins OWNER TO mesonet;
GRANT SELECT ON robins TO nobody;
SELECT addgeometrycolumn('robins', 'the_geom', 4326, 'POINT', 2);

---
--- NWS Forecast / WWA Zones / Boundaries
---
CREATE TABLE ugcs (
    gid serial UNIQUE NOT NULL,
    ugc char(6) NOT NULL,
    name varchar(256),
    state char(2),
    tzname varchar(32),
    wfo varchar(9),
    begin_ts timestamptz NOT NULL,
    end_ts timestamptz,
    area2163 real,
    source varchar(2) NOT NULL,
    gpw_population_2000 int,
    gpw_population_2005 int,
    gpw_population_2010 int,
    gpw_population_2015 int,
    gpw_population_2020 int
);
ALTER TABLE ugcs OWNER TO mesonet;
GRANT ALL ON ugcs TO ldm;
GRANT ALL ON ugcs_gid_seq TO ldm;
SELECT addgeometrycolumn('ugcs', 'geom', 4326, 'MULTIPOLYGON', 2);
SELECT addgeometrycolumn('ugcs', 'simple_geom', 4326, 'MULTIPOLYGON', 2);
SELECT addgeometrycolumn('ugcs', 'centroid', 4326, 'POINT', 2);
GRANT SELECT ON ugcs TO nobody;
CREATE INDEX ugcs_ugc_idx ON ugcs (ugc);
CREATE INDEX ugcs_gix ON ugcs USING gist (geom);
ALTER TABLE ugcs ADD CONSTRAINT _ugcs_no_ampersand_in_name
CHECK (strpos(name, '&') = 0);

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
CREATE TABLE idot_dashcam_current (
    label varchar(20) UNIQUE NOT NULL,
    valid timestamptz,
    geom GEOMETRY (POINT, 4326)
);
ALTER TABLE idot_dashcam_current OWNER TO mesonet;
GRANT SELECT ON idot_dashcam_current TO nobody;

CREATE TABLE idot_dashcam_log (
    label varchar(20) NOT NULL,
    valid timestamptz,
    geom GEOMETRY (POINT, 4326)
);
ALTER TABLE idot_dashcam_log OWNER TO mesonet;
CREATE INDEX idot_dashcam_log_valid_idx ON idot_dashcam_log (valid);
CREATE INDEX idot_dashcam_log_label_idx ON idot_dashcam_log (label);
GRANT SELECT ON idot_dashcam_current TO nobody;

CREATE OR REPLACE FUNCTION idot_dashcam_insert_before_f()
RETURNS trigger
AS $BODY$
DECLARE
    result INTEGER; 
BEGIN
    result = (select count(*) from idot_dashcam_current
                where label = new.label 
               );

    -- Label exists, update table
    IF result = 1 THEN
        UPDATE idot_dashcam_current SET geom = new.geom,
        valid = new.valid WHERE label = new.label;
    END IF;

    -- Insert into log
    INSERT into idot_dashcam_log(label, valid, geom) VALUES
    (new.label, new.valid, new.geom);
    
    -- Stop insert from happening
    IF result = 1 THEN
        RETURN null;
    END IF;
    
    -- Allow insert to happen
    RETURN new;

END; $BODY$
LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER idot_dashcam_current_insert_before_t
BEFORE INSERT
ON idot_dashcam_current
FOR EACH ROW
EXECUTE PROCEDURE idot_dashcam_insert_before_f();

---
--- Store DOT snowplow data
---
CREATE TABLE idot_snowplow_current (
    label varchar(20) UNIQUE NOT NULL,
    valid timestamptz NOT NULL,
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
ALTER TABLE idot_snowplow_current OWNER TO mesonet;
SELECT addgeometrycolumn('idot_snowplow_current', 'geom', 4326, 'POINT', 2);
GRANT SELECT ON idot_snowplow_current TO nobody;

CREATE TABLE idot_snowplow_archive (
    label varchar(20) NOT NULL,
    valid timestamptz NOT NULL,
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
    geom GEOMETRY (POINT, 4326)
) PARTITION BY RANGE (valid);
CREATE INDEX ON idot_snowplow_archive (label);
CREATE INDEX ON idot_snowplow_archive (valid);
ALTER TABLE idot_snowplow_archive OWNER TO mesonet;
GRANT ALL ON idot_snowplow_archive TO ldm;
GRANT SELECT ON idot_snowplow_archive TO nobody;

DO
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
CREATE TABLE vtec_missing_events (
    year smallint,
    wfo char(3),
    phenomena char(2),
    significance char(1),
    eventid int
);
GRANT ALL ON vtec_missing_events TO mesonet, ldm;
GRANT SELECT ON vtec_missing_events TO nobody;

-- Legacy table supporting NWSChat, sigh
CREATE TABLE text_products (
    product_id varchar(35),
    geom GEOMETRY (MULTIPOLYGON, 4326),
    issue timestamptz,
    expire timestamptz,
    pil char(6)
);
ALTER TABLE text_products OWNER TO mesonet;
GRANT ALL ON text_products TO ldm;
GRANT SELECT ON text_products TO nobody;

CREATE INDEX text_products_idx ON text_products (product_id);
CREATE INDEX text_products_issue_idx ON text_products (issue);
CREATE INDEX text_products_expire_idx ON text_products (expire);
CREATE INDEX text_products_pil_idx ON text_products (pil);

-- Special Weather Statements
CREATE TABLE sps (
    product_id varchar(35),
    segmentnum smallint,
    pil char(6),
    wfo char(3),
    issue timestamptz,
    expire timestamptz,
    geom GEOMETRY (POLYGON, 4326),
    ugcs char(6) [],
    landspout text,
    waterspout text,
    max_hail_size text,
    max_wind_gust text,
    tml_valid timestamp with time zone,
    tml_direction smallint,
    tml_sknt smallint,
    tml_geom GEOMETRY (POINT, 4326),
    tml_geom_line GEOMETRY (LINESTRING, 4326)
) PARTITION BY RANGE (issue);
ALTER TABLE sps OWNER TO mesonet;
GRANT ALL ON sps TO ldm;
GRANT SELECT ON sps TO nobody;

DO
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
ALTER TABLE riverpro OWNER TO mesonet;
GRANT SELECT ON riverpro TO nobody;

CREATE UNIQUE INDEX riverpro_nwsli_idx ON riverpro USING btree (nwsli);

---
--- VTEC Table
---
CREATE TABLE warnings (
    issue timestamp with time zone NOT NULL,
    expire timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
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
    gid int REFERENCES ugcs (gid) NOT NULL,
    init_expire timestamp with time zone NOT NULL,
    product_issue timestamp with time zone NOT NULL,
    is_emergency boolean,
    is_pds boolean,
    purge_time timestamptz,
    product_ids varchar(36) [] NOT NULL DEFAULT '{}',
    vtec_year smallint NOT NULL
) PARTITION BY LIST (vtec_year);
ALTER TABLE warnings OWNER TO mesonet;
GRANT ALL ON warnings TO ldm;
GRANT SELECT ON warnings TO nobody;

DO
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
CREATE TABLE sbw (
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
    geom GEOMETRY (MULTIPOLYGON, 4326),
    tml_geom GEOMETRY (POINT, 4326),
    tml_geom_line GEOMETRY (LINESTRING, 4326),
    hvtec_nwsli text,
    hvtec_severity char(1),
    hvtec_cause char(2),
    hvtec_record char(2),
    windthreat text,
    hailthreat text,
    squalltag text,
    product_id varchar(36),
    vtec_year smallint NOT NULL,
    product_signature text,
    shared_border_pct real
) PARTITION BY LIST (vtec_year);
ALTER TABLE sbw OWNER TO mesonet;
GRANT ALL ON sbw TO ldm;
GRANT SELECT ON sbw TO nobody;

DO
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
    type character(1) NOT NULL,
    magnitude numeric,
    city character varying(32),
    county character varying(32),
    state character(2),
    source character varying(32),
    remark text,
    wfo character(3),
    typetext character varying(40) NOT NULL,
    geom GEOMETRY (POINT, 4326),
    product_id text,
    product_id_summary text,
    updated timestamptz DEFAULT now(),
    unit varchar(32),
    qualifier char(1),
    gid int REFERENCES ugcs (gid)
) PARTITION BY RANGE (valid);
ALTER TABLE lsrs OWNER TO mesonet;
GRANT ALL ON lsrs TO ldm;
GRANT SELECT ON lsrs TO nobody;


DO
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
    geom GEOMETRY (POINT, 4326)
);
ALTER TABLE hvtec_nwsli OWNER TO mesonet;
GRANT ALL ON hvtec_nwsli TO ldm;
GRANT SELECT ON hvtec_nwsli TO nobody;

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
    geom GEOMETRY (MULTIPOLYGON, 4326),
    centroid GEOMETRY (POINT, 4326),
    simple_geom GEOMETRY (MULTIPOLYGON, 4326)
);

GRANT SELECT ON nws_ugc TO nobody;

-- SIGMETs
CREATE TABLE alldata_sigmets (
    sigmet_type char(1) NOT NULL,
    label varchar(16) NOT NULL,
    issue timestamp with time zone NOT NULL,
    expire timestamp with time zone NOT NULL,
    product_id varchar(36) NOT NULL,
    geom GEOMETRY (POLYGON, 4326) NOT NULL,
    narrative text
) PARTITION BY RANGE (issue);
ALTER TABLE alldata_sigmets OWNER TO mesonet;
GRANT ALL ON alldata_sigmets TO ldm;
GRANT SELECT ON alldata_sigmets TO nobody;
CREATE INDEX alldata_sigmets_idx ON alldata_sigmets (issue);

DO
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2005..2030
    loop
        mytable := format($f$sigmets_%s$f$, year);
        execute format($f$
            create table %s partition of alldata_sigmets
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
    end loop;
end;
$do$;

---
--- NEXRAD N0R Composites 
---
CREATE TABLE nexrad_n0r_tindex (
    datetime timestamp without time zone,
    filepath varchar,
    the_geom GEOMETRY (MULTIPOLYGON, 4326)
);
ALTER TABLE nexrad_n0r_tindex OWNER TO mesonet;
GRANT ALL ON nexrad_n0r_tindex TO ldm;
GRANT SELECT ON nexrad_n0r_tindex TO nobody;
CREATE INDEX nexrad_n0r_tindex_idx ON nexrad_n0r_tindex (datetime);
CREATE INDEX nexrad_n0r_tindex_date_trunc ON nexrad_n0r_tindex (
    date_trunc('minute', datetime)
);


---
--- NEXRAD N0Q Composites 
---
CREATE TABLE nexrad_n0q_tindex (
    datetime timestamp without time zone,
    filepath varchar,
    the_geom GEOMETRY (MULTIPOLYGON, 4326)
);
ALTER TABLE nexrad_n0q_tindex OWNER TO mesonet;
GRANT ALL ON nexrad_n0q_tindex TO ldm;
GRANT SELECT ON nexrad_n0q_tindex TO nobody;
CREATE INDEX nexrad_n0q_tindex_idx ON nexrad_n0q_tindex (datetime);
CREATE INDEX nexrad_n0q_tindex_date_trunc ON nexrad_n0q_tindex (
    date_trunc('minute', datetime)
);

---
---
---
CREATE TABLE roads_base (
    segid serial UNIQUE,
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
ALTER TABLE roads_base OWNER TO mesonet;
SELECT addgeometrycolumn('roads_base', 'geom', 26915, 'MULTILINESTRING', 2);
SELECT addgeometrycolumn(
    'roads_base', 'simple_geom', 26915, 'MULTILINESTRING', 2
);

GRANT SELECT ON roads_base TO nobody;

CREATE TABLE roads_conditions (
    code smallint UNIQUE,
    label varchar(128),
    color char(7) DEFAULT '#000000' NOT NULL
);
ALTER TABLE roads_conditions OWNER TO mesonet;
GRANT SELECT ON roads_conditions TO nobody;

CREATE TABLE roads_current (
    segid int REFERENCES roads_base (segid),
    valid timestamp with time zone,
    cond_code smallint REFERENCES roads_conditions (code),
    towing_prohibited boolean,
    limited_vis boolean,
    raw varchar
);
ALTER TABLE roads_current OWNER TO mesonet;
GRANT SELECT ON roads_current TO nobody;

---
--- road conditions archive
---
CREATE TABLE roads_log (
    segid int REFERENCES roads_base (segid),
    valid timestamptz,
    cond_code smallint REFERENCES roads_conditions (code),
    towing_prohibited bool,
    limited_vis bool,
    raw text
) PARTITION BY RANGE (valid);
CREATE INDEX ON roads_log (valid);
CREATE INDEX ON roads_log (segid);
ALTER TABLE roads_log OWNER TO mesonet;
GRANT ALL ON roads_log TO ldm;
GRANT SELECT ON roads_log TO nobody;

DO
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
CREATE TABLE spc_outlook (
    id serial UNIQUE NOT NULL,
    issue timestamptz NOT NULL,
    product_issue timestamptz NOT NULL,
    expire timestamptz NOT NULL,
    updated timestamptz DEFAULT now(),
    product_id varchar(35) NOT NULL,
    outlook_type char(1) NOT NULL,
    day smallint NOT NULL,
    cycle smallint NOT NULL
);
ALTER TABLE spc_outlook ADD CONSTRAINT issue_abs CHECK
(abs(product_issue - issue) < '10 days'::interval);
ALTER TABLE spc_outlook ADD CONSTRAINT expire_abs CHECK
(abs(product_issue - expire) < '10 days'::interval);

CREATE INDEX spc_outlook_product_issue ON spc_outlook (product_issue);
CREATE INDEX spc_outlook_issue ON spc_outlook (issue);
CREATE INDEX spc_outlook_expire ON spc_outlook (expire);
CREATE INDEX spc_outlook_combo_idx
ON spc_outlook (outlook_type, day, cycle);
ALTER TABLE spc_outlook OWNER TO mesonet;
GRANT ALL ON spc_outlook TO ldm;
GRANT SELECT ON spc_outlook TO nobody;
GRANT ALL ON spc_outlook_id_seq TO mesonet, ldm;

-- Numeric prioritization of SPC Outlook Thresholds
CREATE TABLE spc_outlook_thresholds (
    priority smallint UNIQUE,
    threshold varchar(4) UNIQUE
);
ALTER TABLE spc_outlook_thresholds OWNER TO mesonet;
GRANT SELECT ON spc_outlook_thresholds TO nobody;
GRANT ALL ON spc_outlook_thresholds TO ldm, mesonet;

INSERT INTO spc_outlook_thresholds VALUES
(2, '0.02'),
(5, '0.05'),
(10, '0.10'),
(15, '0.15'),
(25, '0.25'),
(30, '0.30'),
(35, '0.35'),
(40, '0.40'),
(45, '0.45'),
(60, '0.60'),
(75, '0.75'),
(90, '0.90'),
(101, 'CIG1'),
(102, 'CIG2'),
(103, 'CIG3'),
(104, 'SIGN'),
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

CREATE TABLE spc_outlook_geometries (
    spc_outlook_id int REFERENCES spc_outlook (id),
    threshold varchar(4) REFERENCES spc_outlook_thresholds (threshold),
    category varchar(64),
    geom GEOMETRY (MULTIPOLYGON, 4326) CONSTRAINT _sog_geom_isvalid CHECK (
        st_isvalid(geom)
    ),
    geom_layers GEOMETRY (
        MULTIPOLYGON, 4326
    ) CONSTRAINT _sog_geom_layers_isvalid CHECK (st_isvalid(geom_layers))
);
CREATE INDEX spc_outlook_geometries_idx
ON spc_outlook_geometries (spc_outlook_id);
CREATE INDEX spc_outlook_geometries_gix
ON spc_outlook_geometries USING gist (geom);
CREATE INDEX spc_outlook_geometries_layers_gix
ON spc_outlook_geometries USING gist (geom_layers);
CREATE INDEX spc_outlook_geometries_combo_idx
ON spc_outlook_geometries (threshold, category);
ALTER TABLE spc_outlook_geometries OWNER TO mesonet;
GRANT ALL ON spc_outlook_geometries TO ldm;
GRANT SELECT ON spc_outlook_geometries TO nobody;

--
-- SPC Outlooks View joining the two tables together
CREATE OR REPLACE VIEW spc_outlooks AS
SELECT
    o.id,
    o.issue,
    o.product_issue,
    o.expire,
    g.threshold,
    g.category,
    o.day,
    o.outlook_type,
    g.geom,
    g.geom_layers,
    o.product_id,
    o.updated,
    o.cycle,
    date(o.expire AT TIME ZONE 'UTC' - '24 hours'::interval) AS outlook_date
FROM spc_outlook AS o LEFT JOIN spc_outlook_geometries AS g
    ON (o.id = g.spc_outlook_id);
ALTER VIEW spc_outlooks OWNER TO mesonet;
GRANT SELECT ON spc_outlooks TO ldm, nobody;

--
-- Convective Watches
CREATE TABLE watches (
    fid serial,
    sel varchar(4),
    issued timestamp with time zone,
    expired timestamp with time zone,
    type character(3),
    num smallint,
    geom GEOMETRY (MULTIPOLYGON, 4326),
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
    is_pds bool NOT NULL DEFAULT 'f',
    product_id_wwp varchar(36),
    product_id_saw varchar(36),
    product_id_sel varchar(36)
);
ALTER TABLE watches OWNER TO mesonet;
GRANT ALL ON watches TO ldm;
GRANT ALL ON watches_fid_seq TO ldm;
GRANT SELECT ON watches TO nobody;

CREATE UNIQUE INDEX watches_idx ON watches USING btree (issued, num);

CREATE TABLE watches_current (
    sel character(5),
    issued timestamp with time zone,
    expired timestamp with time zone,
    type character(3),
    report text,
    num smallint,
    geom GEOMETRY (MULTIPOLYGON, 4326)
);
GRANT ALL ON watches_current TO mesonet, ldm;
GRANT SELECT ON watches_current TO nobody;

--
-- Storage of PIREPs
--
CREATE TABLE pireps (
    valid timestamptz,
    geom GEOGRAPHY (POINT, 4326),
    is_urgent boolean,
    aircraft_type text,
    report text,
    artcc varchar(3),
    flight_level int,
    product_id varchar(36)
)
PARTITION BY RANGE (valid);
ALTER TABLE pireps OWNER TO mesonet;
GRANT SELECT ON pireps TO nobody;
GRANT ALL ON pireps TO ldm;

DO
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
CREATE TABLE ffg (
    ugc char(6),
    valid timestamptz,
    hour01 real,
    hour03 real,
    hour06 real,
    hour12 real,
    hour24 real
)
PARTITION BY RANGE (valid);
ALTER TABLE ffg OWNER TO mesonet;
GRANT SELECT ON ffg TO nobody;
GRANT ALL ON ffg TO ldm;

DO
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
CREATE TABLE usdm (
    valid date,
    dm smallint,
    geom GEOMETRY (MULTIPOLYGON, 4326)
);
CREATE INDEX usdm_valid_idx ON usdm (valid);
GRANT SELECT ON usdm TO nobody;
GRANT ALL ON usdm TO mesonet, ldm;

-- Storage of MCDs
CREATE TABLE mcd (
    product_id varchar(35),
    geom GEOMETRY (POLYGON, 4326),
    product text,
    year int NOT NULL,
    num int NOT NULL,
    issue timestamptz,
    expire timestamptz,
    watch_confidence smallint,
    concerning text,
    most_prob_tornado text,
    most_prob_gust text,
    most_prob_hail text
);
ALTER TABLE mcd OWNER TO mesonet;
GRANT ALL ON mcd TO ldm;
GRANT SELECT ON mcd TO nobody;

CREATE INDEX ON mcd (issue);
CREATE INDEX ON mcd (num);
CREATE INDEX mcd_geom_index ON mcd USING gist (geom);
CREATE UNIQUE INDEX mcd_idx ON mcd (year, num);

-- Storage of MPDs
CREATE TABLE mpd (
    product_id varchar(35),
    geom GEOMETRY (POLYGON, 4326),
    product text,
    year int NOT NULL,
    num int NOT NULL,
    issue timestamptz,
    expire timestamptz,
    watch_confidence smallint,
    concerning text,
    most_prob_tornado text,
    most_prob_gust text,
    most_prob_hail text
);
ALTER TABLE mpd OWNER TO mesonet;
GRANT ALL ON mpd TO ldm;
GRANT SELECT ON mpd TO nobody;

CREATE INDEX ON mpd (issue);
CREATE INDEX ON mpd (num);
CREATE INDEX mpd_geom_index ON mpd USING gist (geom);
