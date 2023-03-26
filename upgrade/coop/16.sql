-- Storage of American Somoa
create table alldata_as partition of alldata
 for values from ('AS0000') to ('ASZZZZ');
grant select on alldata_as to nobody;

create unique index alldata_as_idx on alldata_as(station, day);
create index alldata_as_day_idx on alldata_as(day);
create index alldata_as_sday_idx on alldata_as(sday);
create index alldata_as_stationid_idx on alldata_as(station);
create index alldata_as_year_idx on alldata_as(year);
