-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version (
    version int,
    updated timestamptz
);
INSERT INTO iem_schema_manager_version VALUES (19, now());

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

-- synced from mesosite
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
    geom GEOMETRY (POINT, 4326),
    wigos varchar(64)
);
CREATE UNIQUE INDEX stations_idx ON stations (id, network);
CREATE UNIQUE INDEX stations_iemid_idx ON stations (iemid);
GRANT SELECT ON stations TO nobody;
GRANT ALL ON stations_iemid_seq TO nobody;
GRANT ALL ON stations TO mesonet, ldm;
GRANT ALL ON stations_iemid_seq TO mesonet, ldm;

CREATE TABLE sm_daily (
    station char(5),
    valid date,
    tair_c_avg real,
    tair_c_max real,
    tair_c_tmx timestamp with time zone,
    tair_c_min real,
    tair_c_tmn timestamp with time zone,
    -- Rainfall Total in inches
    rain_in_tot real,
    rain_in_tot_f character(1),
    rain_in_tot_qc real,

    -- Second Bucket
    rain_in_2_tot real,
    rain_in_2_tot_qc real,
    rain_in_2_tot_f character(1),

    winddir_d1_wvt real,
    dailyet real,
    t4_c_min real,
    t4_c_min_f character(1),
    t4_c_min_qc real,
    t4_c_avg real,
    t4_c_avg_f character(1),
    t4_c_avg_qc real,
    t4_c_max real,
    t4_c_max_f character(1),
    t4_c_max_qc real,
    vwc_12_avg real,
    vwc_24_avg real,
    vwc_50_avg real,
    ec12 real,
    ec24 real,
    ec50 real,
    t12_c_avg real,
    t24_c_avg real,
    t50_c_avg real,
    vwc4 real,
    encrh_avg real,
    tair_c_avg_f character(1),
    tair_c_avg_qc real,
    tair_c_max_f character(1),
    tair_c_max_qc real,
    tair_c_tmx_f character(1),
    tair_c_tmx_qc timestamp with time zone,
    tair_c_min_f character(1),
    tair_c_min_qc real,
    tair_c_tmn_f character(1),
    tair_c_tmn_qc timestamp with time zone,
    winddir_d1_wvt_f character(1),
    winddir_d1_wvt_qc real,
    ws_mph_tmx timestamp with time zone,
    ws_mph_tmx_f character(1),
    ws_mph_tmx_qc timestamp with time zone,
    dailyet_f character(1),
    dailyet_qc real,
    vwc_12_avg_f character(1),
    vwc_12_avg_qc real,
    vwc_24_avg_f character(1),
    vwc_24_avg_qc real,
    vwc_50_avg_f character(1),
    vwc_50_avg_qc real,
    ec12_f character(1),
    ec12_qc real,
    ec24_f character(1),
    ec24_qc real,
    ec50_f character(1),
    ec50_qc real,
    t12_c_avg_f character(1),
    t12_c_avg_qc real,
    t24_c_avg_f character(1),
    t24_c_avg_qc real,
    t50_c_avg_f character(1),
    t50_c_avg_qc real,
    vwc4_f character(1),
    vwc4_qc real,
    encrh_avg_f character(1),
    encrh_avg_qc real,
    vwc12 real,
    vwc12_qc real,
    vwc12_f char(1),
    vwc24 real,
    vwc24_qc real,
    vwc24_f char(1),
    vwc50 real,
    vwc50_qc real,
    vwc50_f char(1),
    lwmv_1 real,
    lwmv_1_qc real,
    lwmv_1_f character(1),
    lwmv_2 real,
    lwmv_2_qc real,
    lwmv_2_f character(1),
    lwmdry_1_tot real,
    lwmdry_1_tot_qc real,
    lwmdry_1_tot_f character(1),
    lwmcon_1_tot real,
    lwmcon_1_tot_qc real,
    lwmcon_1_tot_f character(1),
    lwmwet_1_tot real,
    lwmwet_1_tot_qc real,
    lwmwet_1_tot_f character(1),
    lwmdry_2_tot real,
    lwmdry_2_tot_qc real,
    lwmdry_2_tot_f character(1),
    lwmcon_2_tot real,
    lwmcon_2_tot_qc real,
    lwmcon_2_tot_f character(1),
    lwmwet_2_tot real,
    lwmwet_2_tot_qc real,
    lwmwet_2_tot_f character(1),
    bpres_avg real,
    bpres_avg_qc real,
    bpres_avg_f character(1),
    rh_avg real,
    rh_avg_qc real,
    rh_avg_f character(1),
    ws_mph real,
    ws_mph_qc real,
    ws_mph_f character(1),
    etapples real,
    etapples_qc real,
    etapples_f character(1),
    ws_mph_max real,
    ws_mph_max_qc real,
    ws_mph_max_f character(1),

    lwmdry_lowbare_tot real,
    lwmdry_lowbare_tot_qc real,
    lwmdry_lowbare_tot_f char(1),
    lwmcon_lowbare_tot real,
    lwmcon_lowbare_tot_qc real,
    lwmcon_lowbare_tot_f char(1),
    lwmwet_lowbare_tot real,
    lwmwet_lowbare_tot_qc real,
    lwmwet_lowbare_tot_f char(1),
    lwmdry_highbare_tot real,
    lwmdry_highbare_tot_qc real,
    lwmdry_highbare_tot_f char(1),
    lwmcon_highbare_tot real,
    lwmcon_highbare_tot_qc real,
    lwmcon_highbare_tot_f char(1),
    lwmwet_highbare_tot real,
    lwmwet_highbare_tot_qc real,
    lwmwet_highbare_tot_f char(1),
    obs_count int,

    -- SoilVue  EC Values
    sv_ec2 real, sv_ec2_qc real, sv_ec2_f char(1),
    sv_ec4 real, sv_ec4_qc real, sv_ec4_f char(1),
    sv_ec8 real, sv_ec8_qc real, sv_ec8_f char(1),
    sv_ec12 real, sv_ec12_qc real, sv_ec12_f char(1),
    sv_ec14 real, sv_ec14_qc real, sv_ec14_f char(1),
    sv_ec16 real, sv_ec16_qc real, sv_ec16_f char(1),
    sv_ec20 real, sv_ec20_qc real, sv_ec20_f char(1),
    sv_ec24 real, sv_ec24_qc real, sv_ec24_f char(1),
    sv_ec28 real, sv_ec28_qc real, sv_ec28_f char(1),
    sv_ec30 real, sv_ec30_qc real, sv_ec30_f char(1),
    sv_ec32 real, sv_ec32_qc real, sv_ec32_f char(1),
    sv_ec36 real, sv_ec36_qc real, sv_ec36_f char(1),
    sv_ec40 real, sv_ec40_qc real, sv_ec40_f char(1),
    sv_ec42 real, sv_ec42_qc real, sv_ec42_f char(1),
    sv_ec52 real, sv_ec52_qc real, sv_ec52_f char(1),
    -- SoilVue Temp Values
    sv_t2 real, sv_t2_qc real, sv_t2_f char(1),
    sv_t4 real, sv_t4_qc real, sv_t4_f char(1),
    sv_t8 real, sv_t8_qc real, sv_t8_f char(1),
    sv_t12 real, sv_t12_qc real, sv_t12_f char(1),
    sv_t14 real, sv_t14_qc real, sv_t14_f char(1),
    sv_t16 real, sv_t16_qc real, sv_t16_f char(1),
    sv_t20 real, sv_t20_qc real, sv_t20_f char(1),
    sv_t24 real, sv_t24_qc real, sv_t24_f char(1),
    sv_t28 real, sv_t28_qc real, sv_t28_f char(1),
    sv_t30 real, sv_t30_qc real, sv_t30_f char(1),
    sv_t32 real, sv_t32_qc real, sv_t32_f char(1),
    sv_t36 real, sv_t36_qc real, sv_t36_f char(1),
    sv_t40 real, sv_t40_qc real, sv_t40_f char(1),
    sv_t42 real, sv_t42_qc real, sv_t42_f char(1),
    sv_t52 real, sv_t52_qc real, sv_t52_f char(1),
    -- SoilVue VWC Values
    sv_vwc2 real, sv_vwc2_qc real, sv_vwc2_f char(1),
    sv_vwc4 real, sv_vwc4_qc real, sv_vwc4_f char(1),
    sv_vwc8 real, sv_vwc8_qc real, sv_vwc8_f char(1),
    sv_vwc12 real, sv_vwc12_qc real, sv_vwc12_f char(1),
    sv_vwc14 real, sv_vwc14_qc real, sv_vwc14_f char(1),
    sv_vwc16 real, sv_vwc16_qc real, sv_vwc16_f char(1),
    sv_vwc20 real, sv_vwc20_qc real, sv_vwc20_f char(1),
    sv_vwc24 real, sv_vwc24_qc real, sv_vwc24_f char(1),
    sv_vwc28 real, sv_vwc28_qc real, sv_vwc28_f char(1),
    sv_vwc30 real, sv_vwc30_qc real, sv_vwc30_f char(1),
    sv_vwc32 real, sv_vwc32_qc real, sv_vwc32_f char(1),
    sv_vwc36 real, sv_vwc36_qc real, sv_vwc36_f char(1),
    sv_vwc40 real, sv_vwc40_qc real, sv_vwc40_f char(1),
    sv_vwc42 real, sv_vwc42_qc real, sv_vwc42_f char(1),
    sv_vwc52 real, sv_vwc52_qc real, sv_vwc52_f char(1),

    -- Solar Radiation kJ
    slrkj_tot real,
    slrkj_tot_f char(1),
    slrkj_tot_qc real
);
ALTER TABLE sm_daily OWNER TO mesonet;
CREATE UNIQUE INDEX sm_daily_idx ON sm_daily (station, valid);
GRANT SELECT ON sm_daily TO nobody;

--- Soil Moisture Stations
CREATE TABLE sm_hourly (
    station char(5),
    valid timestamp with time zone,

    -- max air temp
    tair_c_max real,
    tair_c_max_qc real,
    tair_c_max_f char(1),

    -- min air temp
    tair_c_min real,
    tair_c_min_qc real,
    tair_c_min_f char(1),

    -- average air temp over the hour
    tair_c_avg real,
    tair_c_avg_f character(1),
    tair_c_avg_qc real,

    -- relative humidity, average over the hour
    rh_avg real,
    rh_avg_f character(1),
    rh_avg_qc real,

    -- Precip in inches
    rain_in_tot real,
    rain_in_tot_f character(1),
    rain_in_tot_qc real,
    -- Second Bucket
    rain_in_2_tot real,
    rain_in_2_tot_qc real,
    rain_in_2_tot_f character(1),

    -- Tracked at two stations
    etapples real,
    etapples_qc real,
    etapples_f char(1),

    -- Tracked at most sites
    etalfalfa real,
    etalfalfa_f character(1),
    etalfalfa_qc real,

    -- Wind speed, sample
    ws_mph real,
    ws_mph_f character(1),
    ws_mph_qc real,

    -- Wind direction
    winddir_d1_wvt real,
    winddir_d1_wvt_f character(1),
    winddir_d1_wvt_qc real,

    -- Soil Temperature at 4 inches, old probes
    t4_c_avg real,
    t4_c_avg_f character(1),
    t4_c_avg_qc real,

    vwc_12_avg real,
    vwc_24_avg real,
    vwc_50_avg real,
    ec12 real,
    ec24 real,
    ec50 real,
    t12_c_avg real,
    t24_c_avg real,
    t50_c_avg real,
    vwc4 real,
    ws_mph_max real,
    ws_mph_tmx timestamptz,
    encrh_avg real,
    battv_min real,

    vwc_12_avg_f character(1),
    vwc_12_avg_qc real,
    vwc_24_avg_f character(1),
    vwc_24_avg_qc real,
    vwc_50_avg_f character(1),
    vwc_50_avg_qc real,
    ec12_f character(1),
    ec12_qc real,
    ec24_f character(1),
    ec24_qc real,
    ec50_f character(1),
    ec50_qc real,
    t12_c_avg_f character(1),
    t12_c_avg_qc real,
    t24_c_avg_f character(1),
    t24_c_avg_qc real,
    t50_c_avg_f character(1),
    t50_c_avg_qc real,
    vwc4_f character(1),
    vwc4_qc real,
    battv_min_f character(1),
    battv_min_qc real,
    ws_mph_max_f character(1),
    ws_mph_max_qc real,
    ws_mph_tmx_f character(1),
    ws_mph_tmx_qc timestamp with time zone,
    encrh_avg_f character(1),
    encrh_avg_qc real,

    vwc12 real,
    vwc12_qc real,
    vwc12_f char(1),
    vwc24 real,
    vwc24_qc real,
    vwc24_f char(1),
    vwc50 real,
    vwc50_qc real,
    vwc50_f char(1),
    lwmv_1 real,
    lwmv_1_qc real,
    lwmv_1_f character(1),
    lwmv_2 real,
    lwmv_2_qc real,
    lwmv_2_f character(1),
    lwmdry_1_tot real,
    lwmdry_1_tot_qc real,
    lwmdry_1_tot_f character(1),
    lwmcon_1_tot real,
    lwmcon_1_tot_qc real,
    lwmcon_1_tot_f character(1),
    lwmwet_1_tot real,
    lwmwet_1_tot_qc real,
    lwmwet_1_tot_f character(1),
    lwmdry_2_tot real,
    lwmdry_2_tot_qc real,
    lwmdry_2_tot_f character(1),
    lwmcon_2_tot real,
    lwmcon_2_tot_qc real,
    lwmcon_2_tot_f character(1),
    lwmwet_2_tot real,
    lwmwet_2_tot_qc real,
    lwmwet_2_tot_f character(1),
    bpres_avg real,
    bpres_avg_qc real,
    bpres_avg_f character(1),

    -- SoilVue  EC Values
    sv_ec2 real, sv_ec2_qc real, sv_ec2_f char(1),
    sv_ec4 real, sv_ec4_qc real, sv_ec4_f char(1),
    sv_ec8 real, sv_ec8_qc real, sv_ec8_f char(1),
    sv_ec12 real, sv_ec12_qc real, sv_ec12_f char(1),
    sv_ec14 real, sv_ec14_qc real, sv_ec14_f char(1),
    sv_ec16 real, sv_ec16_qc real, sv_ec16_f char(1),
    sv_ec20 real, sv_ec20_qc real, sv_ec20_f char(1),
    sv_ec24 real, sv_ec24_qc real, sv_ec24_f char(1),
    sv_ec28 real, sv_ec28_qc real, sv_ec28_f char(1),
    sv_ec30 real, sv_ec30_qc real, sv_ec30_f char(1),
    sv_ec32 real, sv_ec32_qc real, sv_ec32_f char(1),
    sv_ec36 real, sv_ec36_qc real, sv_ec36_f char(1),
    sv_ec40 real, sv_ec40_qc real, sv_ec40_f char(1),
    sv_ec42 real, sv_ec42_qc real, sv_ec42_f char(1),
    sv_ec52 real, sv_ec52_qc real, sv_ec52_f char(1),
    -- SoilVue Temp Values
    sv_t2 real, sv_t2_qc real, sv_t2_f char(1),
    sv_t4 real, sv_t4_qc real, sv_t4_f char(1),
    sv_t8 real, sv_t8_qc real, sv_t8_f char(1),
    sv_t12 real, sv_t12_qc real, sv_t12_f char(1),
    sv_t14 real, sv_t14_qc real, sv_t14_f char(1),
    sv_t16 real, sv_t16_qc real, sv_t16_f char(1),
    sv_t20 real, sv_t20_qc real, sv_t20_f char(1),
    sv_t24 real, sv_t24_qc real, sv_t24_f char(1),
    sv_t28 real, sv_t28_qc real, sv_t28_f char(1),
    sv_t30 real, sv_t30_qc real, sv_t30_f char(1),
    sv_t32 real, sv_t32_qc real, sv_t32_f char(1),
    sv_t36 real, sv_t36_qc real, sv_t36_f char(1),
    sv_t40 real, sv_t40_qc real, sv_t40_f char(1),
    sv_t42 real, sv_t42_qc real, sv_t42_f char(1),
    sv_t52 real, sv_t52_qc real, sv_t52_f char(1),
    -- SoilVue VWC Values
    sv_vwc2 real, sv_vwc2_qc real, sv_vwc2_f char(1),
    sv_vwc4 real, sv_vwc4_qc real, sv_vwc4_f char(1),
    sv_vwc8 real, sv_vwc8_qc real, sv_vwc8_f char(1),
    sv_vwc12 real, sv_vwc12_qc real, sv_vwc12_f char(1),
    sv_vwc14 real, sv_vwc14_qc real, sv_vwc14_f char(1),
    sv_vwc16 real, sv_vwc16_qc real, sv_vwc16_f char(1),
    sv_vwc20 real, sv_vwc20_qc real, sv_vwc20_f char(1),
    sv_vwc24 real, sv_vwc24_qc real, sv_vwc24_f char(1),
    sv_vwc28 real, sv_vwc28_qc real, sv_vwc28_f char(1),
    sv_vwc30 real, sv_vwc30_qc real, sv_vwc30_f char(1),
    sv_vwc32 real, sv_vwc32_qc real, sv_vwc32_f char(1),
    sv_vwc36 real, sv_vwc36_qc real, sv_vwc36_f char(1),
    sv_vwc40 real, sv_vwc40_qc real, sv_vwc40_f char(1),
    sv_vwc42 real, sv_vwc42_qc real, sv_vwc42_f char(1),
    sv_vwc52 real, sv_vwc52_qc real, sv_vwc52_f char(1),

    lwmdry_lowbare_tot real,
    lwmdry_lowbare_tot_qc real,
    lwmdry_lowbare_tot_f char(1),
    lwmcon_lowbare_tot real,
    lwmcon_lowbare_tot_qc real,
    lwmcon_lowbare_tot_f char(1),
    lwmwet_lowbare_tot real,
    lwmwet_lowbare_tot_qc real,
    lwmwet_lowbare_tot_f char(1),
    lwmdry_highbare_tot real,
    lwmdry_highbare_tot_qc real,
    lwmdry_highbare_tot_f char(1),
    lwmcon_highbare_tot real,
    lwmcon_highbare_tot_qc real,
    lwmcon_highbare_tot_f char(1),
    lwmwet_highbare_tot real,
    lwmwet_highbare_tot_qc real,
    lwmwet_highbare_tot_f char(1),
    obs_count int,

    -- Solar Radiation
    slrkj_tot real,
    slrkj_tot_f char(1),
    slrkj_tot_qc real
);
ALTER TABLE sm_hourly OWNER TO mesonet;
CREATE UNIQUE INDEX sm_hourly_idx ON sm_hourly (station, valid);
GRANT SELECT ON sm_hourly TO nobody;

--- Soil Moisture Stations
CREATE TABLE sm_minute (
    station char(5),
    valid timestamp with time zone,

    -- Air Temperature
    tair_c_avg real,
    tair_c_avg_qc real,
    tair_c_avg_f char(1),

    -- Relative Humidity
    rh_avg real,
    rh_avg_qc real,
    rh_avg_f char(1),

    -- Solar Rad total kJ over 1 minute
    slrkj_tot real,
    slrkj_tot_qc real,
    slrkj_tot_f char(1),

    -- Precip total
    rain_in_tot real,
    rain_in_tot_qc real,
    rain_in_tot_f char(1),

    -- Precip total from second bucket
    rain_in_2_tot real,
    rain_in_2_tot_qc real,
    rain_in_2_tot_f char(1),

    -- 4 inch soil
    t4_c_avg real,
    t4_c_avg_qc real,
    t4_c_avg_f char(1),

    -- wind speed mph
    ws_mph real,
    ws_mph_qc real,
    ws_mph_f char(1),

    -- wind speed max
    ws_mph_max real,
    ws_mph_max_qc real,
    ws_mph_max_f char(1),

    -- wind direction
    winddir_d1_wvt real,
    winddir_d1_wvt_qc real,
    winddir_d1_wvt_f char(1),

    -- 4 inch VWC
    vwc4 real,
    vwc4_qc real,
    vwc4_f char(1),

    -- 12 inch VWC
    vwc12 real,
    vwc12_qc real,
    vwc12_f char(1),

    -- 24 inch VWC
    vwc24 real,
    vwc24_qc real,
    vwc24_f char(1),

    -- 50 inch VWC
    vwc50 real,
    vwc50_qc real,
    vwc50_f char(1),

    -- 12 inch temp
    t12_c_avg real,
    t12_c_avg_qc real,
    t12_c_avg_f char(1),

    -- 24 inch temp
    t24_c_avg real,
    t24_c_avg_qc real,
    t24_c_avg_f char(1),

    -- 30 inch temp
    t30_c_avg real,
    t30_c_avg_qc real,
    t30_c_avg_f char(1),

    -- 40 inch temp
    t40_c_avg real,
    t40_c_avg_qc real,
    t40_c_avg_f char(1),

    -- 50 inch temp
    t50_c_avg real,
    t50_c_avg_qc real,
    t50_c_avg_f char(1),

    -- SoilVue  EC Values
    sv_ec2 real, sv_ec2_qc real, sv_ec2_f char(1),
    sv_ec4 real, sv_ec4_qc real, sv_ec4_f char(1),
    sv_ec8 real, sv_ec8_qc real, sv_ec8_f char(1),
    sv_ec12 real, sv_ec12_qc real, sv_ec12_f char(1),
    sv_ec14 real, sv_ec14_qc real, sv_ec14_f char(1),
    sv_ec16 real, sv_ec16_qc real, sv_ec16_f char(1),
    sv_ec20 real, sv_ec20_qc real, sv_ec20_f char(1),
    sv_ec24 real, sv_ec24_qc real, sv_ec24_f char(1),
    sv_ec28 real, sv_ec28_qc real, sv_ec28_f char(1),
    sv_ec30 real, sv_ec30_qc real, sv_ec30_f char(1),
    sv_ec32 real, sv_ec32_qc real, sv_ec32_f char(1),
    sv_ec36 real, sv_ec36_qc real, sv_ec36_f char(1),
    sv_ec40 real, sv_ec40_qc real, sv_ec40_f char(1),
    sv_ec42 real, sv_ec42_qc real, sv_ec42_f char(1),
    sv_ec52 real, sv_ec52_qc real, sv_ec52_f char(1),
    -- SoilVue Temp Values
    sv_t2 real, sv_t2_qc real, sv_t2_f char(1),
    sv_t4 real, sv_t4_qc real, sv_t4_f char(1),
    sv_t8 real, sv_t8_qc real, sv_t8_f char(1),
    sv_t12 real, sv_t12_qc real, sv_t12_f char(1),
    sv_t14 real, sv_t14_qc real, sv_t14_f char(1),
    sv_t16 real, sv_t16_qc real, sv_t16_f char(1),
    sv_t20 real, sv_t20_qc real, sv_t20_f char(1),
    sv_t24 real, sv_t24_qc real, sv_t24_f char(1),
    sv_t28 real, sv_t28_qc real, sv_t28_f char(1),
    sv_t30 real, sv_t30_qc real, sv_t30_f char(1),
    sv_t32 real, sv_t32_qc real, sv_t32_f char(1),
    sv_t36 real, sv_t36_qc real, sv_t36_f char(1),
    sv_t40 real, sv_t40_qc real, sv_t40_f char(1),
    sv_t42 real, sv_t42_qc real, sv_t42_f char(1),
    sv_t52 real, sv_t52_qc real, sv_t52_f char(1),
    -- SoilVue VWC Values
    sv_vwc2 real, sv_vwc2_qc real, sv_vwc2_f char(1),
    sv_vwc4 real, sv_vwc4_qc real, sv_vwc4_f char(1),
    sv_vwc8 real, sv_vwc8_qc real, sv_vwc8_f char(1),
    sv_vwc12 real, sv_vwc12_qc real, sv_vwc12_f char(1),
    sv_vwc14 real, sv_vwc14_qc real, sv_vwc14_f char(1),
    sv_vwc16 real, sv_vwc16_qc real, sv_vwc16_f char(1),
    sv_vwc20 real, sv_vwc20_qc real, sv_vwc20_f char(1),
    sv_vwc24 real, sv_vwc24_qc real, sv_vwc24_f char(1),
    sv_vwc28 real, sv_vwc28_qc real, sv_vwc28_f char(1),
    sv_vwc30 real, sv_vwc30_qc real, sv_vwc30_f char(1),
    sv_vwc32 real, sv_vwc32_qc real, sv_vwc32_f char(1),
    sv_vwc36 real, sv_vwc36_qc real, sv_vwc36_f char(1),
    sv_vwc40 real, sv_vwc40_qc real, sv_vwc40_f char(1),
    sv_vwc42 real, sv_vwc42_qc real, sv_vwc42_f char(1),
    sv_vwc52 real, sv_vwc52_qc real, sv_vwc52_f char(1),

    lwmv_1 real,
    lwmv_1_qc real,
    lwmv_1_f character(1),
    lwmv_2 real,
    lwmv_2_qc real,
    lwmv_2_f character(1),
    lwmdry_1_tot real,
    lwmdry_1_tot_qc real,
    lwmdry_1_tot_f character(1),
    lwmcon_1_tot real,
    lwmcon_1_tot_qc real,
    lwmcon_1_tot_f character(1),
    lwmwet_1_tot real,
    lwmwet_1_tot_qc real,
    lwmwet_1_tot_f character(1),
    lwmdry_2_tot real,
    lwmdry_2_tot_qc real,
    lwmdry_2_tot_f character(1),
    lwmcon_2_tot real,
    lwmcon_2_tot_qc real,
    lwmcon_2_tot_f character(1),
    lwmwet_2_tot real,
    lwmwet_2_tot_qc real,
    lwmwet_2_tot_f character(1),

    lwmdry_lowbare_tot real,
    lwmdry_lowbare_tot_qc real,
    lwmdry_lowbare_tot_f char(1),
    lwmcon_lowbare_tot real,
    lwmcon_lowbare_tot_qc real,
    lwmcon_lowbare_tot_f char(1),
    lwmwet_lowbare_tot real,
    lwmwet_lowbare_tot_qc real,
    lwmwet_lowbare_tot_f char(1),
    lwmdry_highbare_tot real,
    lwmdry_highbare_tot_qc real,
    lwmdry_highbare_tot_f char(1),
    lwmcon_highbare_tot real,
    lwmcon_highbare_tot_qc real,
    lwmcon_highbare_tot_f char(1),
    lwmwet_highbare_tot real,
    lwmwet_highbare_tot_qc real,
    lwmwet_highbare_tot_f char(1),

    bp_mb real,
    bp_mb_qc real,
    bp_mb_f char(1),
    duration smallint DEFAULT 1
) PARTITION BY RANGE (valid);
ALTER TABLE sm_minute OWNER TO mesonet;
GRANT SELECT ON sm_minute TO nobody;
GRANT ALL ON sm_minute TO ldm;
CREATE INDEX ON sm_minute (station, valid);


DO
$do$
declare
     year int;
begin
    for year in 2014..2030
    loop
        execute format($f$
            create table sm_minute_%s partition of sm_minute
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
        $f$, year, year, year + 1);
        execute format($f$
            GRANT ALL on sm_minute_%s to mesonet,ldm
        $f$, year);
        execute format($f$
            GRANT SELECT on sm_minute_%s to nobody
        $f$, year);
    end loop;
end;
$do$;

CREATE TABLE daily (
    station character varying(7),
    valid date,
    c11 real,
    c11_f character(1),
    c12 real,
    c12_f character(1),
    c20 real,
    c20_f character(1),
    c30 real,
    c30_f character(1),
    c40 real,
    c40_f character(1),
    c80 real,
    c80_f character(1),
    c90 real,
    c90_f character(1),
    c70 real,
    c70_f character(1),
    c110 real,
    c110_f character(1),
    c111 real,
    c111_f character(1),
    c509 real,
    c509_f character(1),
    c510 real,
    c510_f character(1),
    c1300 real,
    c1300_f character(1),
    c1301 real,
    c1301_f character(1),
    c900 real,
    c900_f character(1),
    c529 real,
    c529_f character(1),
    c530 real,
    c530_f character(1),
    c30h real,
    c30h_f character(1),
    c30l real,
    c30l_f character(1),
    c930 real,
    c930_f character(1)
);
ALTER TABLE daily OWNER TO mesonet;
CREATE UNIQUE INDEX daily_idx ON daily USING btree (station, valid);
GRANT SELECT ON daily TO nobody;

CREATE TABLE hourly (
    station character varying(7),
    valid timestamp with time zone,
    c100 real,
    c100_f character(1),
    c200 real,
    c200_f character(1),
    c300 real,
    c300_f character(1),
    c400 real,
    c400_f character(1),
    c500 real,
    c500_f character(1),
    c600 real,
    c600_f character(1),
    c700 real,
    c700_f character(1),
    c800 real,
    c800_f character(1),
    c900 real,
    c900_f character(1)
);
ALTER TABLE hourly OWNER TO mesonet;
CREATE UNIQUE INDEX hourly_idx ON hourly USING btree (station, valid);
GRANT SELECT ON hourly TO nobody;

CREATE TABLE sm_inversion (
    station varchar(5),
    valid timestamptz,
    tair_15_c_avg real,
    tair_15_c_avg_qc real,
    tair_15_c_avg_f char(1),
    tair_5_c_avg real,
    tair_5_c_avg_qc real,
    tair_5_c_avg_f char(1),
    tair_10_c_avg real,
    tair_10_c_avg_qc real,
    tair_10_c_avg_f char(1),

    ws_ms_avg real,
    ws_ms_avg_qc real,
    ws_ms_avg_f char(1),
    ws_ms_max real,
    ws_ms_max_qc real,
    ws_ms_max_f char(1),
    duration smallint DEFAULT 1
);
ALTER TABLE sm_inversion OWNER TO mesonet;
GRANT SELECT ON sm_inversion TO nobody;
CREATE UNIQUE INDEX sm_inversion_idx ON sm_inversion (station, valid);

--- Clever hack to map data around!
CREATE OR REPLACE VIEW alldata AS
SELECT
    station,
    valid,
    winddir_d1_wvt AS drct,
    rain_in_tot AS phour,
    rh_avg AS relh,
    ws_mph * 1.15 AS sknt,
    c2f(tair_c_avg) AS tmpf
FROM sm_hourly;
GRANT SELECT ON alldata TO nobody;
