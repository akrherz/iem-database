-- Migration to EPSG:5070, see github issue 31

ALTER TABLE flowpath_points
 ALTER COLUMN geom TYPE geometry(POINT, 5070)
 USING ST_Transform(ST_SetSRID(geom, 26915), 5070);

ALTER TABLE flowpaths
 ALTER COLUMN geom TYPE geometry(LINESTRING, 5070)
 USING ST_Transform(ST_SetSRID(geom, 26915), 5070);

ALTER TABLE huc12
 ALTER COLUMN geom TYPE geometry(MULTIPOLYGON, 5070)
 USING ST_Transform(ST_SetSRID(geom, 26915), 5070);
 
ALTER TABLE huc12
 ALTER COLUMN simple_geom TYPE geometry(POLYGON, 5070)
 USING ST_Transform(ST_SetSRID(simple_geom, 26915), 5070);
 
DROP TABLE ia_huc8;
DROP TABLE hillslopes;

ALTER TABLE huc12 add ugc char(6);
