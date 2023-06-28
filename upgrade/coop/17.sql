-- NCEI climdiv storage
create table ncei_climdiv(
    station char(6),
    day date,
    high real,
    low real,
    precip real
);
alter table ncei_climdiv owner to mesonet;
grant select on ncei_climdiv to nobody;
create index ncei_climdiv_station_idx on ncei_climdiv(station);