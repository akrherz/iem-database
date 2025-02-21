-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
    version int,
    updated timestamptz);
INSERT into iem_schema_manager_version values (32, now());

-- Storage of Water Quality Data
CREATE TABLE waterquality_data(
  uniqueid varchar(24),
  plotid varchar(24),
  valid timestamp with time zone,
  sample_type varchar(32),
  varname varchar(8),
  value real);
alter table waterquality_data owner to mesonet;
GRANT ALL on waterquality_data to mesonet;
GRANT SELECT on waterquality_data to nobody;


-- Storage of downloads
CREATE TABLE website_downloads(
  email varchar,
  valid timestamptz default now()
);
alter table website_downloads owner to mesonet;
GRANT ALL on website_downloads to nobody;

CREATE TABLE dwm(
 uniqueid varchar,
 plotid varchar,
 cropyear varchar,
 cashcrop varchar,
 boxstructure varchar,
 outletdepth varchar,
 outletdate date,
 comments varchar,
 updated varchar,
 editedby varchar
);
alter table dwm owner to mesonet;
GRANT SELECT on dwm to nobody;

CREATE TABLE notes(
 uniqueid varchar,
 calendaryear int,
 cropyear int,
 notes varchar,
 updated varchar,
 editedby varchar
);
alter table notes owner to mesonet;
GRANT SELECT on notes to nobody;

-- Storage of IPM
CREATE TABLE ipm_data(
  uniqueid varchar(32),
  plotid varchar(32),
  year smallint,
  date date,
  ipm01 varchar,
  ipm02 varchar,
  ipm03 varchar,
  ipm04 varchar,
  ipm05 varchar,
  ipm06 varchar,
  ipm07 varchar,
  ipm08 varchar,
  ipm09 varchar,
  ipm10 varchar,
  ipm11 varchar,
  ipm12 varchar,
  ipm13 varchar,
  ipm14 varchar);
CREATE INDEX ipm_data_uniqueid_idx on ipm_data(uniqueid);
alter table ipm_data owner to mesonet;
GRANT SELECT on ipm_data to nobody;
GRANT ALL on ipm_data to mesonet;

-- Storage of GHG Data
CREATE TABLE ghg_data(
  uniqueid varchar(32),
  plotid varchar(32),
  year int,
  date date,
  ghg01 varchar(64),
  ghg02 varchar(64),
  ghg03 real,
  ghg04 real,
  ghg05 real,
  ghg06 real,
  ghg07 real,
  ghg08 real,
  ghg09 real,
  ghg10 real,
  ghg11 real,
  ghg12 real,
  ghg13 real,
  ghg14 real,
  ghg15 real,
  ghg16 real,
  method varchar(16),
  position varchar(32),
  subsample varchar(16));
CREATE INDEX ghg_data_uniqueid_idx on ghg_data(uniqueid);
alter table ghg_data owner to mesonet;
GRANT SELECT on ghg_data to nobody;
GRANT ALL on ghg_data to mesonet;


-- Storage of website edits metadata
CREATE TABLE website_edits(
  username varchar(128),
  edit_ts timestamptz DEFAULT now(),
  edit_table varchar(64),
  uniqueid varchar,
  plotid varchar,
  valid timestamptz,
  edit_column varchar(64),
  newvalue real,
  comment text);
alter table website_edits owner to mesonet;
GRANT ALL on website_edits to nobody;


-- Finer grain permissions
CREATE TABLE website_access_levels(
  access_level smallint UNIQUE NOT NULL,
  appid varchar,
  label varchar);
GRANT SELECT on website_access_levels to nobody;
INSERT into website_access_levels VALUES (0, 'admin', 'Administrators');
INSERT into website_access_levels VALUES (1, 'cscap', 'Sustainable Corn CAP');
INSERT into website_access_levels VALUES (2, 'td', 'Transforming Drainage');

-- Storage of authorized Google OpenID users
CREATE TABLE website_users(
  email varchar NOT NULL UNIQUE,
  last_usage timestamptz,
  access_level smallint);
alter table website_users owner to mesonet;
GRANT ALL on website_users to nobody;
ALTER TABLE website_users ADD CONSTRAINT distfk FOREIGN KEY (access_level)
  REFERENCES website_access_levels(access_level);
ALTER TABLE website_users DROP CONSTRAINT website_users_email_key;

-- Storage of Tile Flow
CREATE TABLE tileflow_data(
  uniqueid varchar(24),
  plotid varchar(24),
  valid timestamptz,
  discharge_m3 real,
  discharge_m3_qcflag char(1),
  discharge_m3_qc real,
  discharge_mm real,
  discharge_mm_qcflag char(1),
  discharge_mm_qc real);
alter table tileflow_data owner to mesonet;
CREATE INDEX tileflow_data_idx on tileflow_data(uniqueid, plotid, valid);
GRANT SELECT on tileflow_data to nobody;


-- Storage of water table data
CREATE TABLE watertable_data(
  uniqueid varchar(24),
  plotid varchar(24),
  valid timestamptz,
  depth_mm real,
  depth_mm_qcflag char(1),
  depth_mm_qc real);
alter table watertable_data owner to mesonet;
CREATE INDEX watertable_data_idx on watertable_data(uniqueid, plotid, valid);
GRANT SELECT on watertable_data to nobody;


-- Storage of weather data
CREATE TABLE weather_data_daily(
  station varchar(32),
  valid date,
  high real,
  low real,
  precip real,
  sknt real,
  drct real);
alter table weather_data_daily owner to mesonet;
GRANT SELECT on weather_data_daily to nobody;
CREATE INDEX weather_data_daily_idx on weather_data_daily(station, valid);

CREATE TABLE weather_data_obs(
  station varchar(32),
  valid timestamptz,
  tmpf real,
  dwpf real,
  drct real,
  sknt real,
  srad_mj real,
  precip real,
  srad real);
alter table weather_data_obs owner to mesonet;
GRANT SELECT on weather_data_obs to nobody;
CREATE INDEX weather_data_obs_idx on weather_data_obs(station, valid);

-- Add Decagon Data Storage
CREATE TABLE decagon_data(
    uniqueid varchar(24),
    plotid varchar(24),
    valid timestamptz,
    d1moisture real,
    d1moisture_qcflag char(1),
    d1moisture_qc real,
    d1temp real,
    d1temp_qcflag char(1),
    d1temp_qc real,
    d1ec real,
    d1ec_qcflag char(1),
    d1ec_qc real,
    d2moisture real,
    d2moisture_qcflag char(1),
    d2moisture_qc real,
    d2temp real,
    d2temp_qcflag char(1),
    d2temp_qc real,
    d3moisture real,
    d3moisture_qcflag char(1),
    d3moisture_qc real,
    d3temp real,
    d3temp_qcflag char(1),
    d3temp_qc real,
    d4moisture real,
    d4moisture_qcflag char(1),
    d4moisture_qc real,
    d4temp real,
    d4temp_qcflag char(1),
    d4temp_qc real,
    d5moisture real,
    d5moisture_qcflag char(1),
    d5moisture_qc real,
    d5temp real,
    d5temp_qcflag char(1),
    d5temp_qc real,
    d6moisture real,
    d6moisture_qcflag char(1),
    d6moisture_qc real,
    d6temp real,
    d6temp_qcflag char(1),
    d6temp_qc real,
    d7moisture real,
    d7moisture_qcflag char(1),
    d7moisture_qc real,
    d7temp real,
    d7temp_qcflag char(1),
    d7temp_qc real
);
alter table decagon_data owner to mesonet;
CREATE INDEX decagon_valid_idx on decagon_data(valid);
GRANT SELECT on decagon_data to nobody;
create index decagon_data_idx on decagon_data(uniqueid, plotid);


--- Storage of Plot Identifiers
---
CREATE TABLE plotids(
    uniqueid varchar,
    rep varchar,
    tillage varchar,
    rotation varchar,
    drainage varchar,
    nitrogen varchar,
    landscape varchar,
    row varchar,
    col varchar,
    soilseriesname2 varchar,
    soiltextureseries2 varchar,
    soilseriesname1 varchar,
    soiltextureseries1 varchar,
    soilseriesdescription1 varchar,
    soiltaxonomicclass1 varchar,
    soilseriesdescription2 varchar,
    soiltaxonomicclass2 varchar,
    soiltextureseries3 varchar,
    soiltaxonomicclass3 varchar,
    soilseriesdescription3 varchar,
    soilseriesname3 varchar,
    north varchar,
    west varchar,
    south varchar,
    plotid varchar,
    soiltaxonomicclass4 varchar,
    soilseriesdescription4 varchar,
    soilseriesname4 varchar,
    soiltextureseries4 varchar,
    notes varchar,
    herbicide varchar,
    agro varchar(3),
    soil varchar(3),
    ghg varchar(3),
    ipmcscap varchar(3),
    ipmusb varchar(3),
    timing varchar
);
CREATE UNIQUE INDEX plotids_idx on plotids(uniqueid, plotid);
alter table plotids owner to mesonet;
GRANT SELECT on plotids to nobody;

---=========================================================================
--- Storage of Management
---
CREATE TABLE management(
    updated varchar,
    irrigationmethod varchar,
    residuebiomassmoisture varchar,
    organicamendments varchar,
    cropyear varchar,
    irrigation varchar,
    comments varchar,
    residueplantingpercentage varchar,
    residueremoval varchar,
    residuetype varchar,
    residuehow varchar,
    uniqueid varchar,
    residuebiomassweight varchar,
    limeyear varchar,
    organicamendmentstext varchar,
    irrigationamount varchar,
    editedby varchar
);
GRANT SELECT on management to nobody;

--- Storage of Pesticides
---
CREATE TABLE pesticides(
    target8 varchar,
    reference varchar,
    cropapplied varchar,
    valid varchar,
    operation varchar,
    target6 varchar,
    comments varchar,
    target10 varchar,
    adjuvant1 varchar,
    adjuvant2 varchar,
    product4 varchar,
    product3 varchar,
    product2 varchar,
    product1 varchar,
    target1 varchar,
    method varchar,
    updated varchar,
    cropyear varchar,
    pressure varchar,
    uniqueid varchar,
    target9 varchar,
    timing varchar,
    target7 varchar,
    target4 varchar,
    target5 varchar,
    target2 varchar,
    target3 varchar,
    stage varchar,
    totalrate varchar,
    target6_2 varchar,
    rate4 varchar,
    rate3 varchar,
    rate2 varchar,
    rate1 varchar,
    rateunit4 varchar,
    justify varchar,
    rateunit1 varchar,
    rateunit3 varchar,
    rateunit2 varchar,
    editedby varchar,
    notill varchar,
    cashcrop varchar,
    croprot varchar
);
GRANT SELECT on pesticides to nobody;

--- Storage of Operations
---
CREATE TABLE operations(
    valid date,
    uniqueid varchar,
    updated varchar,
    operation varchar,
    stabilizername varchar,
    zinc varchar,
    stabilizerused varchar,
    manuremethod varchar,
    productrate varchar,
    manurerateunits varchar,
    fertilizerform varchar,
    nitrogen varchar,
    manurerate varchar,
    currentph varchar,
    potash varchar,
    limerate varchar,
    planthybrid varchar,
    comments varchar,
    plantrate varchar,
    manurecomposition varchar,
    manuresource varchar,
    neutralindex varchar,
    terminatemethod varchar,
    stabilizer varchar,
    cropyear int,
    potassium varchar,
    fertilizerformulation varchar,
    sulfur varchar,
    phosphorus varchar,
    fertilizerapptype varchar,
    plantrateunits varchar,
    targetph varchar,
    calcium varchar,
    depth varchar,
    phosphate varchar,
    biomassdate2 date,
    magnesium varchar,
    iron varchar,
    biomassdate1 date,
    plantryemethod varchar,
    plantmaturity varchar,
    growthstage varchar,
    canopyheight varchar,
    fertilizercrop varchar,
    editedby varchar,
    hybridtrait varchar,
    plantbrand varchar,
    nitrogenelem varchar,
    phosphoruselem varchar,
    potassiumelem varchar,
    sulfurelem varchar,
    zincelem varchar,
    magnesiumelem varchar,
    calciumelem varchar,
    ironelem varchar,
    cashcrop varchar,
    croprot varchar,
    categories varchar
);
alter table operations owner to mesonet;
GRANT SELECT on operations to nobody;

CREATE TABLE metadata_master (
    leadpi character varying,
    co_leaders character varying,
    institutionname character varying,
    unit character varying,
    officialfarmname character varying,
    uniqueid character varying,
    nwlon character varying,
    nwlat character varying,
    swlon character varying,
    swlat character varying,
    selon character varying,
    selat character varying,
    nelon character varying,
    nelat character varying,
    rawlonlat character varying,
    latitude character varying,
    longitude character varying,
    state character varying,
    county character varying,
    city character varying,
    landscapeslope character varying,
    tiledepth character varying,
    tilespacing character varying,
    sitearea character varying,
    plotsize character varying,
    numberofplots character varying,
    establishmentyear character varying,
    y1forcap character varying,
    epaecoregionlevel4codeandname character varying,
    iemclimatesite character varying,
    additionalinformation character varying,
    pre_2011 character varying,
    notes2011 character varying,
    notes2012 character varying,
    notes2013 character varying,
    notes2014 character varying,
    notes2015 character varying
);

ALTER TABLE public.metadata_master OWNER TO mesonet;
GRANT SELECT ON TABLE public.metadata_master TO nobody;

--- ========================================================================
--- Storage of Soil Data
---
CREATE TABLE soil_data(
  uniqueid varchar(24),
  plotid varchar(24),
  depth varchar(24),
  varname varchar(24),
  year smallint,
  value varchar(32),
  subsample varchar(12),
  updated timestamptz default now(),
  sampledate date
);
CREATE INDEX soil_data_site_idx on soil_data(uniqueid);
CREATE UNIQUE index soil_data_idx on 
    soil_data(uniqueid, plotid, varname, year, depth, subsample, sampledate);

alter table soil_data owner to mesonet;
grant select on soil_data to nobody;

CREATE TABLE soil_data_log(
  uniqueid varchar(24),
  plotid varchar(24),
  depth varchar(24),
  varname varchar(24),
  year smallint,
  value varchar(32),
  subsample varchar(12),
  updated timestamptz default now(),
  sampledate date
);

CREATE OR REPLACE FUNCTION soil_insert_before_F()
RETURNS TRIGGER
 AS $BODY$
DECLARE
    result INTEGER; 
BEGIN
    result = (select count(*) from soil_data
                where uniqueid = new.uniqueid and plotid = new.plotid and
                varname = new.varname and year = new.year and
                depth = new.depth and subsample = new.subsample and 
                (value = new.value or (value is null and new.value is null))
               );

	-- Data is duplication, no-op
    IF result = 1 THEN
        RETURN null;
    END IF;

    result = (select count(*) from soil_data
                where uniqueid = new.uniqueid and plotid = new.plotid and
                varname = new.varname and year = new.year
                and depth = new.depth and subsample = new.subsample);

	-- Data is a new value!
    IF result = 1 THEN
    	UPDATE soil_data SET value = new.value, updated = now()
    	WHERE uniqueid = new.uniqueid and plotid = new.plotid and
                varname = new.varname and year = new.year and
                depth = new.depth and subsample = new.subsample;
        INSERT into soil_data_log SELECT * from soil_data WHERE
        		uniqueid = new.uniqueid and plotid = new.plotid and
                varname = new.varname and year = new.year and depth = new.depth
                and subsample = new.subsample;
        RETURN null;
    END IF;

    INSERT into soil_data_log (uniqueid, plotid, varname, year, depth, subsample, value)
    VALUES (new.uniqueid, new.plotid, new.varname, new.year, new.depth, new.subsample, new.value);

    -- The default branch is to return "NEW" which
    -- causes the original INSERT to go forward
    RETURN new;

END; $BODY$
LANGUAGE 'plpgsql' SECURITY DEFINER;


CREATE TRIGGER soil_insert_before_T
   before insert
   ON soil_data
   FOR EACH ROW
   EXECUTE PROCEDURE soil_insert_before_F();
  
GRANT SELECT on soil_data to nobody;



--- ==========================================================================
--- Storage of Agronomic Data
---
CREATE TABLE agronomic_data(
  uniqueid varchar(24),
  plotid varchar(24),
  varname varchar(24),
  year smallint,
  value varchar(32),
  updated timestamptz default now()
);
alter table agronomic_data owner to mesonet;
grant select on agronomic_data to nobody;

CREATE TABLE agronomic_data_log(
  uniqueid varchar(24),
  plotid varchar(24),
  varname varchar(24),
  year smallint,
  value varchar(32),
  updated timestamptz default now()
);

CREATE OR REPLACE FUNCTION agronomic_insert_before_F()
RETURNS TRIGGER
 AS $BODY$
DECLARE
    result INTEGER; 
BEGIN
    result = (select count(*) from agronomic_data
                where uniqueid = new.uniqueid and plotid = new.plotid and
                varname = new.varname and year = new.year and
                (value = new.value or (value is null and new.value is null))
               );

	-- Data is duplication, no-op
    IF result = 1 THEN
        RETURN null;
    END IF;

    result = (select count(*) from agronomic_data
                where uniqueid = new.uniqueid and plotid = new.plotid and
                varname = new.varname and year = new.year);

	-- Data is a new value!
    IF result = 1 THEN
    	UPDATE agronomic_data SET value = new.value, updated = now()
    	WHERE uniqueid = new.uniqueid and plotid = new.plotid and
                varname = new.varname and year = new.year;
        INSERT into agronomic_data_log SELECT * from agronomic_data WHERE
        		uniqueid = new.uniqueid and plotid = new.plotid and
                varname = new.varname and year = new.year;
        RETURN null;
    END IF;

    INSERT into agronomic_data_log (uniqueid, plotid, varname, year, value)
    VALUES (new.uniqueid, new.plotid, new.varname, new.year, new.value);

    -- The default branch is to return "NEW" which
    -- causes the original INSERT to go forward
    RETURN new;

END; $BODY$
LANGUAGE 'plpgsql' SECURITY DEFINER;


CREATE TRIGGER agronomic_insert_before_T
   before insert
   ON agronomic_data
   FOR EACH ROW
   EXECUTE PROCEDURE agronomic_insert_before_F();
  
CREATE UNIQUE index agronomic_data_idx on 
    agronomic_data(site, plotid, varname, year);
GRANT SELECT on agronomic_data to nobody;