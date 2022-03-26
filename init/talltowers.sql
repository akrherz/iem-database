-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
	version int,
	updated timestamptz);
INSERT into iem_schema_manager_version values (-1, now());

-- Storage of Tower Metadata
CREATE TABLE towers(
  id smallint UNIQUE NOT NULL,
  name varchar);
INSERT into towers values(0, 'Hamilton');
INSERT into towers values(1, 'Story');
GRANT SELECT on towers to nobody;
GRANT ALL on towers to mesonet,ldm;

-- 1 hertz data
CREATE TABLE data_analog(
  tower smallint REFERENCES towers(id),
  valid timestamptz,

  ws_5m_s real,
  ws_5m_nw real,
  winddir_5m_s real,
  winddir_5m_nw real,
  rh_5m real,
  airtc_5m real,

  ws_10m_s real,
  ws_10m_nwht real,
  winddir_10m_s real,
  winddir_10m_nw real,
  rh_10m real,
  airtc_10m real,
  bp_10m real,

  ws_20m_s real,
  ws_20m_nw real,
  winddir_20m_s real,
  winddir_20m_nw real,
  rh_20m real,
  airtc_20m real,
  
  ws_40m_s real,
  ws_40m_nwht real,
  winddir_40m_s real,
  winddir_40m_nw real,
  rh_40m real,
  airtc_40m real,

  ws_80m_s real,
  ws_80m_nw real,
  winddir_80m_s real,
  winddir_80m_nw real,
  rh_80m real,
  airtc_80m real,
  bp_80m real,

  ws_120m_s real,
  ws_120m_nwht real,
  winddir_120m_s real,
  winddir_120m_nw real,
  rh_120m_1 real,
  rh_120m_2 real,
  airtc_120m_1 real,
  airtc_120m_2 real

) PARTITION by range(valid);
GRANT ALL on data_analog to tt_admin,tt_script;
GRANT SELECT on data_analog to tt_web;

do
$do$
declare
     year int;
     month int;
begin
    for year in 2016..2030
    loop
        for month in 1..12
        loop
            execute format($f$
                create table data_analog_%s%s partition of data_analog
                for values from ('%s-%s-01 00:00+00') to ('%s-%s-01 00:00+00')
            $f$, year, lpad(month::text, 2, '0'), year, month,
            case when month = 12 then year + 1 else year end,
            case when month = 12 then 1 else month + 1 end);
            execute format($f$
                GRANT ALL on data_analog_%s%s to mesonet,ldm,tt_script,tt_admin
            $f$, year, lpad(month::text, 2, '0'));
            execute format($f$
                GRANT SELECT on data_analog_%s%s to nobody,tt_web
            $f$, year, lpad(month::text, 2, '0'));
            execute format($f$
                CREATE INDEX on data_analog_%s%s(tower, valid)
            $f$, year, lpad(month::text, 2, '0'));
        end loop;
    end loop;
end;
$do$;

-- Sonic data 20hz
CREATE TABLE data_sonic(
  tower smallint REFERENCES towers(id),
  valid timestamptz,

  diag_5m smallint,
  ts_5m real,
  uz_5m real,
  uy_5m real,
  ux_5m real,

  diag_10m smallint,
  ts_10m real,
  uz_10m real,
  uy_10m real,
  ux_10m real,

  diag_20m smallint,
  ts_20m real,
  uz_20m real,
  uy_20m real,
  ux_20m real,
  
  diag_40m smallint,
  ts_40m real,
  uz_40m real,
  uy_40m real,
  ux_40m real,
  
  diag_80m smallint,
  ts_80m real,
  uz_80m real,
  uy_80m real,
  ux_80m real,
  
  diag_120m smallint,
  ts_120m real,
  uz_120m real,
  uy_120m real,
  ux_120m real) PARTITION by range(valid);
GRANT ALL on data_sonic to tt_admin,tt_script;
GRANT SELECT on data_sonic to tt_web;

do
$do$
declare
     year int;
     month int;
begin
    for year in 2016..2030
    loop
        for month in 1..12
        loop
            execute format($f$
                create table data_sonic_%s%s partition of data_sonic
                for values from ('%s-%s-01 00:00+00') to ('%s-%s-01 00:00+00')
            $f$, year, lpad(month::text, 2, '0'), year, month,
            case when month = 12 then year + 1 else year end,
            case when month = 12 then 1 else month + 1 end);
            execute format($f$
                GRANT ALL on data_sonic_%s%s to mesonet,ldm,tt_script,tt_admin
            $f$, year, lpad(month::text, 2, '0'));
            execute format($f$
                GRANT SELECT on data_sonic_%s%s to nobody,tt_web
            $f$, year, lpad(month::text, 2, '0'));
            execute format($f$
                CREATE INDEX on data_sonic_%s%s(tower, valid)
            $f$, year, lpad(month::text, 2, '0'));
        end loop;
    end loop;
end;
$do$;


-- monitor
CREATE TABLE data_monitor(
  tower smallint REFERENCES towers(id),
  valid timestamptz,
  CR6_BattV real,
  CR6_PTemp real,
  BoardTemp_120m real,
  BoardHumidity_120m real,
  InclinePitch_120m real,
  InclineRoll_120m real,
  BoardTemp_80m real,
  BoardHumidity_80m real,
  InclinePitch_80m real,
  InclineRoll_80m real,
  BoardTemp_40m real,
  BoardHumidity_40m real,
  InclinePitch_40m real,
  InclineRoll_40m real,
  BoardTemp_20m real,
  BoardHumidity_20m real,
  InclinePitch_20m real,
  InclineRoll_20m real,
  BoardTemp_10m real,
  BoardHumidity_10m real,
  InclinePitch_10m real,
  InclineRoll_10m real,
  BoardTemp_5m real,
  BoardHumidity_5m real,
  InclinePitch_5m real,
  InclineRoll_5m real);
GRANT ALL on data_monitor to tt_admin,tt_script;
GRANT SELECT on data_monitor to tt_web;

-- Storage of SODAR data
CREATE TABLE sodar_profile(
    station int,
    valid timestamptz,
    label char(1),
    height int,
    beamnum real,
    confidence_function real,
    confidence real,
    echo_suppression real,
    number_of_shots real,
    peak_detection real,
    range_gate real,
    signal_level real,
    snr real,
    suppressed_echoes real,
    valid_spectra real,
    wind_direction real,
    wind_speed real,
    wind_vert real,
    quality real,
    wind_turbulence real
);
CREATE UNIQUE INDEX soldar_profile_idx on
  sodar_profile(station, valid, label, height);
GRANT ALL on sodar_profile to tt_script;
GRANT SELECT on sodar_profile to tt_web;

CREATE TABLE sodar_surface(
    station int,
    valid timestamptz,
    ambient_temp real,
    barometric_pressure real,
    tiltx real,
    azimuth real,
    tilty real,
    humidity real,
    noise_level_a real,
    noise_level_b real,
    noise_level_c real,
    solar_power real,
    cpu_power real,
    core_power real,
    modem_power real,
    speaker_power real,
    pwm_power real,
    status real,
    internal_temp real,
    heater_temp real,
    mirror_temp real,
    cpu_temp real,
    vibrationy real,
    vibrationx real,
    battery real,
    beep_volume real
);
CREATE UNIQUE INDEX sodar_surface_idx on sodar_surface(station, valid);
GRANT ALL on sodar_surface to tt_script;
GRANT SELECT on sodar_surface to tt_web;

CREATE TABLE channels (
  chn_id smallint NOT NULL,
  header varchar(20) NOT NULL,
  height smallint,
  site varchar(8) NOT NULL,
  unit varchar(4)
);
GRANT SELECT on channels to tt_script,tt_web;

COMMENT ON TABLE channels IS 'This table provides the chn_id to select from the dat table.';
COMMENT ON COLUMN channels.chn_id IS 'primary key. encoded with site as thousands unit, datatable as hundreds, and tens+ones are the column number in .dat files.';
COMMENT ON COLUMN channels.header IS 'the column name programmed by the datalogger.  when important, the header includes height in meters.';
COMMENT ON COLUMN channels.height IS 'the height in meters above ground.  The datashed does not have a height ("\N")';
COMMENT ON COLUMN channels.site IS '"story" or "hamilton"';
COMMENT ON COLUMN channels.unit IS 'units of measurment';

ALTER TABLE ONLY channels ADD CONSTRAINT channels_pkey PRIMARY KEY (chn_id);

-- copy channels data
-- developed from headers, using python code "simple_chn_id.py".
COPY channels (chn_id,header,height,site,unit) FROM stdin;
1102	AirTC_120m_1	120	story	C
1103	AirTC_120m_2	120	story	C
1104	AirTC_80m	80	story	C
1105	AirTC_40m	40	story	C
1106	AirTC_20m	20	story	C
1107	AirTC_10m	10	story	C
1108	AirTC_5m	5	story	C
1109	RH_120m_1	120	story	%
1110	RH_120m_2	120	story	%
1111	RH_80m	80	story	%
1112	RH_40m	40	story	%
1113	RH_20m	20	story	%
1114	RH_10m	10	story	%
1115	RH_5m	5	story	%
1116	BP_80m	80	story	mbar
1117	BP_10m	10	story	mbar
1118	WS_120m_NWht	120	story	m/s
1119	WS_120m_S	120	story	m/s
1120	WS_80m_NW	80	story	m/s
1121	WS_80m_S	80	story	m/s
1122	WS_40m_NWht	40	story	m/s
1123	WS_40m_S	40	story	m/s
1124	WS_20m_NW	20	story	m/s
1125	WS_20m_S	20	story	m/s
1126	WS_10m_NWht	10	story	m/s
1127	WS_10m_S	10	story	m/s
1128	WS_5m_NW	5	story	m/s
1129	WS_5m_S	5	story	m/s
1130	WindDir_120m_NW	120	story	deg
1131	WindDir_120m_S	120	story	deg
1132	WindDir_80m_NW	80	story	deg
1133	WindDir_80m_S	80	story	deg
1134	WindDir_40m_NW	40	story	deg
1135	WindDir_40m_S	40	story	deg
1136	WindDir_20m_NW	20	story	deg
1137	WindDir_20m_S	20	story	deg
1138	WindDir_10m_NW	10	story	deg
1139	WindDir_10m_S	10	story	deg
1140	WindDir_5m_NW	5	story	deg
1141	WindDir_5m_S	5	story	deg
1202	Ux_120m	120	story	m/s
1203	Uy_120m	120	story	m/s
1204	Uz_120m	120	story	m/s
1205	Ts_120m	120	story	C
1206	Diag_120m	120	story	
1207	Ux_80m	80	story	m/s
1208	Uy_80m	80	story	m/s
1209	Uz_80m	80	story	m/s
1210	Ts_80m	80	story	C
1211	Diag_80m	80	story	
1212	Ux_40m	40	story	m/s
1213	Uy_40m	40	story	m/s
1214	Uz_40m	40	story	m/s
1215	Ts_40m	40	story	C
1216	Diag_40m	40	story	
1217	Ux_20m	20	story	m/s
1218	Uy_20m	20	story	m/s
1219	Uz_20m	20	story	m/s
1220	Ts_20m	20	story	C
1221	Diag_20m	20	story	
1222	Ux_10m	10	story	m/s
1223	Uy_10m	10	story	m/s
1224	Uz_10m	10	story	m/s
1225	Ts_10m	10	story	C
1226	Diag_10m	10	story	
1227	Ux_5m	5	story	m/s
1228	Uy_5m	5	story	m/s
1229	Uz_5m	5	story	m/s
1230	Ts_5m	5	story	C
1231	Diag_5m	5	story	
1302	CR6_BattV	\N	story	V
1303	CR6_PTemp	\N	story	C
1304	BoardTemp_120m	120	story	C
1305	BoardHumidity_120m	120	story	%
1306	InclinePitch_120m	120	story	deg
1307	InclineRoll_120m	120	story	deg
1308	BoardTemp_80m	80	story	C
1309	BoardHumidity_80m	80	story	%
1310	InclinePitch_80m	80	story	deg
1311	InclineRoll_80m	80	story	deg
1312	BoardTemp_40m	40	story	C
1313	BoardHumidity_40m	40	story	%
1314	InclinePitch_40m	40	story	deg
1315	InclineRoll_40m	40	story	deg
1316	BoardTemp_20m	20	story	C
1317	BoardHumidity_20m	20	story	%
1318	InclinePitch_20m	20	story	deg
1319	InclineRoll_20m	20	story	deg
1320	BoardTemp_10m	10	story	C
1321	BoardHumidity_10m	10	story	%
1322	InclinePitch_10m	10	story	deg
1323	InclineRoll_10m	10	story	deg
1324	BoardTemp_5m	5	story	C
1325	BoardHumidity_5m	5	story	%
1326	InclinePitch_5m	5	story	deg
1327	InclineRoll_5m	5	story	deg
2102	AirTC_120m_1	120	hamilton	C
2103	AirTC_120m_2	120	hamilton	C
2104	AirTC_80m	80	hamilton	C
2105	AirTC_40m	40	hamilton	C
2106	AirTC_20m	20	hamilton	C
2107	AirTC_10m	10	hamilton	C
2108	AirTC_5m	5	hamilton	C
2109	RH_120m_1	120	hamilton	%
2110	RH_120m_2	120	hamilton	%
2111	RH_80m	80	hamilton	%
2112	RH_40m	40	hamilton	%
2113	RH_20m	20	hamilton	%
2114	RH_10m	10	hamilton	%
2115	RH_5m	5	hamilton	%
2116	BP_80m	80	hamilton	mbar
2117	BP_10m	10	hamilton	mbar
2118	WS_120m_NWht	120	hamilton	m/s
2119	WS_120m_S	120	hamilton	m/s
2120	WS_80m_NW	80	hamilton	m/s
2121	WS_80m_S	80	hamilton	m/s
2122	WS_40m_NWht	40	hamilton	m/s
2123	WS_40m_S	40	hamilton	m/s
2124	WS_20m_NW	20	hamilton	m/s
2125	WS_20m_S	20	hamilton	m/s
2126	WS_10m_NWht	10	hamilton	m/s
2127	WS_10m_S	10	hamilton	m/s
2128	WS_5m_NW	5	hamilton	m/s
2129	WS_5m_S	5	hamilton	m/s
2130	WindDir_120m_NW	120	hamilton	deg
2131	WindDir_120m_S	120	hamilton	deg
2132	WindDir_80m_NW	80	hamilton	deg
2133	WindDir_80m_S	80	hamilton	deg
2134	WindDir_40m_NW	40	hamilton	deg
2135	WindDir_40m_S	40	hamilton	deg
2136	WindDir_20m_NW	20	hamilton	deg
2137	WindDir_20m_S	20	hamilton	deg
2138	WindDir_10m_NW	10	hamilton	deg
2139	WindDir_10m_S	10	hamilton	deg
2140	WindDir_5m_NW	5	hamilton	deg
2141	WindDir_5m_S	5	hamilton	deg
2202	Ux_120m	120	hamilton	m/s
2203	Uy_120m	120	hamilton	m/s
2204	Uz_120m	120	hamilton	m/s
2205	Ts_120m	120	hamilton	C
2206	Diag_120m	120	hamilton	
2207	Ux_80m	80	hamilton	m/s
2208	Uy_80m	80	hamilton	m/s
2209	Uz_80m	80	hamilton	m/s
2210	Ts_80m	80	hamilton	C
2211	Diag_80m	80	hamilton	
2212	Ux_40m	40	hamilton	m/s
2213	Uy_40m	40	hamilton	m/s
2214	Uz_40m	40	hamilton	m/s
2215	Ts_40m	40	hamilton	C
2216	Diag_40m	40	hamilton	
2217	Ux_20m	20	hamilton	m/s
2218	Uy_20m	20	hamilton	m/s
2219	Uz_20m	20	hamilton	m/s
2220	Ts_20m	20	hamilton	C
2221	Diag_20m	20	hamilton	
2222	Ux_10m	10	hamilton	m/s
2223	Uy_10m	10	hamilton	m/s
2224	Uz_10m	10	hamilton	m/s
2225	Ts_10m	10	hamilton	C
2226	Diag_10m	10	hamilton	
2227	Ux_5m	5	hamilton	m/s
2228	Uy_5m	5	hamilton	m/s
2229	Uz_5m	5	hamilton	m/s
2230	Ts_5m	5	hamilton	C
2231	Diag_5m	5	hamilton	
2302	CR6_BattV	\N	hamilton	V
2303	CR6_PTemp	\N	hamilton	C
2304	BoardTemp_120m	120	hamilton	C
2305	BoardHumidity_120m	120	hamilton	%
2306	InclinePitch_120m	120	hamilton	deg
2307	InclineRoll_120m	120	hamilton	deg
2308	BoardTemp_80m	80	hamilton	C
2309	BoardHumidity_80m	80	hamilton	%
2310	InclinePitch_80m	80	hamilton	deg
2311	InclineRoll_80m	80	hamilton	deg
2312	BoardTemp_40m	40	hamilton	C
2313	BoardHumidity_40m	40	hamilton	%
2314	InclinePitch_40m	40	hamilton	deg
2315	InclineRoll_40m	40	hamilton	deg
2316	BoardTemp_20m	20	hamilton	C
2317	BoardHumidity_20m	20	hamilton	%
2318	InclinePitch_20m	20	hamilton	deg
2319	InclineRoll_20m	20	hamilton	deg
2320	BoardTemp_10m	10	hamilton	C
2321	BoardHumidity_10m	10	hamilton	%
2322	InclinePitch_10m	10	hamilton	deg
2323	InclineRoll_10m	10	hamilton	deg
2324	BoardTemp_5m	5	hamilton	C
2325	BoardHumidity_5m	5	hamilton	%
2326	InclinePitch_5m	5	hamilton	deg
2327	InclineRoll_5m	5	hamilton	deg
\.
