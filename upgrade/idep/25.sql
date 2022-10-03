-- Store of Flowpath OFE information
CREATE TABLE flowpath_ofes(
    flowpath int REFERENCES flowpaths(fid),
    ofe smallint not null,
    geom geometry(LineString, 5070),
    bulk_slope real,
    surgo int,
    scenario int
);
ALTER TABLE flowpath_ofes OWNER to mesonet;
GRANT SELECT on flowpath_ofes to nobody;
CREATE INDEX flowpath_ofes_idx on flowpath_ofes(flowpath);
