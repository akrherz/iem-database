---
--- Storage of Flowpaths
---
--- DROP TABLE flowpaths CASCADE;
--- DROP TABLE flowpath_points;

CREATE TABLE flowpaths(
  fid serial UNIQUE,
  huc_12 char(12),
  fpath int
);
SELECT AddGeometryColumn('flowpaths', 'geom', 26915, 'LINESTRING', 2);
create index flowpaths_huc12_fpath_idx on flowpaths(huc_12,fpath);
GRANT SELECT on flowpaths to nobody,apache;
CREATE INDEX flowpaths_idx on flowpaths USING GIST(geom);

---
--- Raw Points on each flowpath
---
CREATE  TABLE flowpath_points(
  flowpath int references flowpaths(fid),
  segid int,
  elevation real,
  length real,
  surgo int,
  management smallint,
  slope real,
  landuse1 char(1),
  landuse2 char(1),
  landuse3 char(1),
  landuse4 char(1),
  landuse5 char(1),
  landuse6 char(1)
);
SELECT AddGeometryColumn('flowpath_points', 'geom', 26915, 'POINT', 2);
create index flowpath_points_flowpath_idx on flowpath_points(flowpath);
GRANT SELECT on flowpath_points to nobody,apache;

---
--- xref of surgo values to soils file
---
CREATE TABLE xref_surgo(
  surgo int,
  soilfile varchar(24)
);
create index xref_surgo_idx on xref_surgo(surgo);

