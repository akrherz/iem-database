-- Wind and Temp Aloft Forecast
create table alldata_tempwind_aloft(
    station char(4),
    obtime timestamptz,
    ftime timestamptz,
    tmpc1000 smallint,
    drct1000 smallint,
    sknt1000 smallint,

    tmpc1500 smallint,
    drct1500 smallint,
    sknt1500 smallint,

    tmpc2000 smallint,
    drct2000 smallint,
    sknt2000 smallint,

    tmpc3000 smallint,
    drct3000 smallint,
    sknt3000 smallint,

    tmpc6000 smallint,
    drct6000 smallint,
    sknt6000 smallint,

    tmpc9000 smallint,
    drct9000 smallint,
    sknt9000 smallint,

    tmpc12000 smallint,
    drct12000 smallint,
    sknt12000 smallint,

    tmpc15000 smallint,
    drct15000 smallint,
    sknt15000 smallint,

    tmpc18000 smallint,
    drct18000 smallint,
    sknt18000 smallint,

    tmpc24000 smallint,
    drct24000 smallint,
    sknt24000 smallint,

    tmpc30000 smallint,
    drct30000 smallint,
    sknt30000 smallint,

    tmpc34000 smallint,
    drct34000 smallint,
    sknt34000 smallint,

    tmpc39000 smallint,
    drct39000 smallint,
    sknt39000 smallint,

    tmpc45000 smallint,
    drct45000 smallint,
    sknt45000 smallint,

    tmpc53000 smallint,
    drct53000 smallint,
    sknt53000 smallint
) partition by range(ftime);
alter table alldata_tempwind_aloft owner to mesonet;
grant all on alldata_tempwind_aloft to ldm;
grant select on alldata_tempwind_aloft to nobody;

do
$do$
declare
     year int;
begin
    for year in 2004..2030
    loop
        execute format($f$
            create table tempwind_aloft_%s partition of alldata_tempwind_aloft
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
            $f$, year, year, year + 1);
        execute format($f$
            alter table tempwind_aloft_%s owner to mesonet
        $f$, year);
        execute format($f$
            grant all on tempwind_aloft_%s to ldm
        $f$, year);
        execute format($f$
            grant select on tempwind_aloft_%s to nobody
        $f$, year);
        -- Indices
        execute format($f$
            create index tempwind_aloft_%s_station_idx
            on tempwind_aloft_%s(station)
        $f$, year, year);
        execute format($f$
            create index tempwind_aloft_%s_ftime_idx
            on tempwind_aloft_%s(ftime)
        $f$, year, year);
    end loop;
end;
$do$;
