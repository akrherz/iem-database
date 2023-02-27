-- Storage of polygons associated with regions we compute climodat for
CREATE TABLE climodat_regions(
    iemid int REFERENCES stations(iemid),
    geom geometry(MultiPolygon, 4326)
);
CREATE UNIQUE INDEX climodat_regions_idx on climodat_regions(iemid);
CREATE INDEX climodat_regions_gix on climodat_regions USING GIST(geom);
ALTER TABLE climodat_regions OWNER TO mesonet;
GRANT SELECT on climodat_regions to nobody, ldm;
