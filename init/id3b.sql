-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
  version int,
  updated timestamptz);
ALTER TABLE iem_schema_manager_version OWNER to mesonet;
INSERT into iem_schema_manager_version values (-1, now());

-- Our database schema
CREATE TABLE ldm_product_log(
  entered_at timestamptz DEFAULT now(),
  md5sum char(32),
  size int,
  valid_at timestamptz,
  ldm_feedtype int,
  seqnum int,
  product_id varchar,
  product_origin varchar,
  wmo_ttaaii char(6),
  wmo_source char(4),
  wmo_valid_at timestamptz,
  wmo_bbb char(3),
  awips_id varchar(6)
);
ALTER TABLE ldm_product_log OWNER TO mesonet;

CREATE INDEX ldm_product_log_wmo_source_idx on ldm_product_log(wmo_source);
CREATE INDEX ldm_product_log_wmo_ttaaii_idx on ldm_product_log(wmo_ttaaii);
CREATE INDEX ldm_product_log_awips_id_idx on ldm_product_log(awips_id);
CREATE INDEX ON ldm_product_log(valid_at);

GRANT ALL on ldm_product_log to ldm;
GRANT SELECT on ldm_product_log to nobody;
