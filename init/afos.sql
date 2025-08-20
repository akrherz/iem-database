
-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
    version int,
    updated timestamptz);
INSERT into iem_schema_manager_version values (10, now());

CREATE TABLE products(
  data text,
  pil char(6) not null,
  entered timestamptz,
  source char(4),
  wmo char(6),
  bbb varchar(3)
) PARTITION by RANGE (entered);
ALTER TABLE products OWNER to mesonet;
GRANT ALL on products to ldm;
GRANT SELECT on products to nobody;


do
$do$
declare
     year int;
     month int;
     mytable varchar;
begin
    for year in 1982..2030
    loop
        for month in 1..2
        loop
            mytable := format($f$products_%s_%s$f$,
                year, case when month = 1 then '0106' else '0712' end);
            execute format($f$
                create table %s partition of products
                for values from ('%s-%s-01 00:00+00') to ('%s-%s-01 00:00+00')
                $f$, mytable,
                year,
                case when month = 1 then 1 else 7 end,
                case when month = 1 then year else year + 1 end,
                case when month = 1 then 7 else 1 end);
            execute format($f$
                ALTER TABLE %s OWNER to mesonet
            $f$, mytable);
            execute format($f$
                GRANT ALL on %s to ldm
            $f$, mytable);
            execute format($f$
                GRANT SELECT on %s to nobody
            $f$, mytable);
            -- Indices
            execute format($f$
                CREATE INDEX on %s(substr(pil, 1, 3))
            $f$, mytable);
            execute format($f$
                CREATE INDEX %s_pil_idx on %s(pil)
            $f$, mytable, mytable);
            execute format($f$
                CREATE INDEX %s_entered_idx on %s(entered)
            $f$, mytable, mytable);
            execute format($f$
                CREATE INDEX %s_source_idx on %s(source)
            $f$, mytable, mytable);
            execute format($f$
                CREATE INDEX %s_pe_idx on %s(pil, entered)
            $f$, mytable, mytable);
        end loop;
    end loop;
end;
$do$;
