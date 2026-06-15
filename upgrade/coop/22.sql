-- Storage of soil growing degree day climatology
ALTER TABLE climate81 ADD sgdd32 real;
ALTER TABLE climate81 ADD sgdd50 real;
ALTER TABLE climate81 ADD sgdd52 real;

ALTER TABLE climate71 ADD sgdd32 real;
ALTER TABLE climate71 ADD sgdd50 real;
ALTER TABLE climate71 ADD sgdd52 real;

ALTER TABLE climate51 ADD sgdd32 real;
ALTER TABLE climate51 ADD sgdd50 real;
ALTER TABLE climate51 ADD sgdd52 real;

ALTER TABLE climate ADD sgdd32 real;
ALTER TABLE climate ADD sgdd50 real;
ALTER TABLE climate ADD sgdd52 real;

ALTER TABLE ncdc_climate81 ADD sgdd32 real;
ALTER TABLE ncdc_climate81 ADD sgdd50 real;
ALTER TABLE ncdc_climate81 ADD sgdd52 real;

ALTER TABLE ncdc_climate71 ADD sgdd32 real;
ALTER TABLE ncdc_climate71 ADD sgdd50 real;
ALTER TABLE ncdc_climate71 ADD sgdd52 real;

ALTER TABLE ncei_climate91 ADD sgdd32 real;
ALTER TABLE ncei_climate91 ADD sgdd50 real;
ALTER TABLE ncei_climate91 ADD sgdd52 real;
