-- Unused columns
alter table current drop qc_tmpf;
alter table current_log drop qc_tmpf;
alter table current drop qc_dwpf;
alter table current_log drop qc_dwpf;

alter table current add srad_1h_j real;
alter table current_log add srad_1h_j real;

drop table current_tmp;
