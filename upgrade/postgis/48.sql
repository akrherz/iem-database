-- Special Weather Statements
CREATE TABLE sps(
    product_id varchar(32),
    product text,
    pil char(6),
    wfo char(3),
    issue timestamptz,
    expire timestamptz,
    geom geometry(Polygon, 4326),
    ugcs char(6)[],
    landspout text,
    waterspout text,
    max_hail_size text,
    max_wind_gust text,
    tml_valid timestamp with time zone,
    tml_direction smallint,
    tml_sknt smallint,
    tml_geom geometry(Point, 4326),
    tml_geom_line geometry(Linestring, 4326)
) PARTITION by range(issue);
ALTER TABLE sps OWNER to mesonet;
GRANT ALL on sps to ldm;
GRANT SELECT on sps to apache,nobody;

do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 1993..2040
    loop
        mytable := format($f$sps_%s$f$, year);
        execute format($f$
            create table %s partition of sps
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
            $f$, mytable, year, year + 1);
        execute format($f$
            ALTER TABLE %s OWNER to mesonet
        $f$, mytable);
        execute format($f$
            GRANT ALL on %s to ldm
        $f$, mytable);
        execute format($f$
            GRANT SELECT on %s to nobody,apache
        $f$, mytable);
        -- Indices
        execute format($f$
            CREATE INDEX %s_issue_idx on %s(issue)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_expire_idx on %s(expire)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_product_id_idx on %s(product_id)
        $f$, mytable, mytable);
        execute format($f$
            CREATE INDEX %s_wfo_idx on %s(wfo)
        $f$, mytable, mytable);
    end loop;
end;
$do$;
