-- Create some needed indexies
CREATE INDEX results_by_huc12_huc_12_idx on results_by_huc12(huc_12);
CREATE INDEX results_valid_idx on results(valid);
CREATE INDEX results_huc_12_idx on results(huc_12);

-- Add column for qc_precip from daily_clifile_editor
ALTER TABLE results_by_huc12 ADD qc_precip real;