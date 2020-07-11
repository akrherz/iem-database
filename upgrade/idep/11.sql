-- Clean up the ia_huc12 table
ALTER TABLE ia_huc12 RENAME to huc12;
ALTER TABLE huc12 add scenario int REFERENCES scenarios(id);
CREATE UNIQUE INDEX huc12_idx on huc12(huc_12, scenario);

UPDATE huc12 SET scenario = 0;
INSERT into huc12(huc_8, huc_10, huc_12, acres,
	hu_10_ds, hu_10_name, hu_10_type, hu_12_ds, hu_12_name, hu_12_mod,
	hu_12_type, meta_id, states, areapctmea, shape_leng, shape_area,
	buffdist, geom, simple_geom, scenario)
	SELECT huc_8, huc_10, huc_12, acres,
	hu_10_ds, hu_10_name, hu_10_type, hu_12_ds, hu_12_name, hu_12_mod,
	hu_12_type, meta_id, states, areapctmea, shape_leng, shape_area,
	buffdist, geom, simple_geom, 1 from huc12 where scenario = 0;
	
INSERT into huc12(huc_8, huc_10, huc_12, acres,
	hu_10_ds, hu_10_name, hu_10_type, hu_12_ds, hu_12_name, hu_12_mod,
	hu_12_type, meta_id, states, areapctmea, shape_leng, shape_area,
	buffdist, geom, simple_geom, scenario)
	SELECT huc_8, huc_10, huc_12, acres,
	hu_10_ds, hu_10_name, hu_10_type, hu_12_ds, hu_12_name, hu_12_mod,
	hu_12_type, meta_id, states, areapctmea, shape_leng, shape_area,
	buffdist, geom, simple_geom, 2 from huc12 where scenario = 0;
	
INSERT into huc12(huc_8, huc_10, huc_12, acres,
	hu_10_ds, hu_10_name, hu_10_type, hu_12_ds, hu_12_name, hu_12_mod,
	hu_12_type, meta_id, states, areapctmea, shape_leng, shape_area,
	buffdist, geom, simple_geom, scenario)
	SELECT huc_8, huc_10, huc_12, acres,
	hu_10_ds, hu_10_name, hu_10_type, hu_12_ds, hu_12_name, hu_12_mod,
	hu_12_type, meta_id, states, areapctmea, shape_leng, shape_area,
	buffdist, geom, simple_geom, 3 from huc12 where scenario = 0;
	
INSERT into huc12(huc_8, huc_10, huc_12, acres,
	hu_10_ds, hu_10_name, hu_10_type, hu_12_ds, hu_12_name, hu_12_mod,
	hu_12_type, meta_id, states, areapctmea, shape_leng, shape_area,
	buffdist, geom, simple_geom, scenario)
	SELECT huc_8, huc_10, huc_12, acres,
	hu_10_ds, hu_10_name, hu_10_type, hu_12_ds, hu_12_name, hu_12_mod,
	hu_12_type, meta_id, states, areapctmea, shape_leng, shape_area,
	buffdist, geom, simple_geom, 4 from huc12 where scenario = 0;
	
INSERT into huc12(huc_8, huc_10, huc_12, acres,
	hu_10_ds, hu_10_name, hu_10_type, hu_12_ds, hu_12_name, hu_12_mod,
	hu_12_type, meta_id, states, areapctmea, shape_leng, shape_area,
	buffdist, geom, simple_geom, scenario)
	SELECT huc_8, huc_10, huc_12, acres,
	hu_10_ds, hu_10_name, hu_10_type, hu_12_ds, hu_12_name, hu_12_mod,
	hu_12_type, meta_id, states, areapctmea, shape_leng, shape_area,
	buffdist, geom, simple_geom, 5 from huc12 where scenario = 0;
	
INSERT into huc12(huc_8, huc_10, huc_12, acres,
	hu_10_ds, hu_10_name, hu_10_type, hu_12_ds, hu_12_name, hu_12_mod,
	hu_12_type, meta_id, states, areapctmea, shape_leng, shape_area,
	buffdist, geom, simple_geom, scenario)
	SELECT huc_8, huc_10, huc_12, acres,
	hu_10_ds, hu_10_name, hu_10_type, hu_12_ds, hu_12_name, hu_12_mod,
	hu_12_type, meta_id, states, areapctmea, shape_leng, shape_area,
	buffdist, geom, simple_geom, 6 from huc12 where scenario = 0;
	