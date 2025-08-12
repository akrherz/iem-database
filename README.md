# IEM Database Schema + Testing Data

This repo serves three purposes.

1. Document the database schema used by most of akrherz's projects.
2. Provide testing data to load into that schema to support CIs.
3. Generate docker images used within these same project repos CIs.

## Docker Images

See [GHCR](https://github.com/akrherz/iem-database/pkgs/container/iem_database)

Image | Purpose
-- | --
`akrherz/iem_database:no_test_data` | Schema, but no test data loaded
`akrherz/iem_database:test_data` | Schema and Test Data

## Schema Versioning

Eh, I am sure there are much better ways to manage database schema than this,
but alas, here it is.  Fundamentally, we support the following scenarios.

1. A newly setup PostgreSQL database.
2. An upgrade path from previously deployed databases
3. A means to bootstrap a database schema and some initial data to support
CI testing.

The `init` folder contains the initial schema plus incremental changes that
are also tracked in sequential `upgrade` files.  A recent change was to update
the files in `init` with any schema updates made.  The magic happens with a
dedicated table in each database known as `iem_schema_manager_version`,
which tracks a integer value representing the most recent schema update made.

Simply running:

    python schema_manager.py

and things should take care of themselves.  The `bootstrap.sh` exists for
initial deployments, like on CI.

## Bundled test data

To support integration tests, some real data is bundled here for loading into
the database via `store_test_data.py`.  Some terse details on these files in
the `data` folder:

Filename | Contains
--- | ---
afos_products.sql.gz | AFDDMX from 10-16 Jul 2024
asos__000taf.sql | TAF reference table for 21 Aug 2024 UTC
asos__31_Dec_2024.sql | ASOS data for DSM, AMW, BNW for 31 Dec 2024
asos__AMW_01_10_Aug_2024.aql | Ames data for 1-10 Aug 2024
asos__taf2024.sql.gz | TAF data for 21 Aug 2024 UTC
asos_alldata.sql.gz | ~2020 data for AMW and DSM
asos1min_DSMAMW.sql.gz | One Minute ASOS 10-12 July 2024 DSM+AMW
coop__IA0000_IATAME_2000_2024.sql.gz | climodat IA0000,IATAME,IA0200 for 2000-2024(aug 25)
coop__IAC005_2000_2024.sql | climodat IAC005 (Central Iowa) 2000-2024
coop__alldata_IATDSM.sql.gz | climodat IATDSM for 2000-2024(aug 15)
coop__climate51.sql | climate51 data for IATAME,IATDSM,IA0000
coop__climate71.sql | climate71 data for IATAME,IATDSM,IA0000
coop__climate81.sql | climate81 data for IATAME,IATDSM,IA0000
coop__cocorahs_241231.sql | CoCoRaHS Iowa data for 31 Dec 2024
coop__elnino.sql | El Nino data till Aug 2024
coop__nass_quickstats.sql.gz | NASS Quickstats 2007-Aug 2024
coop__ncei_climdiv_IA0000.sql | NCEI Climdiv data for Iowa Statewide
coop_ncei_climate71_ames.sql | NCEI 71 Climatology for Ames
coop_ncei_climate81_ames.sql | NCEI 81 Climatology for Ames
coop_ncei_climate91_ames.sql | NCEI 91 Climatology for Ames
dep_china__pydeptesting.sql | pydep test entry for climate_files
hads_alldata.sql.gz | 2024 weather variables for EOKI4
hads_snowfall.sql | 10 Nov 2023 12 UTC fake entries for DNKI4
hml__000hml_forecast.sql | Guttenburg GTTI4 20-23 Aug 2024
hml__hml_forecast_data.sql | Guttenburg GTTI4 20-23 Aug 2024
hml__hml_observed_data.sql | Guttenburg GTTI4 20-23 Aug 2024
id3b__product_log_nob.sql.gz | ldm_product_log of N0B that gets updated to RT
idep__pydeptesting.sql | test data run with dailyerosion/dep (pydep) repo
iem__hourly.sql.gz | DSM,AMW hourly precip 2024 precip till 4 Sept
iem__AMWDSM.sql.gz | IEM current,current_log,summary_2024 (14 Aug) for AMW+DSM
iem__cf6data.sql | CF6 Data for DSM 2024 till 26 Jul
iem__clidata.sql | CLI Data for DSM 2024 till 26 Jul
iem__summary_iacoop_241022.sql | Iowa COOP summary data for 22 Oct 2024
iem__summary2020.sql.gz | Ames, Des Moines summary data for 2020
iem__summary_iacoop_241231.sql | IA COOP summary data for 31 Dec 2024
iemre__20170102.sql | IEMRE entry for 2 Jan 2017 for pydep
iemre_china__20250721.sql | IEMRE entry for 21 Jul 2025 for pydep
isuag_daily.sql.gz | ISU Ag Climate station A130209 (Ames)
isuag__hourly.sql | ISU Ag Climate station A130209 (Ames) 2,000 hourly
isuag_sm_minute.sql.gz | ISU Soil Moisture minute data 21-25 July 2024
isuag_sm_hourly.sql.gz | ISU Soil Moisture hourly data 21-25 July 2024
isuag__sm_hourly.sql.gz | More AEEI4 hourly data
isuag_sm_daily.sql | ISU Soil Moisture daily data 21-25 July 2024
isuag_sm_inversion.sql.gz | ISU Soil Moisture inversion data 21-25 July 2024
mesosite__camera_log_2020.sql | Webcam metadata around 17z 10 Aug 2020
mesosite__feature.sql | Random IEM Feature content
mesosite__networks.sql | A few IEM networks for Iowa and WFO
mesosite_products.sql | Archived products metadata
mesosite_tzworld_chicago.sql.gz | Largest geometry for America/Chicago for tz_world
mesosite_webcams.sql | Some example webcam entries
mesosite_zz_station_attrs.sql | Station attributes for
mos_20240802.sql | KDSM MOS for 2 Aug 2024 0z
other__feel_data.sql | ISU FEEL data for 14 Apr 2025
other__purpleair.sql | purpleair data for 10 Aug 2024
other__ss_bubbler.sql | data for 13 Aug 2012
other__ss_logger_data.sql | 2012-2014 random data
postgis__00ugcs.sql.gz | NWS UGC database as of 30 Jul 2025, with hard coded 1980 start date
postgis_00ugcs.sql | A faked UGC entry to match warnings below
postgis_mcd.sql.gz | MCDs for much of July 2024
postgis_pireps.sql | A few PIREPs on 31 July 2024
postgis__000spc_outlook.sql | SPC/WPC Outlook 1-8 Aug 2024
postgis__airmets.sql | Some AIRMETs from 10 Aug 2024
postgis__cwas.sql | Some Center Weather Advisories from 10 Aug 2024
postgis__fema_regions.sql.gz | Simplified FEMA Regions
postgis__sigmets_archive.sql | Some SIGMETs from 10 Aug 2024
postgis__spc_outlook_geometries.sql.gz | SPC/WPC Outlooks 1-8 Aug 2024
postgis__sps2024.sql.gz | SPSs from Aug 2024
postgis_lsrs.sql | DMX LSRs from 2018-06-20,2018-06-21,2024-05-21, One BGM LSR from 2023
postgis_sbw.sql | DMX,OAX 21 May 2024 polygons, some 2018 stuff
postgis_states.sql | Simplified 0.01 us states
postgis__text_products_oct24.sql.gz | NWS misc polygons for Oct 2024
postgis__usdm.sql.gz | US Drought Monitor for 2024 till 8 Aug
postgis_warnings.sql | DMX select warnings from 2018 and 2024, OAX Emergencies 2024
postgis_warnings2020.sql | DMX selected for 2020
postgis_watches_current.sql | watches_current snapshot 5 Aug 2024
postgis_watches2024.sql.gz | watches for 2024 till 5 Aug 2024
radar__nexrad_attributes_2024.sql.gz | sampled attributes from 10 Aug 2024
radar__nexrad_attributes.sql.gz | nexrad attributes current (set to loadtime)
raob_240719.sql.gz | All soundings from 19 July 2024 12 UTC
rwis_atmos.sql.gz | RWIS met data for 1 July 2024
rwis_soil.sql | Iowa RWIS soil data for 1 July 2024
rwis_traffic.sql | Iowa RWIS traffic data for 1 July 2024
talltowers_20160915.sql | Talltowers data from 15 Sep 2016
