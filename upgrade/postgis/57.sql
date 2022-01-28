-- Grid Population of the World
-- https://sedac.ciesin.columbia.edu/data/set/gpw-v4-population-count-rev11/data-download
CREATE TABLE gpw2020(
    geom geometry(Point,4326),
    population int
);
create index gpw2020_gix on gpw2020 USING GIST(geom);
ALTER TABLE gpw2020 OWNER to mesonet;
GRANT SELECT on gpw2020 to nobody;

--
CREATE TABLE gpw2015(
    geom geometry(Point,4326),
    population int
);
create index gpw2015_gix on gpw2015 USING GIST(geom);
ALTER TABLE gpw2015 OWNER to mesonet;
GRANT SELECT on gpw2015 to nobody;

--
CREATE TABLE gpw2010(
    geom geometry(Point,4326),
    population int
);
create index gpw2010_gix on gpw2010 USING GIST(geom);
ALTER TABLE gpw2010 OWNER to mesonet;
GRANT SELECT on gpw2010 to nobody;

--
CREATE TABLE gpw2005(
    geom geometry(Point,4326),
    population int
);
create index gpw2005_gix on gpw2005 USING GIST(geom);
ALTER TABLE gpw2005 OWNER to mesonet;
GRANT SELECT on gpw2005 to nobody;

--
CREATE TABLE gpw2000(
    geom geometry(Point,4326),
    population int
);
create index gpw2000_gix on gpw2000 USING GIST(geom);
ALTER TABLE gpw2000 OWNER to mesonet;
GRANT SELECT on gpw2000 to nobody;

--
ALTER TABLE ugcs add gpw_population_2000 int;
ALTER TABLE ugcs add gpw_population_2005 int;
ALTER TABLE ugcs add gpw_population_2010 int;
ALTER TABLE ugcs add gpw_population_2015 int;
ALTER TABLE ugcs add gpw_population_2020 int;
