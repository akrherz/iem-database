-- Storage of NESDIS SCP Data
CREATE TABLE scp_alldata(
 station varchar(5),    
 valid timestamptz,
 mid varchar(3),
 high varchar(3),
 cldtop1 int,
 cldtop2 int,
 eca smallint
) PARTITION by range(valid);
ALTER TABLE scp_alldata OWNER to mesonet;
GRANT ALL on scp_alldata to ldm;
GRANT SELECT on scp_alldata to nobody,apache;

do
$do$
declare
     year int;
begin
    for year in 2003..2030
    loop
        execute format($f$
            create table scp%s partition of scp_alldata
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
            $f$, year, year, year + 1);
        execute format($f$
            ALTER TABLE scp%s OWNER to mesonet
        $f$, year);
        execute format($f$
            GRANT ALL on scp%s to ldm
        $f$, year);
        execute format($f$
            GRANT SELECT on scp%s to nobody,apache
        $f$, year);
        -- Indices
        execute format($f$
            CREATE INDEX scp%s_valid_idx on scp%s(valid)
        $f$, year, year);
        execute format($f$
            CREATE INDEX scp%s_station_idx on scp%s(station)
        $f$, year, year);
    end loop;
end;
$do$;
