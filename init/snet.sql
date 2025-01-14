-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
    version int,
    updated timestamptz);
INSERT into iem_schema_manager_version values (4, now());

CREATE TABLE dump (
    station character varying(5),
    valid timestamp with time zone,
    tmpf smallint,
    dwpf smallint,
    drct smallint,
    sknt real,
    pday real,
    pmonth real,
    srad real,
    relh real,
    alti real,
    gust real
);

CREATE TABLE temp (
    station character varying(5),
    valid timestamp with time zone,
    tmpf smallint,
    dwpf smallint,
    drct smallint,
    sknt real,
    pday real,
    pmonth real,
    srad real,
    relh real,
    alti real,
    gust real
);

CREATE TABLE alldata (
    station character varying(5),
    valid timestamp with time zone,
    tmpf smallint,
    dwpf smallint,
    drct smallint,
    sknt real,
    pday real,
    pmonth real,
    srad real,
    relh real,
    alti real,
    gust real
);
alter table alldata owner to mesonet;
GRANT SELECT on alldata to nobody;

do
$do$
declare
     year int;
     month int;
begin
    for year in 2002..2019
    loop
        for month in 1..12
        loop
            execute format($f$
                create table t%s_%s partition of alldata
                for values from ('%s-%s-01 00:00+00') to ('%s-%s-01 00:00+00')
            $f$, year, lpad(month::text, 2, '0'), year, month,
            case when month = 12 then year + 1 else year end,
            case when month = 12 then 1 else month + 1 end);
            execute format($f$
                alter table t%s_%s owner to mesonet
            $f$, year, lpad(month::text, 2, '0'));
            execute format($f$
                GRANT SELECT on t%s_%s to nobody
            $f$, year, lpad(month::text, 2, '0'));
            execute format($f$
                CREATE INDEX t%s_%s_station_idx on t%s_%s(station)
            $f$, year, lpad(month::text, 2, '0'),
            year, lpad(month::text, 2, '0'));
            execute format($f$
                CREATE INDEX t%s_%s_valid_idx on t%s_%s(valid)
            $f$, year, lpad(month::text, 2, '0'),
            year, lpad(month::text, 2, '0'));
        end loop;
    end loop;
end;
$do$;
