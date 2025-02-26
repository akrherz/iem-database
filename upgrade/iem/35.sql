-- Drop unused summary table entries
alter table summary drop max_tmpf_qc;
alter table summary drop min_tmpf_qc;
alter table summary drop pday_qc;
alter table summary drop snow_qc;
