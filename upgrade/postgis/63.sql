-- Storage of UGC for LSRs
ALTER TABLE lsrs add gid int references ugcs(gid);

--
-- Version for LSR table to get by a name
--   end_ts is null to get only current entries
--   order by to prioritize counties before zones, hopefully
CREATE OR REPLACE FUNCTION get_gid_by_name_state(varchar, char(2))
RETURNS int
LANGUAGE sql
AS $_$
    select gid from ugcs where state = $2 and upper($1) = upper(name)
    and end_ts is null
    ORDER by ugc ASC LIMIT 1
$_$;
