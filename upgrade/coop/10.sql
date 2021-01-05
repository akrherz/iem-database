-- Storage for PR
CREATE TABLE alldata_pr() inherits (alldata); 
GRANT SELECT on alldata_pr to nobody,apache;

CREATE UNIQUE index alldata_PR_idx on alldata_PR(station, day);
CREATE INDEX alldata_PR_day_idx on alldata_PR(day);
CREATE INDEX alldata_PR_sday_idx on alldata_PR(sday);
CREATE INDEX alldata_PR_stationid_idx on alldata_PR(station);
CREATE INDEX alldata_PR_year_idx on alldata_PR(year);

CREATE TABLE alldata_vi() inherits (alldata);
GRANT SELECT on alldata_vi to nobody,apache;

CREATE UNIQUE index alldata_VI_idx on alldata_VI(station, day);
CREATE INDEX alldata_VI_day_idx on alldata_VI(day);
CREATE INDEX alldata_VI_sday_idx on alldata_VI(sday);
CREATE INDEX alldata_VI_stationid_idx on alldata_VI(station);
CREATE INDEX alldata_VI_year_idx on alldata_VI(year);

