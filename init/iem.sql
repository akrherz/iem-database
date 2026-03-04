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
    version int,  -- noqa
    updated timestamptz
);
INSERT INTO iem_schema_manager_version VALUES (35, now());

-- Storage of WPC national high low
CREATE TABLE wpc_national_high_low (
    product_id varchar(35),
    station varchar(24),
    state varchar(2),
    name text,  -- noqa
    date date,  -- noqa
    sts timestamptz,
    ets timestamptz,
    n_x char(1),
    value real  -- noqa
);
ALTER TABLE wpc_national_high_low OWNER TO mesonet;
GRANT ALL ON wpc_national_high_low TO ldm;
GRANT SELECT ON wpc_national_high_low TO nobody;
CREATE INDEX wpc_national_high_low_date_idx ON wpc_national_high_low (date);

-- Storage of CF6 data
CREATE TABLE cf6_data (
    station text,
    valid date,  -- noqa
    product text,
    high real,
    low real,
    avg_temp real,
    dep_temp real,
    hdd real,
    cdd real,
    precip real,
    snow real,
    snowd_12z real,
    avg_smph real,
    max_smph real,
    avg_drct real,
    minutes_sunshine real,
    possible_sunshine real,
    cloud_ss real,
    wxcodes text,
    gust_smph real,
    gust_drct real,
    updated timestamptz
) PARTITION BY RANGE (valid);
CREATE UNIQUE INDEX ON cf6_data (station, valid);
ALTER TABLE cf6_data OWNER TO mesonet;
GRANT ALL ON cf6_data TO ldm;
GRANT SELECT ON cf6_data TO nobody;

DO
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2000..2030
    loop
        mytable := format($f$cf6_data_%s$f$, year);
        execute format($f$
            create table %s partition of cf6_data
            for values from ('%s-01-01') to ('%s-01-01')
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

CREATE TABLE stations (
    id varchar(64),
    synop int,
    name varchar(64),  -- noqa
    state char(2),
    country char(2),
    elevation real,
    network varchar(20),
    online boolean,  -- noqa
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
--- Some skycoverage metadata
---
CREATE TABLE skycoverage (
    code char(3),
    value smallint  -- noqa
);
GRANT SELECT ON skycoverage TO nobody;
INSERT INTO skycoverage VALUES ('CLR', 0);
INSERT INTO skycoverage VALUES ('FEW', 25);
INSERT INTO skycoverage VALUES ('SCT', 50);
INSERT INTO skycoverage VALUES ('BKN', 75);
INSERT INTO skycoverage VALUES ('OVC', 100);

---
--- Events table
---
CREATE TABLE events (
    station varchar(10),
    network varchar(10),
    valid timestamptz,  -- noqa
    event varchar(10),  -- noqa
    magnitude real,
    iemid int REFERENCES stations (iemid)
);
GRANT SELECT ON events TO nobody;

---
--- Current QC data
---
CREATE TABLE current_qc (
    valid timestamptz,  -- noqa
    tmpf real,
    tmpf_qc_av real,
    tmpf_qc_sc real,
    dwpf real,
    dwpf_qc_av real,
    dwpf_qc_sc real,
    alti real,
    alti_qc_av real,
    alti_qc_sc real,
    iemid int REFERENCES stations (iemid)
);
CREATE UNIQUE INDEX current_qc_idx ON current_qc (iemid);
GRANT SELECT ON current_qc TO nobody;

---
--- Copy of the climate51 table that is in the coop database
---
CREATE TABLE climate51 (
    station varchar(6),
    valid date,  -- noqa
    high real,
    low real,
    precip real,
    snow real,
    max_high real,
    max_low real,
    min_high real,
    min_low real,
    max_precip real,
    years int,
    gdd50 real,
    sdd86 real,
    max_high_yr int,
    max_low_yr int,
    min_high_yr int,
    min_low_yr int,
    max_precip_yr int,
    max_range smallint,
    min_range smallint,
    hdd65 real
);
CREATE UNIQUE INDEX climate51_idx ON climate51 (station, valid);
CREATE INDEX climate51_station_idx ON climate51 (station);
CREATE INDEX climate51_valid_idx ON climate51 (valid);
GRANT SELECT ON climate51 TO nobody;

---
--- Storage of information we parse from CLI products
---
CREATE TABLE cli_data (
    station char(4),
    product varchar(64),
    valid date,  -- noqa
    high int,
    high_normal int,
    high_record int,
    high_record_years int [],
    high_time varchar(7),
    low int,
    low_normal int,
    low_record int,
    low_record_years int [],
    low_time varchar(7),
    precip float,
    precip_month float,
    precip_jan1 float,
    precip_jan1_normal float,
    precip_jul1 float,
    precip_dec1 float,
    precip_dec1_normal float,
    precip_normal float,
    precip_record float,
    precip_record_years int [],
    precip_month_normal real,
    snow float,
    snow_normal float,
    snow_month float,
    snow_jun1 float,
    snow_jul1 float,
    snow_dec1 float,
    snow_record_years int [],
    snow_record float,
    snow_jun1_normal float,
    snow_jul1_normal float,
    snow_dec1_normal float,
    snow_month_normal float,
    precip_jun1 real,
    precip_jun1_normal real,
    average_sky_cover real,
    resultant_wind_speed real,
    resultant_wind_direction real,
    highest_wind_speed real,
    highest_wind_direction real,
    highest_gust_speed real,
    highest_gust_direction real,
    average_wind_speed real,
    snowdepth real
);
ALTER TABLE cli_data OWNER TO mesonet;
GRANT ALL ON cli_data TO ldm;
CREATE UNIQUE INDEX cli_data_idx ON cli_data (station, valid);
GRANT SELECT ON cli_data TO nobody;

---
--- Offline metadata
---
CREATE TABLE offline (
    station varchar(20),
    network varchar(10),
    trackerid int,
    valid timestamptz  -- noqa
);
ALTER TABLE offline OWNER TO mesonet;
GRANT SELECT ON offline TO nobody;


CREATE TABLE current_shef (
    station varchar(10),
    valid timestamp with time zone,  -- noqa
    physical_code char(2),
    duration char(1),
    source char(1),
    type char(1),  -- noqa
    extremum char(1),
    probability char(1),
    value real,  -- noqa
    depth smallint,  -- noqa
    dv_interval interval,
    qualifier char(1),
    unit_convention char(1),
    product_id varchar(35)
);
CREATE UNIQUE INDEX ON current_shef (
    station, physical_code, duration, source, type, extremum,
    probability, depth, qualifier, unit_convention
);
ALTER TABLE current_shef OWNER TO mesonet;
CREATE INDEX current_shef_station_idx ON current_shef (station);
GRANT ALL ON current_shef TO ldm;
GRANT SELECT ON current_shef TO nobody;

CREATE TABLE current (
    iemid int REFERENCES stations (iemid),
    tmpf real,
    dwpf real,
    drct real,
    sknt real,
    indoor_tmpf real,
    tsf0 real,
    tsf1 real,
    tsf2 real,
    tsf3 real,
    rwis_subf real,
    scond0 character varying,
    scond1 character varying,
    scond2 character varying,
    scond3 character varying,
    valid timestamp with time zone DEFAULT '1980-01-01 00:00:00-06'::timestamp with time zone,   -- noqa
    pday real,
    c1smv real,
    c2smv real,
    c3smv real,
    c4smv real,
    c5smv real,
    c1tmpf real,
    c2tmpf real,
    c3tmpf real,
    c4tmpf real,
    c5tmpf real,
    pres real,
    relh real,
    srad real,
    vsby real,
    phour real DEFAULT (-99),
    gust real,
    raw character varying(256),  -- noqa
    alti real,
    mslp real,
    rstage real,
    pmonth real,
    skyc1 character(3),
    skyc2 character(3),
    skyc3 character(3),
    skyl1 integer,
    skyl2 integer,
    skyl3 integer,
    skyc4 character(3),
    skyl4 integer,
    pcounter real,
    discharge real,
    p03i real,
    p06i real,
    p24i real,
    max_tmpf_6hr real,
    min_tmpf_6hr real,
    max_tmpf_24hr real,
    min_tmpf_24hr real,
    wxcodes varchar(12) [],
    battery real,
    water_tmpf real,
    feel real,
    ice_accretion_1hr real,
    ice_accretion_3hr real,
    ice_accretion_6hr real,
    peak_wind_gust real,
    peak_wind_drct real,
    peak_wind_time timestamptz,
    updated timestamptz DEFAULT now(),
    snowdepth real,
    srad_1h_j real,
    tsoil_4in_f real,
    tsoil_8in_f real,
    tsoil_16in_f real,
    tsoil_20in_f real,
    tsoil_32in_f real,
    tsoil_40in_f real,
    tsoil_64in_f real,
    tsoil_128in_f real
);

-- Condition Relative Humidty to some value gt 0 and le 102 (forgive some)
CREATE OR REPLACE FUNCTION rh_condition()
RETURNS trigger AS $$
declare
    v_relh double precision;
begin
    if NEW.relh is null then
        return NEW;
    end if;
    begin
        v_relh := (NEW.relh)::double precision;
    exception when others then
        NEW.relh := null;
        return NEW;
    end;
    if v_relh <= 0.0 or v_relh > 102.0 then
        NEW.relh := null;
    else
        NEW.relh := v_relh;  -- I suppose we could make this an int, meh
    end if;
    return NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_current_rh_condition
BEFORE INSERT OR UPDATE ON current
FOR EACH ROW EXECUTE FUNCTION rh_condition();

ALTER TABLE current OWNER TO mesonet;
GRANT ALL ON current TO ldm;
CREATE UNIQUE INDEX current_iemid_idx ON current (iemid);
GRANT SELECT ON current TO nobody;

CREATE TABLE current_log (
    iemid int REFERENCES stations (iemid),
    tmpf real,
    dwpf real,
    drct real,
    sknt real,
    indoor_tmpf real,
    tsf0 real,
    tsf1 real,
    tsf2 real,
    tsf3 real,
    rwis_subf real,
    scond0 character varying,
    scond1 character varying,
    scond2 character varying,
    scond3 character varying,
    valid timestamp with time zone DEFAULT '1980-01-01 00:00:00-06'::timestamp with time zone,  -- noqa
    pday real,
    c1smv real,
    c2smv real,
    c3smv real,
    c4smv real,
    c5smv real,
    c1tmpf real,
    c2tmpf real,
    c3tmpf real,
    c4tmpf real,
    c5tmpf real,
    pres real,
    relh real,
    srad real,
    vsby real,
    phour real DEFAULT (-99),
    gust real,
    raw character varying(256),  -- noqa
    alti real,
    mslp real,
    rstage real,
    pmonth real,
    skyc1 character(3),
    skyc2 character(3),
    skyc3 character(3),
    skyl1 integer,
    skyl2 integer,
    skyl3 integer,
    skyc4 character(3),
    skyl4 integer,
    pcounter real,
    discharge real,
    p03i real,
    p06i real,
    p24i real,
    max_tmpf_6hr real,
    min_tmpf_6hr real,
    max_tmpf_24hr real,
    min_tmpf_24hr real,
    wxcodes varchar(12) [],
    battery real,
    water_tmpf real,
    feel real,
    ice_accretion_1hr real,
    ice_accretion_3hr real,
    ice_accretion_6hr real,
    peak_wind_gust real,
    peak_wind_drct real,
    peak_wind_time timestamptz,
    updated timestamptz DEFAULT now(),
    snowdepth real,
    srad_1h_j real,
    tsoil_4in_f real,
    tsoil_8in_f real,
    tsoil_16in_f real,
    tsoil_20in_f real,
    tsoil_32in_f real,
    tsoil_40in_f real,
    tsoil_64in_f real,
    tsoil_128in_f real
);

CREATE TRIGGER trg_current_log_rh_condition
BEFORE INSERT OR UPDATE ON current_log
FOR EACH ROW EXECUTE FUNCTION rh_condition();

GRANT ALL ON current_log TO mesonet, ldm;
GRANT SELECT ON current_log TO nobody;
CREATE INDEX current_log_updated_idx ON current_log (updated);

CREATE OR REPLACE FUNCTION current_update_log() RETURNS trigger
LANGUAGE plpgsql
AS $$
  BEGIN
   IF (NEW.valid != OLD.valid or coalesce(NEW.raw, '') != coalesce(OLD.raw, '')) THEN
     INSERT into current_log SELECT * from current WHERE iemid = NEW.iemid;
   END IF;
   RETURN NEW;
  END
 $$;

CREATE TRIGGER current_update_tigger AFTER UPDATE ON current
FOR EACH ROW EXECUTE PROCEDURE current_update_log();

-- main storage of summary data
CREATE TABLE summary (
    iemid int REFERENCES stations (iemid),
    max_tmpf real,
    min_tmpf real,
    day date,  -- noqa
    max_sknt real,
    max_gust real,
    max_sknt_ts timestamp with time zone,
    max_gust_ts timestamp with time zone,
    max_dwpf real,
    min_dwpf real,
    pday real,
    pmonth real,
    snow real,
    snowd real,
    snoww real,
    max_drct real,
    max_srad real,
    coop_tmpf real,
    coop_valid timestamp with time zone,
    et_inch real,
    srad_mj real,
    avg_sknt real,
    vector_avg_drct real,
    avg_rh real,
    min_rh real,
    max_rh real,
    max_water_tmpf real,
    min_water_tmpf real,
    max_feel real,
    avg_feel real,
    min_feel real,
    min_rstage real,
    max_rstage real,
    report text
) PARTITION BY RANGE (day);
ALTER TABLE summary OWNER TO mesonet;
GRANT ALL ON summary TO ldm;
GRANT SELECT ON summary TO nobody;

DO
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 1900..2030
    loop
        mytable := format($f$summary_%s$f$, year);
        execute format($f$
            create table %s partition of summary
            for values from ('%s-01-01') to ('%s-01-01')
            $f$, mytable, year, year + 1);
        execute format($f$
            ALTER TABLE %s ADD foreign key(iemid)
            references stations(iemid) ON DELETE CASCADE;
        $f$, mytable);
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
            CREATE UNIQUE INDEX %s_idx on %s(iemid, day)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_day_idx on %s(day)
        $f$, mytable, mytable);
    end loop;
end;
$do$;


---
--- Hourly precip
---
CREATE TABLE hourly (
    valid timestamptz,  -- noqa
    phour real,
    iemid int REFERENCES stations (iemid)
) PARTITION BY RANGE (valid);
ALTER TABLE hourly OWNER TO mesonet;
GRANT ALL ON hourly TO ldm;
GRANT SELECT ON hourly TO nobody;

DO
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 1941..2030
    loop
        mytable := format($f$hourly_%s$f$, year);
        execute format($f$
            create table %s partition of hourly
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
            $f$, mytable, year, year + 1);
        execute format($f$
            ALTER TABLE %s ADD foreign key(iemid)
            references stations(iemid) ON DELETE CASCADE;
        $f$, mytable);
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
            CREATE INDEX %s_idx on %s(iemid, valid)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_valid_idx on %s(valid)
        $f$, mytable, mytable);
    end loop;
end;
$do$;

---

CREATE TABLE rwis_locations (
    id smallint UNIQUE,
    nwsli char(5)
);
GRANT SELECT ON rwis_locations TO nobody;

--
-- RWIS Deep Soil Probe Data
--
CREATE TABLE rwis_soil_data (
    location_id smallint REFERENCES rwis_locations (id),
    sensor_id smallint,
    valid timestamp with time zone,  -- noqa
    temp real,  -- noqa
    moisture real,
    updated timestamptz DEFAULT now()
);
CREATE TABLE rwis_soil_data_log (
    location_id smallint REFERENCES rwis_locations (id),
    sensor_id smallint,
    valid timestamp with time zone,  -- noqa
    temp real,  -- noqa
    moisture real,
    updated timestamptz DEFAULT now()
);

GRANT SELECT ON rwis_soil_data TO nobody;

CREATE FUNCTION rwis_soil_update_log() RETURNS trigger
LANGUAGE plpgsql
AS $$
  BEGIN
   IF (NEW.valid != OLD.valid) THEN
     INSERT into rwis_soil_data_log 
        SELECT * from rwis_soil_data WHERE sensor_id = NEW.sensor_id
        and location_id = NEW.location_id;
   END IF;
   RETURN NEW;
  END
 $$;

CREATE TRIGGER rwis_soil_update_tigger
AFTER UPDATE ON rwis_soil_data
FOR EACH ROW
EXECUTE PROCEDURE rwis_soil_update_log();

--
-- RWIS Traffic Data Storage
-- 
CREATE TABLE rwis_traffic_sensors (
    id serial UNIQUE,
    location_id smallint REFERENCES rwis_locations (id),
    lane_id smallint,
    name varchar(64)  -- noqa
);
ALTER TABLE rwis_traffic_sensors OWNER TO mesonet;
GRANT SELECT ON rwis_traffic_sensors TO nobody;

CREATE OR REPLACE VIEW rwis_traffic_meta AS
SELECT
    l.id AS location_id,
    l.nwsli,
    s.id AS sensor_id,
    s.lane_id
FROM rwis_locations AS l, rwis_traffic_sensors AS s
WHERE l.id = s.location_id;
GRANT SELECT ON rwis_traffic_meta TO nobody;


CREATE TABLE rwis_traffic_data (
    sensor_id int REFERENCES rwis_traffic_sensors (id),
    valid timestamp with time zone,  -- noqa
    avg_speed real,
    avg_headway real,
    normal_vol real,
    long_vol real,
    occupancy real,
    updated timestamptz DEFAULT now()
);

CREATE TABLE rwis_traffic_data_log (
    sensor_id int REFERENCES rwis_traffic_sensors (id),
    valid timestamp with time zone,  -- noqa
    avg_speed real,
    avg_headway real,
    normal_vol real,
    long_vol real,
    occupancy real,
    updated timestamptz DEFAULT now()
);

CREATE FUNCTION rwis_traffic_update_log() RETURNS trigger
LANGUAGE plpgsql
AS $$
  BEGIN
   IF (NEW.valid != OLD.valid) THEN
     INSERT into rwis_traffic_data_log 
        SELECT * from rwis_traffic_data WHERE sensor_id = NEW.sensor_id;
   END IF;
   RETURN NEW;
  END
 $$;

CREATE TRIGGER rwis_traffic_update_tigger
AFTER UPDATE ON rwis_traffic_data
FOR EACH ROW
EXECUTE PROCEDURE rwis_traffic_update_log();


CREATE VIEW rwis_traffic AS
SELECT * FROM  -- noqa
    rwis_traffic_sensors AS s, rwis_traffic_data AS d
WHERE d.sensor_id = s.id;

GRANT SELECT ON rwis_traffic_data TO nobody;
GRANT SELECT ON rwis_traffic_data_log TO nobody;
GRANT SELECT ON rwis_traffic_sensors TO nobody;
GRANT SELECT ON rwis_traffic TO nobody;

INSERT INTO rwis_locations VALUES (58, 'RPFI4');
INSERT INTO rwis_locations VALUES (30, 'RMCI4');
INSERT INTO rwis_locations VALUES (54, 'RSYI4');
INSERT INTO rwis_locations VALUES (42, 'RSPI4');
INSERT INTO rwis_locations VALUES (48, 'RWBI4');
INSERT INTO rwis_locations VALUES (22, 'RGRI4');
INSERT INTO rwis_locations VALUES (45, 'RURI4');
INSERT INTO rwis_locations VALUES (43, 'RSLI4');
INSERT INTO rwis_locations VALUES (60, 'RDNI4');
INSERT INTO rwis_locations VALUES (61, 'RQCI4');
INSERT INTO rwis_locations VALUES (57, 'RTMI4');
INSERT INTO rwis_locations VALUES (49, 'RHAI4');
INSERT INTO rwis_locations VALUES (52, 'RCRI4');
INSERT INTO rwis_locations VALUES (53, 'RCFI4');
INSERT INTO rwis_locations VALUES (02, 'RTNI4');
INSERT INTO rwis_locations VALUES (03, 'RTOI4');
INSERT INTO rwis_locations VALUES (00, 'RDAI4');
INSERT INTO rwis_locations VALUES (01, 'RALI4');
INSERT INTO rwis_locations VALUES (06, 'RAVI4');
INSERT INTO rwis_locations VALUES (07, 'RBUI4');
INSERT INTO rwis_locations VALUES (04, 'RAMI4');
INSERT INTO rwis_locations VALUES (05, 'RAKI4');
INSERT INTO rwis_locations VALUES (46, 'RWLI4');
INSERT INTO rwis_locations VALUES (47, 'RWII4');
INSERT INTO rwis_locations VALUES (08, 'RCAI4');
INSERT INTO rwis_locations VALUES (09, 'RCDI4');
INSERT INTO rwis_locations VALUES (28, 'RMQI4');
INSERT INTO rwis_locations VALUES (29, 'RMTI4');
INSERT INTO rwis_locations VALUES (40, 'RSGI4');
INSERT INTO rwis_locations VALUES (41, 'RSCI4');
INSERT INTO rwis_locations VALUES (59, 'RCTI4');
INSERT INTO rwis_locations VALUES (51, 'RIGI4');
INSERT INTO rwis_locations VALUES (24, 'RIOI4');
INSERT INTO rwis_locations VALUES (56, 'RDYI4');
INSERT INTO rwis_locations VALUES (25, 'RJFI4');
INSERT INTO rwis_locations VALUES (39, 'RSDI4');
INSERT INTO rwis_locations VALUES (26, 'RLEI4');
INSERT INTO rwis_locations VALUES (27, 'RMNI4');
INSERT INTO rwis_locations VALUES (20, 'RDBI4');
INSERT INTO rwis_locations VALUES (38, 'RROI4');
INSERT INTO rwis_locations VALUES (21, 'RFDI4');
INSERT INTO rwis_locations VALUES (11, 'RCNI4');
INSERT INTO rwis_locations VALUES (10, 'RCII4');
INSERT INTO rwis_locations VALUES (13, 'RCEI4');
INSERT INTO rwis_locations VALUES (12, 'RCBI4');
INSERT INTO rwis_locations VALUES (15, 'RDCI4');
INSERT INTO rwis_locations VALUES (14, 'RDVI4');
INSERT INTO rwis_locations VALUES (17, 'RDMI4');
INSERT INTO rwis_locations VALUES (16, 'RDSI4');
INSERT INTO rwis_locations VALUES (19, 'RDWI4');
INSERT INTO rwis_locations VALUES (18, 'RDEI4');
INSERT INTO rwis_locations VALUES (31, 'RMVI4');
INSERT INTO rwis_locations VALUES (23, 'RIAI4');
INSERT INTO rwis_locations VALUES (37, 'RPLI4');
INSERT INTO rwis_locations VALUES (36, 'ROTI4');
INSERT INTO rwis_locations VALUES (35, 'ROSI4');
INSERT INTO rwis_locations VALUES (34, 'RONI4');
INSERT INTO rwis_locations VALUES (33, 'RNHI4');
INSERT INTO rwis_locations VALUES (55, 'RBFI4');
INSERT INTO rwis_locations VALUES (32, 'RMPI4');
INSERT INTO rwis_locations VALUES (44, 'RTPI4');
INSERT INTO rwis_locations VALUES (50, 'RSBI4');


CREATE FUNCTION dzvalid(timestamp with time zone) RETURNS date
LANGUAGE sql IMMUTABLE
AS $_$SET TIME ZONE 'GMT'; select date($1)$_$;

CREATE FUNCTION getskyc(character varying) RETURNS smallint
LANGUAGE sql
AS $_$select value from skycoverage where code = $1$_$;


CREATE FUNCTION mdate(timestamp with time zone) RETURNS date
LANGUAGE sql IMMUTABLE
AS $_$select date($1)$_$;

CREATE FUNCTION zero_record(text) RETURNS boolean
LANGUAGE plpgsql
AS $_$
  BEGIN
    UPDATE current SET tmpf = NULL, dwpf = NULL, drct = NULL,
     sknt = NULL  WHERE station = $1;
    RETURN true;
  END;
$_$;

--
-- Set cascading deletes when an entry is removed from the stations table
--
ALTER TABLE current
DROP CONSTRAINT current_iemid_fkey,
ADD CONSTRAINT current_iemid_fkey FOREIGN KEY (iemid)
REFERENCES stations (iemid) ON DELETE CASCADE;

ALTER TABLE current_log
DROP CONSTRAINT current_log_iemid_fkey,
ADD CONSTRAINT current_log_iemid_fkey FOREIGN KEY (iemid)
REFERENCES stations (iemid) ON DELETE CASCADE;

ALTER TABLE current_qc
DROP CONSTRAINT current_qc_iemid_fkey,
ADD CONSTRAINT current_qc_iemid_fkey FOREIGN KEY (iemid)
REFERENCES stations (iemid) ON DELETE CASCADE;

ALTER TABLE events
DROP CONSTRAINT events_iemid_fkey,
ADD CONSTRAINT events_iemid_fkey FOREIGN KEY (iemid)
REFERENCES stations (iemid) ON DELETE CASCADE;

ALTER TABLE hourly
DROP CONSTRAINT hourly_iemid_fkey,
ADD CONSTRAINT hourly_iemid_fkey FOREIGN KEY (iemid)
REFERENCES stations (iemid) ON DELETE CASCADE;

ALTER TABLE summary_2014
DROP CONSTRAINT summary_2014_iemid_fkey,
ADD CONSTRAINT summary_2014_iemid_fkey FOREIGN KEY (iemid)
REFERENCES stations (iemid) ON DELETE CASCADE;

ALTER TABLE summary_2015
DROP CONSTRAINT summary_2015_iemid_fkey,
ADD CONSTRAINT summary_2015_iemid_fkey FOREIGN KEY (iemid)
REFERENCES stations (iemid) ON DELETE CASCADE;

ALTER TABLE summary
DROP CONSTRAINT summary_iemid_fkey,
ADD CONSTRAINT summary_iemid_fkey FOREIGN KEY (iemid)
REFERENCES stations (iemid) ON DELETE CASCADE;
