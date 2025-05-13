create table alldata_sigmets(
    sigmet_type char(1) not null,
    label varchar(16) not null,
    issue timestamp with time zone not null,
    expire timestamp with time zone not null,
    product_id varchar(36) not null,
    geom geometry(Polygon, 4326) not null,
    narrative text
) partition by range(issue);
alter table alldata_sigmets owner to mesonet;
grant all on alldata_sigmets to ldm;
grant select on alldata_sigmets to nobody;
create index alldata_sigmets_idx on alldata_sigmets(issue);

do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2005..2030
    loop
        mytable := format($f$sigmets_%s$f$, year);
        execute format($f$
            create table %s partition of alldata_sigmets
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
            $f$, mytable, year, year + 1);
        execute format($f$
            ALTER TABLE %s OWNER to mesonet
        $f$, mytable);
        execute format($f$
            GRANT ALL on %s to ldm
        $f$, mytable);
        execute format($f$
            GRANT SELECT on %s to nobody
        $f$, mytable);
    end loop;
end;
$do$;
