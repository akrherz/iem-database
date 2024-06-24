CREATE TABLE wind_results_by_huc12(
    huc_12 char(12),
    scenario int references scenarios(id),
    valid date,
    avg_loss real
);
ALTER TABLE wind_results_by_huc12 OWNER to mesonet;
GRANT SELECT on wind_results_by_huc12 to nobody;
CREATE INDEX wind_results_by_huc12_huc_12_idx on wind_results_by_huc12(huc_12);
CREATE INDEX wind_results_by_huc12_valid_idx on wind_results_by_huc12(valid);
