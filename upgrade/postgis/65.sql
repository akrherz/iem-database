-- Bootstraped via scripts in akrherz/DEV repo, pireps folder
CREATE TABLE airspaces(
    ident varchar(8),
    type_code varchar(8) not null,
    name text,
    geom geography(multipolygon)
);
ALTER TABLE airspaces OWNER to mesonet;
GRANT ALL on airspaces to ldm;
GRANT SELECT on airspaces to nobody;
