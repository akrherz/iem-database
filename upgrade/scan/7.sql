-- Fix previous mistakes

do
$do$
declare
     year int;
begin
    for year in 1983..2030
    loop
        execute format($f$
            ALTER TABLE t%s_hourly RENAME to t%s
            $f$, year, year);
    end loop;
end;
$do$;