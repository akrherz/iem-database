-- Explicit Storage of daily max/min 4 inch soil temperature
alter table sm_daily add t4_c_min real;
alter table sm_daily add t4_c_min_f char(1);
alter table sm_daily add t4_c_min_qc real;
alter table sm_daily add t4_c_max real;
alter table sm_daily add t4_c_max_f char(1);
alter table sm_daily add t4_c_max_qc real;
