--
-- CoCoRaHS data
create table alldata_cocorahs(
    iemid int REFERENCES stations(iemid),
    day date,
    obvalid timestamptz,
    updated timestamptz,
    precip real,
    snow real,
    snowd real,
    snow_swe real,
    snowd_swe real
) partition by range(day);
alter table alldata_cocorahs owner to mesonet;
grant select on alldata_cocorahs to nobody;
create index alldata_cocorahs_iemid_idx on alldata_cocorahs(iemid);
create index alldata_cocorahs_day_idx on alldata_cocorahs(day);

do
$do$
declare
    year int;
begin
    for year in 2000..2030
    loop
        execute format($f$
            create table cocorahs_%s partition of alldata_cocorahs
            for values from ('%s-01-01') to ('%s-01-01')
            $f$, year, year, year + 1);
        execute format($f$
            alter table cocorahs_%s owner to mesonet
        $f$, year);
        execute format($f$
            grant select on cocorahs_%s to nobody
        $f$, year);
    end loop;
end;
$do$;
