-- GSSURGO Metadata
CREATE TABLE gssurgo(
    id serial UNIQUE NOT NULL,
    fiscal_year int,
    mukey int,
    label text,
    kwfact real,
    hydrogroup varchar(8)
);
ALTER TABLE gssurgo OWNER to mesonet;
GRANT SELECT on gssurgo to nobody;
CREATE INDEX gssurgo_idx on gssurgo(id);
CREATE UNIQUE INDEX gssurgo_mukey_idx on gssurgo(fiscal_year, mukey);

ALTER TABLE flowpath_ofes ADD gssurgo_id int REFERENCES gssurgo(id);
ALTER TABLE flowpath_points ADD gssurgo_id int REFERENCES gssurgo(id);
