---
--- cross referenence of HUC12 hillslopes and their location
---
CREATE TABLE hillslopes(
  huc_12 varchar(12),
  hs_id int
);

SELECT AddGeometryColumn('hillslopes', 'geom', 4326, 'POINT', 2);

GRANT SELECT on hillslopes to nobody,apache;

---
--- Storage of raw results, temp table, more-or-less
---
CREATE TABLE results(
  huc_12 varchar(12),
  hs_id int,
  valid date,
  runoff real,
  loss real,
  precip real
);

---
--- Storage of huc12 level results
---
CREATE TABLE results_by_huc12(
  huc_12 varchar(12),
  valid date,
  min_precip real,
  avg_precip real,
  max_precip real,
  min_loss real,
  avg_loss real,
  max_loss real,
  ve_loss real,
  min_runoff real,
  avg_runoff real,
  max_runoff real,
  ve_runoff real
);

CREATE INDEX results_by_huc12_valid_idx on results_by_huc12(valid);

GRANT SELECT on results_by_huc12 to nobody,apache;