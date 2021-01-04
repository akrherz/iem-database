-- Storage for PR
CREATE TABLE alldata_pr() inherits (alldata); 
GRANT SELECT on alldata_pr to nobody,apache;

CREATE UNIQUE index alldata_PR_idx on alldata_PR(station, day);
CREATE INDEX alldata_PR_day_idx on alldata_PR(day);
CREATE INDEX alldata_PR_sday_idx on alldata_PR(sday);
CREATE INDEX alldata_PR_stationid_idx on alldata_PR(station);
CREATE INDEX alldata_PR_year_idx on alldata_PR(year);
