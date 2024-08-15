# Simple Schema Manager

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
asos_alldata.sql.gz | ~2020 data for AMW and DSM
asos1min_DSMAMW.sql.gz | One Minute ASOS 10-12 July 2024 DSM+AMW
coop__IA0000_IATAME_2000_2024.sql.gz | climodat IA0000,IATAME for 2000-2024(aug 14)
coop__nass_quickstats.sql.gz | NASS Quickstats 2021-2024
coop_ncei_climate71_ames.sql | NCEI 71 Climatology for Ames
coop_ncei_climate81_ames.sql | NCEI 81 Climatology for Ames
coop_ncei_climate91_ames.sql | NCEI 91 Climatology for Ames
hads_alldata.sql.gz | 2024 weather variables for EOKI4
iem_AMWDSM.sql.gz | IEM current,current_log,summary_2024 (14 Aug) for AMW+DSM
iem_cf6data.sql | CF6 Data for DSM 2024 till 26 Jul
iem_clidata.sql | CLI Data for DSM 2024 till 26 Jul
isuag_daily.sql.gz | ISU Ag Climate station A130209 (Ames)
isuag_sm_minute.sql.gz | ISU Soil Moisture minute data 21-25 July 2024
isuag_sm_hourly.sql.gz | ISU Soil Moisture hourly data 21-25 July 2024
isuag_sm_daily.sql | ISU Soil Moisture daily data 21-25 July 2024
isuag_sm_inversion.sql.gz | ISU Soil Moisture inversion data 21-25 July 2024
mesosite__camera_log_2020.sql | Webcam metadata around 17z 10 Aug 2020
mesosite_products.sql | Archived products metadata
mesosite_tzworld_chicago.sql.gz | Largest geometry for America/Chicago for tz_world
mesosite_webcams.sql | Some example webcam entries
mesosite_zz_station_attrs.sql | Station attributes for
mos_20240802.sql | KDSM MOS for 2 Aug 2024 0z
mos_fake_realtime.sql | MOS faked NBS entry for KDSM valid at 0z today
other__purpleair.sql | purpleair data for 10 Aug 2024
other__ss_bubbler.sql | data for 13 Aug 2012
other__ss_logger_data.sql | 2012-2014 random data
postgis_mcd.sql.gz | MCDs for much of July 2024
postgis_pireps.sql | A few PIREPs on 31 July 2024
postgis__000spc_outlook.sql | SPC/WPC Outlook 1-8 Aug 2024
postgis__airmets.sql | Some AIRMETs from 10 Aug 2024
postgis__cwas.sql | Some Center Weather Advisories from 10 Aug 2024
postgis__sigmets_archive.sql | Some SIGMETs from 10 Aug 2024
postgis__spc_outlook_geometries.sql.gz | SPC/WPC Outlooks 1-8 Aug 2024
postgis__sps.sql | Some SPSs from 10 Aug 2024
postgis_states.sql | Simplified 0.01 us states
postgis__usdm.sql.gz | US Drought Monitor for 2024 till 8 Aug
postgis_watches_current.sql | watches_current snapshot 5 Aug 2024
postgis_watches2024.sql.gz | watches for 2024 till 5 Aug 2024
radar__nexrad_attributes_2024.sql.gz | sampled attributes from 10 Aug 2024
radar__nexrad_attributes.sql.gz | current attributes at 22z 10 Aug 2024
raob_240719.sql.gz | All soundings from 19 July 2024 12 UTC
rwis_atmos.sql.gz | RWIS met data for 1 July 2024
rwis_soil.sql | Iowa RWIS soil data for 1 July 2024
rwis_traffic.sql | Iowa RWIS traffic data for 1 July 2024
talltowers_20160915.sql | Talltowers data from 15 Sep 2016
