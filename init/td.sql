CREATE EXTENSION postgis;

-- bandaid
insert into spatial_ref_sys select 9311, 'EPSG', 9311, srtext, proj4text from spatial_ref_sys where srid = 2163;

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
CREATE INDEX tileflow_data_idx on tileflow_data(uniqueid, plotid, valid);
GRANT SELECT on tileflow_data to nobody;
CREATE TABLE public.water_stage_data (
    siteid text,
    location text,
    date date,
    stage real
);
grant select on water_stage_data to nobody;
ALTER TABLE public.water_stage_data OWNER TO mesonet;
CREATE TABLE public.water_quality_data (
    siteid text,
    plotid text,
    location text,
    height real,
    date date,
    sample_type text,
    nitrate_n_concentration text,
    ammonia_n_concentration text,
    total_n_filtered_concentration real,
    total_n_unfiltered_concentration real,
    ortho_p_filtered_concentration text,
    ortho_p_unfiltered_concentration text,
    total_p_filtered_concentration text,
    total_p_unfiltered_concentration real,
    ph real,
    water_ec real
);
grant select on water_quality_data to nobody;
ALTER TABLE public.water_quality_data OWNER TO mesonet;

CREATE TABLE public.td_data_dictionary (
    sheet_name character varying,
    "primary" character varying,
    scope_td_tab character varying,
    "#_td_sites_collecting_v._12.2015_*est." character varying,
    american_units character varying,
    bmp_db character varying,
    code_column_heading character varying,
    comments_for_data_team character varying,
    created character varying,
    created_by character varying,
    cscap_sorting_column character varying,
    cscap_team__required_status character varying,
    data_type character varying,
    frequency character varying,
    icasa_code character varying,
    "included_in_m&m_export_text" character varying,
    methodology_of_cscap_team character varying,
    methodology_of_td_team character varying,
    modified character varying,
    modified_by character varying,
    responsibility character varying,
    scope_cscap_tab character varying,
    short_description character varying,
    stewards_code character varying,
    stewards_method_name character varying,
    stewards_sample_types character varying,
    "stewards_units format" character varying,
    "td_sites_collecting_v._12.2015" character varying,
    td_sorting_column character varying,
    td_team__requirement_status character varying,
    team character varying,
    units character varying,
    value_range character varying,
    value_range_american_units character varying
);
grant select on td_data_dictionary to nobody;
ALTER TABLE public.td_data_dictionary OWNER TO mesonet;


CREATE TABLE public.weather_data (
    siteid text,
    station text,
    date date,
    precipitation real,
    relative_humidity real,
    air_temp_avg real,
    air_temp_min real,
    air_temp_max real,
    dew_point_temp_avg real,
    solar_radiation real,
    wind_speed real,
    wind_direction real,
    et real,
    et_method text
);
grant select on weather_data to nobody;
ALTER TABLE public.weather_data OWNER TO mesonet;


CREATE TABLE public.tile_flow_and_n_loads_data (
    siteid text,
    plotid text,
    location text,
    date date,
    dwm_treatment text,
    tile_flow real,
    discharge real,
    nitrate_n_load real,
    nitrate_n_removed real,
    tile_flow_filled real,
    nitrate_n_load_filled real,
    comments text
);
grant select on tile_flow_and_n_loads_data to nobody;
ALTER TABLE public.tile_flow_and_n_loads_data OWNER TO mesonet;



CREATE TABLE public.soil_moisture_data (
    siteid text,
    plotid text,
    location text,
    depth real,
    date date,
    soil_moisture real,
    soil_temperature real,
    soil_ec real
);
grant select on soil_moisture_data to nobody;
ALTER TABLE public.soil_moisture_data OWNER TO mesonet;


CREATE TABLE public.water_table_data (
    siteid text,
    plotid text,
    location text,
    reading_type text,
    date date,
    water_table_depth real
);
grant select on water_table_data to nobody;
ALTER TABLE public.water_table_data OWNER TO mesonet;


CREATE TABLE public.soil_properties_data (
    siteid text,
    plotid text,
    location text,
    subsample text,
    depth text,
    year integer,
    date date,
    soil_texture text,
    percent_sand real,
    percent_silt real,
    percent_clay real,
    bulk_density real,
    hydraulic_conductivity text,
    infiltration_rate real,
    matric_potential real,
    water_content real,
    som real,
    ph_water real,
    ph_salt real,
    lime_index real,
    neutralizable_acidity real,
    cec real,
    k_saturation real,
    ca_saturation real,
    mg_saturation real,
    na_saturation real,
    k_concentration real,
    ca_concentation real,
    mg_concentration real,
    na_concentration real,
    k_amount real,
    ca_amount real,
    mg_amount real,
    sar real,
    salinity_paste real,
    salinity_water real,
    soc real,
    total_n real,
    no3_concentration text,
    nh4_concentration real,
    no3_amount real,
    nh4_amount real,
    p_b1_concentration real,
    p_m3_concentration real,
    p_b1_amount real
);
alter table soil_properties_data owner to mesonet;
grant select on soil_properties_data to nobody;

CREATE TABLE public.agronomic_data (
    siteid text,
    plotid text,
    location text,
    crop text,
    trt_2 text,
    trt_value_2 text,
    year integer,
    date date,
    leaf_area_index real,
    final_plant_population real,
    grain_moisture real,
    crop_yield real,
    standard_moisture text,
    whole_plant_biomass real,
    vegetative_biomass real,
    grain_biomass real,
    corn_cob_biomass real,
    forage_biomass real,
    whole_plant_total_n real,
    vegetative_total_n real,
    grain_total_n real,
    corn_cob_total_n real,
    vegetative_total_c real,
    grain_total_c real,
    corn_cob_total_c real
);
alter table agronomic_data owner to mesonet;
ALTER TABLE public.agronomic_data OWNER TO mesonet;

CREATE TABLE public.agronomic_data_log (
    uniqueid character varying(24),
    plotid character varying(24),
    varname character varying(24),
    year smallint,
    value character varying(32),
    updated timestamp with time zone DEFAULT now()
);


ALTER TABLE public.agronomic_data_log OWNER TO mesonet;
CREATE FUNCTION public.agronomic_insert_before_f() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
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

END; $$;

CREATE TABLE public.meta_treatment_identifier (
    siteid text,
    plotid text,
    dwmid text,
    irrid text,
    year integer,
    drainage_water_management text,
    irrigation text,
    comments text
);
alter table meta_treatment_identifier owner to mesonet;
ALTER TABLE public.meta_treatment_identifier OWNER TO mesonet;


-- Storage of water table data
CREATE TABLE watertable_data(
  uniqueid varchar(24),
  plotid varchar(24),
  valid timestamptz,
  depth_mm real,
  depth_mm_qcflag char(1),
  depth_mm_qc real);
CREATE INDEX watertable_data_idx on watertable_data(uniqueid, plotid, valid);
GRANT SELECT on watertable_data to nobody;

