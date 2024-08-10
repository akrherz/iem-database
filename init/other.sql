-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
    version int,
    updated timestamptz);
INSERT into iem_schema_manager_version values (15, now());

-- Purple Air Data
create table purpleair(
    station varchar(6),
    valid timestamptz,
    current_temp_f smallint,
    current_humidity smallint,
    current_dewpoint_f smallint,
    pressure real,
    pm2_5_aqi_b smallint,
    pm1_0_cf_1_b real,
    p_0_3_um_b real,
    pm2_5_cf_1_b real,
    p_0_5_um_b real,
    pm10_0_cf_1_b real,
    p_1_0_um_b real,
    pm1_0_atm_b real,
    p_2_5_um_b real,
    pm2_5_atm_b real,
    p_5_0_um_b real,
    pm10_0_atm_b real,
    p_10_0_um_b real,
    pm2_5_aqi smallint,
    pm1_0_cf_1 real,
    p_0_3_um real,
    pm2_5_cf_1 real,
    p_0_5_um real,
    pm10_0_cf_1 real,
    p_1_0_um real,
    pm1_0_atm real,
    p_2_5_um real,
    pm2_5_atm real,
    p_5_0_um real,
    pm10_0_atm real,
    p_10_0_um real
);
alter table purpleair owner to mesonet;
grant select on purpleair to nobody;

---
--- Stuart Smith Park Hydrology Learning Lab
---
CREATE TABLE ss_bubbler(
  valid timestamptz,
  field varchar(32),
  value real,
  units varchar(32)
);
alter table ss_bubbler owner to mesonet;
CREATE INDEX ss_bubbler_idx on ss_bubbler(valid);
GRANT SELECT on ss_bubbler to nobody;

---
--- Stuart Smith Park Hydrology Learning Lab
---
CREATE TABLE ss_logger_data(
  id int,
  site_serial int,
  valid timestamptz,
  ch1_data_p real,
  ch2_data_p real,
  ch3_data_p real,
  ch4_data_p real,
  ch1_data_t real,
  ch2_data_t real,
  ch3_data_t real,
  ch4_data_t real,
  ch1_data_c real,
  ch2_data_c real,
  ch3_data_c real,
  ch4_data_c real
);
alter table ss_logger_data owner to mesonet;
CREATE INDEX ss_logger_data_idx on ss_logger_data(valid);
GRANT SELECT on ss_logger_data to nobody;

CREATE TABLE asi_data (
  station char(7),
  valid timestamp with time zone,
  ch1avg real,
  ch1sd  real,
  ch1max real,
  ch1min real,
  ch2avg real,
  ch2sd  real,
  ch2max real,
  ch2min real,
  ch3avg real,
  ch3sd  real,
  ch3max real,
  ch3min real,
  ch4avg real,
  ch4sd  real,
  ch4max real,
  ch4min real,
  ch5avg real,
  ch5sd  real,
  ch5max real,
  ch5min real,
  ch6avg real,
  ch6sd  real,
  ch6max real,
  ch6min real,
  ch7avg real,
  ch7sd  real,
  ch7max real,
  ch7min real,
  ch8avg real,
  ch8sd  real,
  ch8max real,
  ch8min real,
  ch9avg real,
  ch9sd  real,
  ch9max real,
  ch9min real,
  ch10avg real,
  ch10sd  real,
  ch10max real,
  ch10min real,
  ch11avg real,
  ch11sd  real,
  ch11max real,
  ch11min real,
  ch12avg real,
  ch12sd  real,
  ch12max real,
  ch12min real);
ALTER TABLE asi_data OWNER to mesonet;
CREATE unique index asi_data_idx on asi_data(station, valid);
GRANT SELECT on asi_data to nobody;

CREATE TABLE alldata (
    station varchar(64),
    valid timestamp with time zone,
    tmpf real,
    dwpf real,
    drct real,
    sknt real,
    gust real,
    relh real,
    alti real,
    pcpncnt real,
    pday real,
    pmonth real,
    srad real,
    tsoil_4in_f real,
    tsoil_8in_f real,
    tsoil_16in_f real,
    tsoil_20in_f real,
    tsoil_32in_f real,
    tsoil_40in_f real,
    tsoil_64in_f real,
    tsoil_128in_f real,
    skyc1 char(3),
    skyc2 char(3),
    skyc3 char(3),
    skyc4 char(3),
    skyl1 int,
    skyl2 int,
    skyl3 int,
    skyl4 int,
    srad_1h_j real
) PARTITION by range(valid);
ALTER TABLE alldata OWNER to mesonet;
GRANT ALL on alldata to ldm;
GRANT SELECT on alldata to nobody;

do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2003..2030
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
            GRANT SELECT on %s to nobody
        $f$, mytable);
        -- Indices
        execute format($f$
            CREATE INDEX %s_idx on %s(station, valid)
        $f$, mytable, mytable);
    end loop;
end;
$do$;

-- -----------------------------------

CREATE TABLE flux_data(
station            character varying(10),   
 valid             timestamp with time zone,
 fc_wpl            real,
 le_wpl            real,
 hs                real,
 tau               real,
 u_star            real,
 cov_uz_uz         real,
 cov_uz_ux         real,
 cov_uz_uy         real,
 cov_uz_co2        real,
 cov_uz_h2o        real,
 cov_uz_ts         real,
 cov_ux_ux         real,
 cov_ux_uy         real,
 cov_ux_co2        real,
 cov_ux_h2o        real,
 cov_ux_ts         real,
 cov_uy_uy         real,
 cov_uy_co2        real,
 cov_uy_h2o        real,
 cov_uy_ts         real,
 cov_co2_co2       real,
 cov_h2o_h2o       real,
 cov_ts_ts         real,
 ux_avg            real,
 uy_avg            real,
 uz_avg            real,
 co2_avg           real,
 h2o_avg           real,
 ts_avg            real,
 rho_a_avg         real,
 press_avg         real,
 panel_temp_avg    real,
 wnd_dir_compass   real,
 wnd_dir_csat3     real,
 wnd_spd           real,
 rslt_wnd_spd      real,
 batt_volt_avg     real,
 std_wnd_dir       real,
 fc_irga           real,
 le_irga           real,
 co2_wpl_le        real,
 co2_wpl_h         real,
 h2o_wpl_le        real,
 h2o_wpl_h         real,
 h2o_hmp_avg       real,
 t_hmp_avg         real,
 par_avg           real,
 solrad_avg        real,
 rain_tot          real,
 shf1_avg          real,
 shf2_avg          real,
 soiltc1_avg       real,
 soiltc2_avg       real,
 soiltc3_avg       real,
 soiltc4_avg       real,
 irt_can_avg       real,
 irt_cb_avg        real,
 incoming_sw       real,
 outgoing_sw       real,
 incoming_lw_tcor  real,
 terrest_lw_tcor   real,
 rn_short_avg      real,
 rn_long_avg       real,
 rn_total_avg      real,
 rh_hmp_avg        real,
 temps_c1_avg      real,
 corrtemp_avg      real,
 rn_total_tcor_avg real,
 incoming_lw_avg   real,
 terrestrial_lw_avg real,
 wfv1_avg          real,
 n_tot real,
 csat_warnings real,
 irga_warnings real,
 del_t_f_tot real,
 track_f_tot real,
 amp_h_f_tot real,
 amp_l_f_tot real,
 chopper_f_tot real,
 detector_f_tot real,
 pll_f_tot real,
 sync_f_tot real, 
 agc_avg real, 
 solarrad_mv_avg real, 
 solarrad_w_avg real, 
 par_mv_avg real, 
 par_den_avg real,
 surftc_avg real, 
 temp_c1_avg real,
 temp_k1_avg real,
 irr_can_corr_avg real,
 irr_body_avg real,
 vwc real,
 ec real,
 t real,
 p real,
 pa real,
 vr real,
 lithium_bv_avg real,
 solarrad_mj_tot real,
 par_tot_tot real
) PARTITION by range(valid);
ALTER TABLE flux_data OWNER to mesonet;
GRANT ALL on flux_data to ldm;
GRANT SELECT on flux_data to nobody;

do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2002..2030
    loop
        mytable := format($f$flux%s$f$, year);
        execute format($f$
            create table %s partition of flux_data
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
            CREATE INDEX %s_idx on %s(station, valid)
        $f$, mytable, mytable);
    end loop;
end;
$do$;

--
-- Storage of ISU FEEL Data
CREATE TABLE feel_data_daily(
        valid date UNIQUE,
        AirTemp_Max real,
        AirTemp_Min real,
        Rain_Tot real,
        Windspeed_Max real,
        SolarRad_MJ_Tot real
);
alter table feel_data_daily owner to mesonet;
GRANT SELECT on feel_data_daily to nobody;

CREATE TABLE feel_data_hourly(
        valid timestamptz UNIQUE,
        BattVolt_Avg real,
        PanTemp_Avg real,
        AirTemp_Avg real,
        RH_Avg real,
        sat_vp_Avg real,
        act_vp_Avg real,
        WindDir_Avg real,
        Windspeed_Avg real,
        SolarRad_mV_Avg real,
        SolarRad_W_Avg real,
        Soil_Temp_5_Avg real,
        Rain_Tot real,
        LWS1_Avg real,
        LWS2_Avg real,
        LWS3_Avg real,
        LWS1_Ohms real,
        LWS2_Ohms real,
        LWS3_Ohms real,
        LWS1_Ohms_Hst real,
        LWS2_Ohms_Hst real,
        LWS3_Ohms_Hst real
);
alter table feel_data_hourly owner to mesonet;
GRANT SELECT on feel_data_hourly to nobody;

-- Storage of ncdc HPD data
--
CREATE TABLE hpd_alldata(
  station varchar(6),
  valid timestamptz,
  precip real
) PARTITION by range(valid);
ALTER TABLE hpd_alldata OWNER to mesonet;
GRANT ALL on hpd_alldata to ldm;
GRANT SELECT on hpd_alldata to nobody;

do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 1970..2030
    loop
        mytable := format($f$hpd_%s$f$, year);
        execute format($f$
            create table %s partition of hpd_alldata
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
            CREATE INDEX %s_station_idx on %s(station)
        $f$, mytable, mytable);
    end loop;
end;
$do$;
