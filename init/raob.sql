CREATE EXTENSION postgis;

-- bandaid
insert into spatial_ref_sys select 9311, 'EPSG', 9311, srtext, proj4text from spatial_ref_sys where srid = 2163;

-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
    version int,
    updated timestamptz);
INSERT into iem_schema_manager_version values (0, now());

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
--- Rawinsonde data!
---
CREATE TABLE raob_flights(
    fid SERIAL PRIMARY KEY,
    valid timestamptz,  -- Standard time of ob
    station varchar(4),
    hydro_level real,
    maxwd_level real,
    tropo_level real,
    release_time timestamptz, -- Time of Release
    sbcape_jkg real,
    sbcin_jkg real,
    mucape_jkg real,
    mucin_jkg real,
    pwater_mm real,
    computed boolean,
    lcl_agl_m real,
    lcl_pressure_hpa real,
    lcl_tmpc real,
    lfc_agl_m real,
    lfc_pressure_hpa real,
    lfc_tmpc real,
    el_agl_m real,
    el_pressure_hpa real,
    el_tmpc real,
    total_totals real,
    sweat_index real,
    bunkers_lm_smps real,
    bunkers_lm_drct real,
    bunkers_rm_smps real,
    bunkers_rm_drct real,
    mean_sfc_6km_smps real,
    mean_sfc_6km_drct real,
    srh_sfc_1km_pos real,
    srh_sfc_1km_neg real,
    srh_sfc_1km_total real,
    srh_sfc_3km_pos real,
    srh_sfc_3km_neg real,
    srh_sfc_3km_total real,
    shear_sfc_1km_smps real,
    shear_sfc_3km_smps real,
    shear_sfc_6km_smps real,
    mlcape_jkg real,
    mlcin_jkg real,
    locked boolean DEFAULT 'f',
    ingested_at timestamptz DEFAULT now(),
    computed_at timestamptz DEFAULT now()
);
ALTER TABLE raob_flights OWNER to mesonet;
GRANT ALL on raob_flights to ldm,mesonet;
create unique index raob_flights_idx on raob_flights(valid, station);
GRANT SELECT on raob_flights to nobody;

CREATE TABLE raob_profile(
    fid int REFERENCES raob_flights(fid) ON DELETE CASCADE ON UPDATE CASCADE,
    ts timestamptz,
    levelcode smallint,
    pressure real, -- mb
    height real, -- m
    tmpc real, -- C
    dwpc real, -- C
    drct real, -- deg
    smps real, -- wind speed in MPS
    bearing real, -- deg
    range_miles real -- miles
);
ALTER TABLE raob_profile OWNER to mesonet;
CREATE INDEX raob_profile_fid_idx on raob_profile(fid);
GRANT SELECT on raob_profile to nobody;

do
$do$
declare
     y int;
begin
    for y in 1946..2030
    loop
    execute format($f$
        CREATE TABLE raob_profile_%s
            (LIKE raob_profile INCLUDING all);
        ALTER TABLE raob_profile_%s INHERIT raob_profile;
        ALTER TABLE raob_profile_%s OWNER to mesonet;
        alter table raob_profile_%s add constraint fid_fk FOREIGN KEY (fid)
            REFERENCES raob_flights(fid) ON DELETE CASCADE ON UPDATE CASCADE;
        GRANT SELECT on raob_profile_%s to nobody;
    $f$, y, y, y, y, y
    );
    end loop;
end;
$do$;
