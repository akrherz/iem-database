  -- Precip total from second bucket
ALTER TABLE sm_hourly add rain_in_2_tot real;
ALTER TABLE sm_hourly add rain_in_2_tot_qc real;
ALTER TABLE sm_hourly add rain_in_2_tot_f char(1);

ALTER TABLE sm_daily add rain_in_2_tot real;
ALTER TABLE sm_daily add rain_in_2_tot_qc real;
ALTER TABLE sm_daily add rain_in_2_tot_f char(1);
