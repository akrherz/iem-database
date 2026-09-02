-- Storage of GEFS Forecast
CREATE TABLE iemre_gefs (
    gid int REFERENCES iemre_grid (gid),
    ens_member smallint,
    model_valid timestamptz,
    valid date,
    high_tmpk real,
    low_tmpk real,
    avg_rh real
);
ALTER TABLE iemre_gefs OWNER TO mesonet;
GRANT SELECT ON iemre_gefs TO nobody;
CREATE INDEX ON iemre_gefs (gid);
CREATE INDEX ON iemre_gefs (model_valid);
