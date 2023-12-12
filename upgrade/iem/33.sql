-- Unused columns
alter table current drop qc_tmpf;
alter table current_log drop qc_tmpf;
alter table current drop qc_dwpf;
alter table current_log drop qc_dwpf;

alter table current add srad_1h_j real;
alter table current_log add srad_1h_j real;

drop table current_tmp;

alter table current add tsoil_4in_f real;
alter table current_log add tsoil_4in_f real;

alter table current add tsoil_8in_f real;
alter table current_log add tsoil_8in_f real;

alter table current add tsoil_16in_f real;
alter table current_log add tsoil_16in_f real;

alter table current add tsoil_20in_f real;
alter table current_log add tsoil_20in_f real;

alter table current add tsoil_32in_f real;
alter table current_log add tsoil_32in_f real;

alter table current add tsoil_40in_f real;
alter table current_log add tsoil_40in_f real;

alter table current add tsoil_64in_f real;
alter table current_log add tsoil_64in_f real;

alter table current add tsoil_128in_f real;
alter table current_log add tsoil_128in_f real;
