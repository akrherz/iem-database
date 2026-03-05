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
INSERT INTO iem_schema_manager_version VALUES (30, now());

--- ==== TABLES TO investigate deleting
--- counties
--- states

-- Storage of DOT Roadway cam metadata
CREATE TABLE dot_roadway_cams (
    cam_id serial UNIQUE NOT NULL,
    device_id text NOT NULL,
    name text NOT NULL,
    archive_begin timestamptz NOT NULL,
    archive_end timestamptz,
    geom GEOMETRY (POINT, 4326)
);
ALTER TABLE dot_roadway_cams OWNER TO mesonet;
GRANT SELECT ON dot_roadway_cams TO nobody;

CREATE TABLE dot_roadway_cams_log (
    cam_id int REFERENCES dot_roadway_cams (cam_id),
    valid timestamp with time zone
) PARTITION BY RANGE (valid);
ALTER TABLE dot_roadway_cams_log OWNER TO mesonet;
GRANT SELECT ON dot_roadway_cams_log TO nobody;

DO
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2018..2030
    loop
        mytable := format($f$dot_roadway_cams_log_%s$f$, year);
        execute format($f$
            create table %s partition of dot_roadway_cams_log
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
            $f$, mytable, year, year + 1);
        execute format($f$
            alter table %s owner to mesonet
        $f$, mytable);
        execute format($f$
            grant select on %s to nobody
        $f$, mytable);
        -- Indices
        execute format($f$
            create index %s_valid_idx on %s(valid)
        $f$, mytable, mytable);
    end loop;
end;
$do$;

-- Storage of citations of the website
CREATE TABLE website_citations (
    publication_date date NOT NULL,
    title text NOT NULL,
    link text,
    iem_resource text
);
ALTER TABLE website_citations OWNER TO mesonet;
GRANT SELECT, INSERT ON website_citations TO nobody;

--
CREATE TABLE tz_world (
    gid serial UNIQUE NOT NULL,
    tzid varchar(30),
    geom GEOMETRY (MULTIPOLYGON, 4326)
);
CREATE INDEX tz_world_geom_idx ON tz_world USING gist (geom);
ALTER TABLE tz_world OWNER TO mesonet;
GRANT SELECT ON tz_world TO ldm, nobody;

--
CREATE TABLE website_telemetry (
    valid timestamptz NOT NULL DEFAULT now(),
    timing real,
    status_code integer,
    client_addr inet,
    app text,
    request_uri text,
    vhost text
);
CREATE INDEX website_telemetry_valid_idx ON
website_telemetry (valid);
ALTER TABLE website_telemetry OWNER TO mesonet;
GRANT ALL ON website_telemetry TO nobody;

---
--- Store 404s for downstream analysis
CREATE TABLE weblog (
    valid timestamptz DEFAULT now(),
    client_addr inet,
    uri text,
    referer text,
    http_status int,
    x_forwarded_for text,
    domain text
);
ALTER TABLE weblog OWNER TO mesonet;
GRANT ALL ON weblog TO nobody;

CREATE TABLE weblog_block_queue (
    protocol smallint,
    client_addr inet,
    target text,
    x_forwarded_for text,
    banned boolean DEFAULT 'f'
);
ALTER TABLE weblog_block_queue OWNER TO mesonet;

---
--- Store metadata used to drive the /timemachine/
---
CREATE TABLE archive_products (
    id serial,
    name varchar,
    template varchar,
    sts timestamptz,
    interval int,
    groupname varchar,
    time_offset int,
    avail_lag int
);
ALTER TABLE archive_products OWNER TO mesonet;
GRANT SELECT ON archive_products TO nobody;


---
--- networks we process!
---
CREATE TABLE networks (
    id varchar(12) UNIQUE,
    name varchar,
    tzname varchar(32),
    extent GEOMETRY (POLYGON, 4326),
    windrose_update timestamptz
);
CREATE UNIQUE INDEX networks_id_idx ON networks (id);
ALTER TABLE networks OWNER TO mesonet;
GRANT ALL ON networks TO ldm;
GRANT SELECT ON networks TO nobody;

---
--- Missing table: news
---
CREATE TABLE news (
    id serial NOT NULL,
    entered timestamptz DEFAULT now(),
    body text,
    author varchar(100),
    title varchar(100),
    url varchar,
    views int DEFAULT 0,
    tags varchar(128) []
);
CREATE INDEX news_entered_idx ON news (entered);
GRANT ALL ON news TO nobody;
GRANT ALL ON news_id_seq TO nobody;

---
--- Racoon Work Tasks
---
CREATE TABLE racoon_jobs (
    jobid varchar(32) DEFAULT md5(random()::text),
    wfo varchar(3),
    sts timestamp with time zone,
    ets timestamp with time zone,
    radar varchar(3),
    processed boolean DEFAULT false,
    nexrad_product char(3),
    wtype varchar(32)
);
GRANT ALL ON racoon_jobs TO nobody;

---
--- IEM Apps Database!
---
CREATE TABLE iemapps (
    appid serial UNIQUE,
    name varchar(256) UNIQUE NOT NULL,
    description text,
    url varchar(256) NOT NULL
);
GRANT ALL ON iemapps TO nobody;

CREATE TABLE iemapps_tags (
    appid int REFERENCES iemapps (appid),
    tag varchar(24) NOT NULL
);
CREATE UNIQUE INDEX iemapps_tags_idx ON iemapps_tags (appid, tag);
GRANT ALL ON iemapps_tags TO nobody;


---
--- webcam logs
---
CREATE TABLE camera_log (
    cam varchar(11),
    valid timestamp with time zone,
    drct smallint
) PARTITION BY RANGE (valid);
ALTER TABLE camera_log OWNER TO mesonet;
GRANT ALL ON camera_log TO ldm;
GRANT SELECT ON camera_log TO nobody;


DO
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2003..2030
    loop
        mytable := format($f$camera_log_%s$f$, year);
        execute format($f$
            create table %s partition of camera_log
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
    end loop;
end;
$do$;


---
--- webcam currents
---
CREATE TABLE camera_current (
    cam varchar(11) UNIQUE,
    valid timestamp with time zone,
    drct smallint
);
GRANT SELECT ON camera_current TO nobody;
GRANT ALL ON camera_current TO mesonet, ldm;

---
--- Webcam scheduling
---
CREATE TABLE webcam_scheduler (
    cid varchar(10),
    begints timestamp with time zone,
    endts timestamp with time zone,
    is_daily boolean,
    filename varchar,
    movie_seconds smallint
);
CREATE UNIQUE INDEX webcam_scheduler_filename_idx ON
webcam_scheduler (filename);
GRANT ALL ON webcam_scheduler TO nobody;

---
--- Store IEM settings
---
CREATE TABLE properties (
    propname varchar,
    propvalue varchar
);
ALTER TABLE properties OWNER TO mesonet;
-- TODO: fix this permissions
GRANT ALL ON properties TO nobody, ldm;
CREATE UNIQUE INDEX properties_idx ON properties (propname, propvalue);

--- Alias for pyWWA nwschat support
CREATE VIEW nwschat_properties AS SELECT
    propname,
    propvalue
FROM properties;

---
--- Webcam configurations
---
CREATE TABLE webcams (
    id varchar(11),
    ip inet,
    name varchar,
    pan0 smallint,
    online boolean,
    port int,
    network varchar(10),
    iservice varchar,
    iserviceurl varchar,
    sts timestamp with time zone,
    ets timestamp with time zone,
    county varchar,
    hosted varchar,
    hostedurl varchar,
    sponsor varchar,
    sponsorurl varchar,
    removed boolean,
    state varchar(2),
    moviebase varchar,
    scrape_url varchar,
    is_vapix boolean,
    fullres varchar(9) DEFAULT '640x480' NOT NULL,
    fqdn varchar
);
SELECT addgeometrycolumn('webcams', 'geom', 4326, 'POINT', 2);
GRANT ALL ON webcams TO mesonet, ldm;
GRANT SELECT ON webcams TO nobody;

CREATE TABLE stations (
    id varchar(64),
    synop int,
    name varchar(64),
    state char(2),
    country char(2),
    elevation real,
    network varchar(20),
    online boolean NOT NULL DEFAULT 't',
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
    modified timestamptz DEFAULT now(),
    tzname varchar(32),
    iemid serial UNIQUE NOT NULL,
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
ALTER TABLE stations OWNER TO mesonet;
-- no commas in name please
ALTER TABLE stations ADD CONSTRAINT stations_nocommas CHECK (
    strpos(name, ',') = 0
);
CREATE UNIQUE INDEX stations_idx ON stations (id, network);
CREATE UNIQUE INDEX stations_iemid_idx ON stations (iemid);
SELECT addgeometrycolumn('stations', 'geom', 4326, 'POINT', 2);
GRANT SELECT ON stations TO nobody;
GRANT ALL ON stations_iemid_seq TO nobody;
GRANT ALL ON stations TO mesonet, ldm;
GRANT ALL ON stations_iemid_seq TO mesonet, ldm;

CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS trigger AS $$
    BEGIN
       NEW.modified = now(); 
       RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER update_stations_modtime BEFORE UPDATE
ON stations FOR EACH ROW EXECUTE PROCEDURE
update_modified_column();

-- Storage of how stations are threaded together
CREATE TABLE station_threading (
    iemid int REFERENCES stations (iemid),
    source_iemid int REFERENCES stations (iemid),
    begin_date date NOT NULL,
    end_date date
);
ALTER TABLE station_threading OWNER TO mesonet;
GRANT ALL ON station_threading TO ldm;
GRANT SELECT ON station_threading TO nobody;

-- Storage of station attributes
CREATE TABLE station_attributes (
    iemid int REFERENCES stations (iemid),
    attr varchar(128) NOT NULL,
    value varchar NOT NULL
);
GRANT ALL ON station_attributes TO mesonet, ldm;
CREATE UNIQUE INDEX station_attributes_idx ON station_attributes (iemid, attr);
CREATE INDEX station_attributes_iemid_idx ON station_attributes (iemid);
GRANT SELECT ON station_attributes TO nobody;

---
CREATE TABLE iemmaps (
    id serial,
    title varchar(256),
    entered timestamp with time zone DEFAULT now(),
    description text,
    keywords varchar(256),
    views int,
    ref varchar(32),
    category varchar(24)
);
GRANT ALL ON iemmaps TO nobody;
GRANT ALL ON iemmaps_id_seq TO nobody;

CREATE TABLE feature (
    valid timestamp with time zone DEFAULT now(),
    title varchar(256),
    story text,
    caption varchar(256),
    good smallint DEFAULT 0,
    bad smallint DEFAULT 0,
    abstain smallint DEFAULT 0,
    voting boolean DEFAULT true,
    tags varchar(1024),
    fbid bigint,
    appurl varchar(1024),
    javascripturl varchar(1024),
    views int DEFAULT 0,
    mediasuffix varchar(8) DEFAULT 'png',
    media_height int,
    media_width int
);
CREATE UNIQUE INDEX feature_title_check_idx ON feature (title);
CREATE INDEX feature_valid_idx ON feature (valid);
GRANT ALL ON feature TO nobody;
GRANT ALL ON feature TO mesonet, ldm;

CREATE TABLE shef_physical_codes (
    code char(2),
    name varchar(128),
    units varchar(64)
);
GRANT SELECT ON shef_physical_codes TO nobody;

CREATE TABLE shef_duration_codes (
    code char(1),
    name varchar(128)
);
GRANT SELECT ON shef_duration_codes TO nobody;

CREATE TABLE shef_extremum_codes (
    code char(1),
    name varchar(128)
);
GRANT SELECT ON shef_extremum_codes TO nobody;

-- Storage of metadata
CREATE TABLE iemrasters (
    id serial UNIQUE,
    name varchar,
    description text,
    archive_start timestamptz,
    archive_end timestamptz,
    units varchar(12),
    interval int,
    filename_template varchar,
    cf_long_name varchar
);
ALTER TABLE iemrasters OWNER TO mesonet;
GRANT SELECT ON iemrasters TO nobody, ldm;

-- Storage of color tables and values
CREATE TABLE iemrasters_lookup (
    iemraster_id int REFERENCES iemrasters (id),
    coloridx smallint,
    value real,
    r smallint,
    g smallint,
    b smallint
);
ALTER TABLE iemrasters_lookup OWNER TO mesonet;
GRANT SELECT ON iemrasters_lookup TO nobody, ldm;

-- Storage of Autoplot timings and such
CREATE TABLE autoplot_timing (
    appid smallint NOT NULL,
    valid timestamptz NOT NULL,
    timing real NOT NULL,
    uri varchar,
    hostname varchar(24) NOT NULL
);
ALTER TABLE autoplot_timing OWNER TO mesonet;
GRANT SELECT ON autoplot_timing TO nobody;
CREATE INDEX autoplot_timing_idx ON autoplot_timing (appid);

-- Storage of talltowers analog request queue
CREATE TABLE talltowers_analog_queue
(
    stations varchar(32),
    sts timestamptz,
    ets timestamptz,
    fmt varchar(32),
    email varchar(128),
    aff varchar(256),
    filled boolean DEFAULT 'f',
    valid timestamptz DEFAULT now()
);
GRANT ALL ON talltowers_analog_queue TO nobody, mesonet;
