-- Redoing SPC outlook storage
CREATE TABLE spc_outlook(
    id SERIAL UNIQUE NOT NULL,
    issue timestamptz NOT NULL,
    product_issue timestamptz NOT NULL,
    expire timestamptz NOT NULL,
    updated timestamptz DEFAULT now(),
    product_id varchar(32) NOT NULL,
    outlook_type char(1) NOT NULL,
    day smallint NOT NULL,
    cycle smallint NOT NULL
);
CREATE INDEX spc_outlook_product_issue on spc_outlook(product_issue);
CREATE INDEX spc_outlook_expire on spc_outlook(expire);
ALTER TABLE spc_outlook OWNER to mesonet;
GRANT ALL on spc_outlook to ldm;
GRANT SELECT on spc_outlook to nobody;
GRANT ALL on spc_outlook_id_seq to mesonet,ldm;

CREATE TABLE spc_outlook_geometries(
    spc_outlook_id int REFERENCES spc_outlook(id),
    threshold varchar(4) REFERENCES spc_outlook_thresholds(threshold),
    category varchar(64),
    geom geometry(MultiPolygon, 4326)
);
CREATE INDEX spc_outlook_geometries_idx
    on spc_outlook_geometries(spc_outlook_id);
CREATE INDEX spc_outlook_geometries_gix
    ON spc_outlook_geometries USING GIST (geom);
ALTER TABLE spc_outlook_geometries OWNER to mesonet;
GRANT ALL on spc_outlook_geometries to ldm;
GRANT SELECT on spc_outlook_geometries to nobody;
