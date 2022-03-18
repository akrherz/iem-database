-- Storage of AIRMETs / Graphical AIRMET

CREATE TABLE airmets(
    gml_id varchar(32),
    label varchar(4) NOT NULL,
    valid_from timestamptz,
    valid_to timestamptz,
    valid_at timestamptz,
    issuetime timestamptz,
    product_id text,
    hazard_type text,
    weather_conditions text[],
    status text,
    geom geometry(Polygon, 4326)
);
CREATE INDEX airmets_idx on airmets(label, valid_at);
CREATE INDEX airmets_geom_idx on airmets USING gist(geom);
CREATE INDEX airmets_product_id_idx on airmets(product_id);
ALTER TABLE airmets OWNER to mesonet;
GRANT SELECT ON TABLE airmets TO nobody;
GRANT ALL on TABLE airmets to ldm;

-- Storage of Freezing Level found in AIRMETs

CREATE TABLE airmet_freezing_levels(
    gml_id varchar(32),
    valid_at timestamptz,
    product_id text,
    level int,
    geom geometry(MultiLineString, 4326)
);
CREATE INDEX airmet_freezing_levels_idx on airmet_freezing_levels(valid_at);
ALTER TABLE airmet_freezing_levels OWNER to mesonet;
GRANT SELECT ON TABLE airmet_freezing_levels TO nobody;
GRANT ALL on TABLE airmet_freezing_levels to ldm;
