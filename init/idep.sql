---
--- Version information storage
---

CREATE EXTENSION postgis;

CREATE TABLE iem_version(
  name varchar(50) UNIQUE,
  version int);
  
insert into iem_version values ('schema', -1);

create table scenarios (id int UNIQUE, label varchar);
GRANT SELECT on scenarios to nobody,apache;

insert into scenarios(id, label) values (0, 'Production');
insert into scenarios(id, label) values (1, 'G4');
insert into scenarios(id, label) values (2, 'dbfsOrgnlTesting');

CREATE TABLE huc12(
    gid SERIAL,
    huc_8 varchar(8),
    huc_10 varchar(10),
    huc_12 varchar(12),
    acres numeric,
    hu_10_ds varchar(10),
    hu_10_name text,
    hu_10_mod text,
    hu_10_type char(1),
    hu_12_ds varchar(10),
    hu_12_name text,
    hu_12_mod text,
    hu_12_type char(1),
    meta_id varchar(4),
    states text,
    areapctmea real,
    shape_leng numeric,
    shape_area numeric,
    buffdist smallint,
    geom geometry(MultiPolygon, 5070),
    simple_geom geometry(Polygon, 5070),
    scenario int REFERENCES scenarios(id),
    ugc char(6),
    mlra_id smallint
);
CREATE UNIQUE INDEX huc12_idx on huc12(huc_12, scenario);
GRANT SELECT on huc12 to nobody,apache;
