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
INSERT into iem_schema_manager_version values (20, now());

create table ncei_climdiv(
    station char(6),
    day date,
    high real,
    low real,
    precip real
);
alter table ncei_climdiv owner to mesonet;
grant select on ncei_climdiv to nobody;
create index ncei_climdiv_station_idx on ncei_climdiv(station);

---
--- Storage of climoweek
CREATE TABLE climoweek(
  sday char(4) UNIQUE,
  climoweek smallint
);
GRANT SELECT on climoweek to nobody;

-- Stuff gleaned from the PDF reports, sick.
create table nass_iowa(
    valid date,
    metric text,
    nw numeric,
    nc numeric,
    ne numeric,
    wc numeric,
    c numeric,
    ec numeric,
    sw numeric,
    sc numeric,
    se numeric,
    iowa numeric,
    load_time timestamptz default now()
);
alter table nass_iowa owner to mesonet;
grant select on nass_iowa to nobody;
create index nass_iowa_valid_idx on nass_iowa(valid);


CREATE TABLE nass_quickstats(
    sector_desc varchar(60), -- CROPS, ENVIRONMENTAL, etc
    group_desc varchar(80), -- FIELD_CROPS
    commodity_desc varchar(80), -- CORN, SOIL, SOYBEANS
    class_desc varchar(180), -- SUBSOIL, TOPSOIL, ALL CLASSES
    prodn_practice_desc varchar(180), -- ALL PRODUCTION PRACTICES
    util_practice_desc varchar(180), -- SILAGE, GRAIN
    statisticcat_desc varchar(80), -- PROGRESS, CONDITION, etc
    unit_desc varchar(60), -- PCT MATURE, PCT, etc
    agg_level_desc varchar(40), -- STATE
    state_alpha varchar(2), -- IA
    year int, -- important
    freq_desc varchar(30), -- WEEKLY
    begin_code int, -- Start of period
    end_code int, -- end of period
    week_ending date, -- date of WEEKLY data
    load_time timestamptz, -- version of data row
    value varchar(24), -- raw value from service
    cv varchar(7), -- CV % from service
    num_value real, -- converted by IEM numeric
    county_ansi varchar(3), -- county code
    short_desc text -- KEY: commodity_desc, class_desc, prodn_practice_desc,
                    -- util_practice_desc, statisticcat_desc, and unit_desc
);
ALTER TABLE nass_quickstats OWNER to mesonet;
GRANT SELECT on nass_quickstats to nobody;
create index nass_quickstats_year_idx on nass_quickstats(year);
create index nass_quickstats_idx on nass_quickstats(year, short_desc);

---
--- Datastorage tables
---
CREATE TABLE alldata(
  station char(6),
  day date,
  high int,
  low int,
  precip real,
  snow real,
  sday char(4),
  year int,
  month smallint,
  snowd real,
  temp_estimated boolean,
  precip_estimated boolean,
  temp_hour smallint,
  precip_hour smallint,
  narr_srad real,
  merra_srad real,
  era5land_srad real,
  hrrr_srad real,
  era5land_soilt4_avg real,
  era5land_soilm4_avg real,
  nldas_soilt4_avg real,
  nldas_soilm4_avg real,
  era5land_soilm1m_avg real,
  nldas_soilm1m_avg real,
  power_srad real
  ) PARTITION by range(station);
ALTER TABLE alldata OWNER to mesonet;
GRANT ALL on alldata to ldm;
GRANT select on alldata to nobody;

do
$do$
declare
     st text;
     states text[] := array[
        'ak', 'al', 'ar', 'az', 'ca', 'co', 'ct', 'dc', 'de', 'fl', 'ga', 'hi',
        'ia', 'id', 'il', 'in', 'ks', 'ky', 'la', 'ma', 'md', 'me', 'mi', 'mn',
        'mo', 'ms', 'mt', 'nc', 'nd', 'ne', 'nh', 'nj', 'nm', 'nv', 'ny', 'oh',
        'ok', 'or', 'pa', 'ri', 'sc', 'sd', 'tn', 'tx', 'ut', 'va', 'vt', 'wa',
        'wi', 'wv', 'wy', 'gu', 'pr', 'vi', 'as'];
begin
    foreach st in ARRAY states
    loop
        --
        execute format(
        $f$
            create table alldata_%s partition of alldata
            for values from ('%s0000') to ('%sZZZZ')
        $f$, st, upper(st), upper(st));
        --
        execute format(
        $f$
            ALTER table alldata_%s OWNER to mesonet
        $f$, st);
        --
        execute format(
        $f$
            GRANT ALL on alldata_%s to ldm
        $f$, st);
        --
        execute format(
        $f$
            GRANT SELECT on alldata_%s to nobody
        $f$, st);
        --
        execute format(
        $f$
            CREATE UNIQUE index on alldata_%s(station, day)
        $f$, st);
        --
        execute format(
        $f$
            CREATE index on alldata_%s(day)
        $f$, st);
        --
        execute format(
        $f$
            CREATE index on alldata_%s(sday)
        $f$, st);
        --
        execute format(
        $f$
            CREATE index on alldata_%s(station)
        $f$, st);
        --
        execute format(
        $f$
            CREATE index on alldata_%s(year)
        $f$, st);

    end loop;
end;
$do$;


CREATE TABLE alldata_estimates(
  station char(6),
  day date,
  high int,
  low int,
  precip real,
  snow real,
  sday char(4),
  year int,
  month smallint,
  snowd real,
  estimated boolean,
  narr_srad real,
  merra_srad real,
  era5land_srad real,
  hrrr_srad real
  );
GRANT select on alldata_estimates to nobody;

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
--- Store the climate normals
---
CREATE TABLE climate(
  station varchar(6),
  valid date,
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
  gdd32 real,
  gdd41 real,
  gdd46 real,
  gdd48 real,
  gdd50 real,
  gdd51 real,
  gdd52 real,
  sdd86 real,
  max_high_yr   int[],
  max_low_yr    int[],
  min_high_yr   int[],
  min_low_yr    int[],
  max_precip_yr int[],
  max_range     smallint,
  min_range smallint,
  hdd65 real,
  cdd65 real,
  srad real
);
CREATE UNIQUE INDEX climate_idx on climate(station,valid);
GRANT SELECT on climate to nobody;

CREATE TABLE climate51(
  station varchar(6),
  valid date,
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
  gdd32 real,
  gdd41 real,
  gdd46 real,
  gdd48 real,
  gdd50 real,
  gdd51 real,
  gdd52 real,
  sdd86 real,
  max_high_yr   int[],
  max_low_yr    int[],
  min_high_yr   int[],
  min_low_yr    int[],
  max_precip_yr int[],
  max_range     smallint,
  min_range smallint,
  hdd65 real,
  cdd65 real,
  srad real
);
alter table climate51 owner to mesonet;
CREATE UNIQUE INDEX climate51_idx on climate51(station,valid);
CREATE INDEX climate51_station_idx on climate51(station);
CREATE INDEX climate51_valid_idx on climate51(valid);
GRANT SELECT on climate51 to nobody;

CREATE TABLE climate71(
  station varchar(6),
  valid date,
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
  gdd32 real,
  gdd41 real,
  gdd46 real,
  gdd48 real,
  gdd50 real,
  gdd51 real,
  gdd52 real,
  sdd86 real,
  max_high_yr   int[],
  max_low_yr    int[],
  min_high_yr   int[],
  min_low_yr    int[],
  max_precip_yr int[],
  max_range     smallint,
  min_range smallint,
  hdd65 real,
  cdd65 real,
  srad real
);
alter table climate71 owner to mesonet;
CREATE UNIQUE INDEX climate71_idx on climate71(station,valid);
GRANT SELECT on climate71 to nobody;

CREATE TABLE ncdc_climate71(
  station varchar(6),
  valid date,
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
  gdd32 real,
  gdd41 real,
  gdd46 real,
  gdd48 real,
  gdd50 real,
  gdd51 real,
  gdd52 real,
  sdd86 real,
  max_high_yr   int[],
  max_low_yr    int[],
  min_high_yr   int[],
  min_low_yr    int[],
  max_precip_yr int[],
  max_range     smallint,
  min_range smallint,
  hdd65 real,
  cdd65 real
);
alter table ncdc_climate71 owner to mesonet;
CREATE UNIQUE INDEX ncdc_climate71_idx on ncdc_climate71(station,valid);
GRANT SELECT on ncdc_climate71 to nobody;

CREATE TABLE ncdc_climate81(
  station varchar(11),
  valid date,
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
  gdd32 real,
  gdd41 real,
  gdd46 real,
  gdd48 real,
  gdd50 real,
  gdd51 real,
  gdd52 real,
  sdd86 real,
  max_high_yr   int[],
  max_low_yr    int[],
  min_high_yr   int[],
  min_low_yr    int[],
  max_precip_yr int[],
  max_range     smallint,
  min_range smallint,
  hdd65 real,
  cdd65 real,
  srad real
);
alter table ncdc_climate81 owner to mesonet;
CREATE UNIQUE INDEX ncdc_climate81_idx on ncdc_climate81(station,valid);
GRANT SELECT on ncdc_climate81 to nobody;

CREATE TABLE ncei_climate91(
  station varchar(11),
  valid date,
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
  gdd32 real,
  gdd41 real,
  gdd46 real,
  gdd48 real,
  gdd50 real,
  gdd51 real,
  gdd52 real,
  sdd86 real,
  max_high_yr   int[],
  max_low_yr    int[],
  min_high_yr   int[],
  min_low_yr    int[],
  max_precip_yr int[],
  max_range     smallint,
  min_range smallint,
  hdd65 real,
  cdd65 real,
  srad real
);
ALTER TABLE ncei_climate91 OWNER to mesonet;
CREATE UNIQUE INDEX ncei_climate91_idx on ncei_climate91(station,valid);
GRANT SELECT on ncei_climate91 to nobody;

CREATE TABLE climate81(
  station varchar(6),
  valid date,
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
  gdd32 real,
  gdd41 real,
  gdd46 real,
  gdd48 real,
  gdd50 real,
  gdd51 real,
  gdd52 real,
  sdd86 real,
  max_high_yr   int[],
  max_low_yr    int[],
  min_high_yr   int[],
  min_low_yr    int[],
  max_precip_yr int[],
  max_range     smallint,
  min_range smallint,
  hdd65 real,
  cdd65 real,
  srad real
);
ALTER TABLE climate81 OWNER to mesonet;
CREATE UNIQUE INDEX climate81_idx on climate81(station,valid);
GRANT SELECT on climate81 to nobody;

COPY climoweek (sday, climoweek) FROM stdin;
0101	44
0102	44
0103	45
0104	45
0105	45
0106	45
0107	45
0108	45
0109	45
0110	46
0111	46
0112	46
0113	46
0114	46
0115	46
0116	46
0117	47
0118	47
0119	47
0120	47
0121	47
0122	47
0123	47
0124	48
0125	48
0126	48
0127	48
0128	48
0129	48
0130	48
0131	49
0201	49
0202	49
0203	49
0204	49
0205	49
0206	49
0207	50
0208	50
0209	50
0210	50
0211	50
0212	50
0213	50
0214	51
0215	51
0216	51
0217	51
0218	51
0219	51
0220	51
0221	52
0222	52
0223	52
0224	52
0225	52
0226	52
0227	52
0228	53
0229	53
0301	1
0302	1
0303	1
0304	1
0305	1
0306	1
0307	1
0308	2
0309	2
0310	2
0311	2
0312	2
0313	2
0314	2
0315	3
0316	3
0317	3
0318	3
0319	3
0320	3
0321	3
0322	4
0323	4
0324	4
0325	4
0326	4
0327	4
0328	4
0329	5
0330	5
0331	5
0401	5
0402	5
0403	5
0404	5
0405	6
0406	6
0407	6
0408	6
0409	6
0410	6
0411	6
0412	7
0413	7
0414	7
0415	7
0416	7
0417	7
0418	7
0419	8
0420	8
0421	8
0422	8
0423	8
0424	8
0425	8
0426	9
0427	9
0428	9
0429	9
0430	9
0501	9
0502	9
0503	10
0504	10
0505	10
0506	10
0507	10
0508	10
0509	10
0510	11
0511	11
0512	11
0513	11
0514	11
0515	11
0516	11
0517	12
0518	12
0519	12
0520	12
0521	12
0522	12
0523	12
0524	13
0525	13
0526	13
0527	13
0528	13
0529	13
0530	13
0531	14
0601	14
0602	14
0603	14
0604	14
0605	14
0606	14
0607	15
0608	15
0609	15
0610	15
0611	15
0612	15
0613	15
0614	16
0615	16
0616	16
0617	16
0618	16
0619	16
0620	16
0621	17
0622	17
0623	17
0624	17
0625	17
0626	17
0627	17
0628	18
0629	18
0630	18
0701	18
0702	18
0703	18
0704	18
0705	19
0706	19
0707	19
0708	19
0709	19
0710	19
0711	19
0712	20
0713	20
0714	20
0715	20
0716	20
0717	20
0718	20
0719	21
0720	21
0721	21
0722	21
0723	21
0724	21
0725	21
0726	22
0727	22
0728	22
0729	22
0730	22
0731	22
0801	22
0802	23
0803	23
0804	23
0805	23
0806	23
0807	23
0808	23
0809	24
0810	24
0811	24
0812	24
0813	24
0814	24
0815	24
0816	25
0817	25
0818	25
0819	25
0820	25
0821	25
0822	25
0823	26
0824	26
0825	26
0826	26
0827	26
0828	26
0829	26
0830	27
0831	27
0901	27
0902	27
0903	27
0904	27
0905	27
0906	28
0907	28
0908	28
0909	28
0910	28
0911	28
0912	28
0913	29
0914	29
0915	29
0916	29
0917	29
0918	29
0919	29
0920	30
0921	30
0922	30
0923	30
0924	30
0925	30
0926	30
0927	31
0928	31
0929	31
0930	31
1001	31
1002	31
1003	31
1004	32
1005	32
1006	32
1007	32
1008	32
1009	32
1010	32
1011	33
1012	33
1013	33
1014	33
1015	33
1016	33
1017	33
1018	34
1019	34
1020	34
1021	34
1022	34
1023	34
1024	34
1025	35
1026	35
1027	35
1028	35
1029	35
1030	35
1031	35
1101	36
1102	36
1103	36
1104	36
1105	36
1106	36
1107	36
1108	37
1109	37
1110	37
1111	37
1112	37
1113	37
1114	37
1115	38
1116	38
1117	38
1118	38
1119	38
1120	38
1121	38
1122	39
1123	39
1124	39
1125	39
1126	39
1127	39
1128	39
1129	40
1130	40
1201	40
1202	40
1203	40
1204	40
1205	40
1206	41
1207	41
1208	41
1209	41
1210	41
1211	41
1212	41
1213	42
1214	42
1215	42
1216	42
1217	42
1218	42
1219	42
1220	43
1221	43
1222	43
1223	43
1224	43
1225	43
1226	43
1227	44
1228	44
1229	44
1230	44
1231	44
\.

-- Storage of Nino Data
CREATE TABLE elnino(
        monthdate date UNIQUE,
        anom_34 real,
        soi_3m real
);
GRANT SELECT on elnino to nobody;

-- Storage of Point Extracted Forecast Data
CREATE TABLE forecast_inventory(
  id SERIAL UNIQUE,
  model varchar(32),
  modelts timestamptz
);
GRANT SELECT on forecast_inventory to nobody;

CREATE TABLE alldata_forecast(
  modelid int REFERENCES forecast_inventory(id),
  station char(6),
  day date,
  high int,
  low int,
  precip real,
  srad real
);
GRANT SELECT on alldata_forecast to nobody;
CREATE INDEX alldata_forecast_idx on alldata_forecast(station, day);

-- Storage of baseline yield forecast data
CREATE TABLE yieldfx_baseline(
  station varchar(24),
  valid date,
  radn real,
  maxt real,
  mint real,
  rain real,
  windspeed real,
  rh real);
GRANT SELECT on yieldfx_baseline to nobody;

-- Storage of polygons associated with regions we compute climodat for
CREATE TABLE climodat_regions(
    iemid int REFERENCES stations(iemid),
    geom geometry(MultiPolygon, 4326)
);
CREATE UNIQUE INDEX climodat_regions_idx on climodat_regions(iemid);
CREATE INDEX climodat_regions_gix on climodat_regions USING GIST(geom);
ALTER TABLE climodat_regions OWNER TO mesonet;
GRANT SELECT on climodat_regions to nobody, ldm;
