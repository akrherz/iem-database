-- Storage of TAF Information

CREATE TABLE taf(
    id SERIAL UNIQUE,
    station char(4),
    valid timestamptz,
    product_id char(32)
);
ALTER TABLE taf OWNER to mesonet;
GRANT ALL on taf to ldm;
GRANT SELECT on taf to nobody,apache;
CREATE INDEX taf_idx on taf(station, valid);
grant all on taf_id_seq to ldm;

CREATE TABLE taf_forecast(
    taf_id int REFERENCES taf(id),
    valid timestamptz,
    raw text,
    is_tempo boolean,
    end_valid timestamptz,
    sknt smallint,
    drct smallint,
    gust smallint,
    visibility float,
    presentwx text[],
    skyc varchar(3)[],
    skyl int[],
    ws_level int,
    ws_drct smallint,
    ws_sknt smallint
) PARTITION by range(valid);
ALTER TABLE taf_forecast OWNER to mesonet;
GRANT ALL on taf_forecast to ldm;
GRANT SELECT on taf_forecast to nobody,apache;

do
$do$
declare
     year int;
begin
    for year in 1995..2030
    loop
        execute format($f$
            create table taf%s partition of taf_forecast
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
            $f$, year, year, year + 1);
        execute format($f$
            ALTER TABLE taf%s ADD foreign key(taf_id)
            references taf(id);
        $f$, year);
        execute format($f$
            ALTER TABLE taf%s OWNER to mesonet
        $f$, year);
        execute format($f$
            GRANT ALL on taf%s to ldm
        $f$, year);
        execute format($f$
            GRANT SELECT on taf%s to nobody,apache
        $f$, year);
        -- Indices
        execute format($f$
            CREATE INDEX taf%s_valid_idx on taf%s(valid)
        $f$, year, year);
        execute format($f$
            CREATE INDEX taf%s_id_idx on taf%s(taf_id)
        $f$, year, year);
    end loop;
end;
$do$;
