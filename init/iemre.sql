-- We want Postgis
CREATE EXTENSION postgis;

-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
	version int,
	updated timestamptz
);
INSERT into iem_schema_manager_version values (3, now());

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
begin
    for x in 0..487
    loop
        for y in 0..215
        loop
        execute format($f$
            INSERT into iemre_grid(gid, cell_center, hasdata, gridx, gridy,
            cell_polygon)
            VALUES (%s, 'SRID=4326;POINT(%s %s)', 't', %s, %s,
            'SRID=4326;Polygon((%s %s, %s %s, %s %s, %s %s, %s %s))')
        $f$, x + y * 488, -125.9375 + x * 0.125, 23.0625 + y * 0.125, x, y,
        -125.9375 + x * 0.125 - 0.0625, 23.0625 + y * 0.125 - 0.0625,
        -125.9375 + x * 0.125 - 0.0625, 23.0625 + y * 0.125 + 0.0625,
        -125.9375 + x * 0.125 + 0.0625, 23.0625 + y * 0.125 + 0.0625,
        -125.9375 + x * 0.125 + 0.0625, 23.0625 + y * 0.125 - 0.0625,
        -125.9375 + x * 0.125 - 0.0625, 23.0625 + y * 0.125 - 0.0625
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
