-- Storage of WMO BUFR Station Data
alter table alldata add tsoil_4in_f real;
alter table alldata add tsoil_8in_f real;
alter table alldata add tsoil_16in_f real;
alter table alldata add tsoil_20in_f real;
alter table alldata add tsoil_32in_f real;
alter table alldata add tsoil_40in_f real;
alter table alldata add tsoil_64in_f real;
alter table alldata add tsoil_128in_f real;
alter table alldata add skyc1 char(3);
alter table alldata add skyc2 char(3);
alter table alldata add skyc3 char(3);
alter table alldata add skyc4 char(3);
alter table alldata add skyl1 int;
alter table alldata add skyl2 int;
alter table alldata add skyl3 int;
alter table alldata add skyl4 int;
alter table alldata add srad_1h_j real;
