-- We want Postgis
CREATE EXTENSION postgis;

-- bandaid
insert into spatial_ref_sys
select 9311, 'EPSG', 9311, srtext, proj4text from spatial_ref_sys
where srid = 2163;

-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
    version int,
    updated timestamptz
);
INSERT into iem_schema_manager_version values (-1, now());

-- Our baseline grid
CREATE TABLE iemre_grid(
    gid int NOT NULL, -- (gridx + gridy * 488) - 1
    cell_center geometry(Point, 4326),
    cell_polygon geometry(Polygon, 4326),
    hasdata boolean,
    gridx int,
    gridy int
);
GRANT ALL on iemre_grid to mesonet,ldm;
GRANT SELECT on iemre_grid to nobody;

-- fill out the grid, since we can
do
$do$
declare
     x int;
     y int;
     left_edge real = -81.5625;
     left_center real = -81.5;
     bottom_edge real = -55.9375;
     bottom_center real = -55.875;
     spacing real = 0.125;
     columns int = 380;
begin
    for x in 0..379
    loop
        for y in 0..547
        loop
        execute format($f$
            INSERT into iemre_grid(gid, cell_center, hasdata, gridx, gridy,
            cell_polygon)
            VALUES (%s, ST_Point(%s, %s, 4326), 't', %s, %s,
            ST_MakeEnvelope(%s, %s, %s, %s, 4326))
        $f$,
        x + y * columns,
        left_center + x * spacing,
        bottom_center + y * spacing,
        x,
        y,
        left_edge + x * spacing,
        bottom_edge + y * spacing,
        left_edge + (x + 1) * spacing,
        bottom_edge + (y  + 1) * spacing
        );
        end loop;
    end loop;
end;
$do$;


-- Create indices
CREATE INDEX iemre_grid_gix ON iemre_grid USING GIST (cell_center);
CREATE INDEX iemre_grid_cell_gix ON iemre_grid USING GIST (cell_polygon);
CREATE UNIQUE INDEX iemre_grid_gid_idx on iemre_grid(gid);
CREATE UNIQUE INDEX iemre_grid_idx on iemre_grid(gridx, gridy);

-- _______________________________________________________________________
-- Storage of daily analysis
CREATE TABLE iemre_daily(
    gid int REFERENCES iemre_grid(gid),
    valid date,
    high_tmpk real,
    low_tmpk real,
    high_tmpk_12z real,
    low_tmpk_12z real,
    p01d real,
    p01d_12z real,
    rsds real,
    snow_12z real,
    snowd_12z real,
    avg_dwpk real,
    wind_speed real,
    power_swdn real,
    min_rh real,
    max_rh real,
    high_soil4t real,
    low_soil4t real
) PARTITION by RANGE (valid);
ALTER TABLE iemre_daily OWNER to mesonet;
GRANT ALL on iemre_daily to ldm;
GRANT SELECT on iemre_daily to nobody;

CREATE INDEX on iemre_daily(valid);
CREATE INDEX on iemre_daily(gid);


do
$do$
declare
     year int;
begin
    for year in 1893..2030
    loop
        execute format($f$
            create table iemre_daily_%s partition of iemre_daily
            for values from ('%s-01-01') to ('%s-01-01')
        $f$, year, year, year + 1);
        execute format($f$
            GRANT ALL on iemre_daily_%s to mesonet,ldm
        $f$, year);
        execute format($f$
            GRANT SELECT on iemre_daily_%s to nobody
        $f$, year);
    end loop;
end;
$do$;

-- _______________________________________________________________________
-- Storage of CFS forecast
CREATE TABLE iemre_daily_forecast(
    gid int REFERENCES iemre_grid(gid),
    valid date,
    high_tmpk real,
    low_tmpk real,
    p01d real,
    rsds real
);
ALTER TABLE iemre_daily_forecast OWNER to mesonet;
GRANT ALL on iemre_daily_forecast to mesonet,ldm;
GRANT SELECT on iemre_daily_forecast to nobody;

CREATE INDEX on iemre_daily_forecast(valid);
CREATE INDEX on iemre_daily_forecast(gid);

-- _______________________________________________________________________
-- Storage of daily climatology
CREATE TABLE iemre_dailyc(
    gid int REFERENCES iemre_grid(gid),
    valid date,
    high_tmpk real,
    low_tmpk real,
    p01d real
);
ALTER TABLE iemre_dailyc OWNER to mesonet;
GRANT ALL on iemre_dailyc to mesonet,ldm;
GRANT SELECT on iemre_dailyc to nobody;

CREATE INDEX on iemre_dailyc(valid);
CREATE INDEX on iemre_dailyc(gid);
