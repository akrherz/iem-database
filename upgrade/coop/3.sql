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