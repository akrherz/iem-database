-- Storage of Fire Weather WFO
-- see akrherz/pyIEM#374
ALTER TABLE ugcs ADD source varchar(2);

---
--- Helper function to find a GID for a given UGC code and date!
---
CREATE OR REPLACE FUNCTION get_gid(varchar, timestamptz)
RETURNS int
LANGUAGE sql
AS $_$
  select gid from ugcs WHERE ugc = $1 and begin_ts <= $2 and
  (end_ts is null or end_ts > $2) and source != 'fz' LIMIT 1
$_$;

-- Explicit source version
CREATE OR REPLACE FUNCTION get_gid(varchar, timestamptz, varchar)
RETURNS int
LANGUAGE sql
AS $_$
  select gid from ugcs WHERE ugc = $1 and begin_ts <= $2 and
  (end_ts is null or end_ts > $2) and source = $3 LIMIT 1
$_$;
