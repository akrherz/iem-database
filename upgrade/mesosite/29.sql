-- Storage of DOT Roadway cam metadata
create table dot_roadway_cams(
    cam_id serial unique not null,
    device_id text not null,
    name text not null,
    archive_begin timestamptz not null,
    archive_end timestamptz,
    geom geometry(Point,4326)
);
alter table dot_roadway_cams owner to mesonet;
grant select on dot_roadway_cams to nobody;

create table dot_roadway_cams_log(
    cam_id int references dot_roadway_cams(cam_id),
    valid timestamp with time zone
) partition by range(valid);
alter table dot_roadway_cams_log owner to mesonet;
grant select on dot_roadway_cams_log to nobody;

do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2018..2030
    loop
        mytable := format($f$dot_roadway_cams_log_%s$f$, year);
        execute format($f$
            create table %s partition of dot_roadway_cams_log
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
            $f$, mytable, year, year + 1);
        execute format($f$
            alter table %s owner to mesonet
        $f$, mytable);
        execute format($f$
            grant select on %s to nobody
        $f$, mytable);
        -- Indices
        execute format($f$
            create index %s_valid_idx on %s(valid)
        $f$, mytable, mytable);
    end loop;
end;
$do$;
