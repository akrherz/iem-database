-- dailyerosion/dep#90

CREATE TABLE general_landuse(
    id smallint,
    label text
);
CREATE UNIQUE index general_landuse_idx on general_landuse(id);
ALTER TABLE general_landuse OWNER to mesonet;
GRANT SELECT on general_landuse to nobody,apache;

ALTER TABLE flowpath_points add fbndid int;
ALTER TABLE flowpath_points add genlu smallint REFERENCES general_landuse(id);
ALTER TABLE flowpath_points add ofe smallint;
