-- Storage of harvest information
CREATE TABLE harvest(
  valid date,
  huc12 char(12),
  fpath smallint,
  ofe smallint,
  scenario smallint REFERENCES scenarios(id),
  crop varchar(32),
  yield_kgm2 real
);
CREATE INDEX harvest_huc12_idx on harvest(huc12);
CREATE INDEX harvest_valid_idx on harvest(valid);
GRANT ALL on harvest to ldm,mesonet;
GRANT SELECT on harvest to nobody,apache;
