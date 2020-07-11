-- Create a simplified geometry to cut down on the GeoJSON sizes, but
-- yet look okay zoomed in!
ALTER TABLE ia_huc12 add simple_geom geometry(Polygon, 26915);

UPDATE ia_huc12 SET simple_geom = ST_SimplifyPreserveTopology(geom, 250);