-- Storage of Center Weather Advisories

CREATE TABLE cwas(
    center varchar(4),
    issue timestamptz,
    expire timestamptz,
    product_id varchar(35),
    narrative text,
    num smallint,
    geom geometry(Polygon,4326)
);
ALTER TABLE cwas OWNER to mesonet;
GRANT SELECT ON TABLE cwas TO nobody;
GRANT ALL ON TABLE cwas to ldm;
CREATE INDEX cwas_issue_idx on cwas(issue);
CREATE INDEX cwas_gist_idx on cwas USING GIST(geom);
