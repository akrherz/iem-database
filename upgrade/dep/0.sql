-- Storage of tillage direction
ALTER TABLE field ADD tillage_direction real;

-- OFE helper view to make life easier
CREATE VIEW ofe_view AS
SELECT
    p.scenario_id,
    h.huc12_code,
    p.huc12_fpath_num,
    o.ofe,
    f.field_id,
    g.mukey,
    c.filepath AS climate_filepath,
    f.landuse,
    f.management,
    f.tillage_direction,
    p.length_m AS flowpath_length_m,
    o.length_m AS ofe_length_m,
    ST_X(ST_POINTN(ST_TRANSFORM(p.geom, 4326), 1)) AS start_lon,
    ST_Y(ST_POINTN(ST_TRANSFORM(p.geom, 4326), 1)) AS start_lat
FROM flowpath_ofe AS o
INNER JOIN flowpath AS p ON (o.flowpath_id = p.flowpath_id)
INNER JOIN climate_file AS c ON (p.climate_file_id = c.climate_file_id)
INNER JOIN huc12 AS h ON (p.huc12_id = h.huc12_id)
INNER JOIN field AS f ON (o.field_id = f.field_id)
INNER JOIN gssurgo AS g ON (o.gssurgo_id = g.gssurgo_id)
ORDER BY p.scenario_id, h.huc12_code, p.huc12_fpath_num, o.ofe;

-- Flowpath helper
CREATE VIEW flowpath_view AS
SELECT
    p.scenario_id,
    h.huc12_code,
    p.huc12_fpath_num,
    c.filepath AS climate_filepath,
    p.length_m AS flowpath_length_m,
    ST_X(ST_POINTN(ST_TRANSFORM(p.geom, 4326), 1)) AS start_lon,
    ST_Y(ST_POINTN(ST_TRANSFORM(p.geom, 4326), 1)) AS start_lat
FROM flowpath AS p
INNER JOIN climate_file AS c ON (p.climate_file_id = c.climate_file_id)
INNER JOIN huc12 AS h ON (p.huc12_id = h.huc12_id)
ORDER BY p.scenario_id, h.huc12_code, p.huc12_fpath_num;
