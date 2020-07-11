---
--- Store Properties used by website and scripts
CREATE TABLE properties(
  key varchar UNIQUE NOT NULL,
  value varchar
);
GRANT SELECT on properties to nobody,apache;