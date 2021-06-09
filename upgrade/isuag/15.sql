-- Storage of Solar Radiation
ALTER TABLE sm_hourly add slrkj_tot real;
ALTER TABLE sm_hourly add slrkj_tot_f char(1);
ALTER TABLE sm_hourly add slrkj_tot_qc real;

ALTER TABLE sm_daily add slrkj_tot real;
ALTER TABLE sm_daily add slrkj_tot_f char(1);
ALTER TABLE sm_daily add slrkj_tot_qc real;

-- How long our sm_minute data is
ALTER TABLE sm_minute add duration smallint DEFAULT 1;

-- Storage of Precipitation in inches
ALTER TABLE sm_hourly add rain_in_tot real;
ALTER TABLE sm_hourly add rain_in_tot_qc real;
ALTER TABLE sm_hourly add rain_in_tot_f char(1);

-- Storage of Precipitation in inches
ALTER TABLE sm_daily add rain_in_tot real;
ALTER TABLE sm_daily add rain_in_tot_qc real;
ALTER TABLE sm_daily add rain_in_tot_f char(1);
