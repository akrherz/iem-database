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

