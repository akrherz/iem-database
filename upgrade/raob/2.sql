-- Run in a transaction. The schema manager does this automatically.
-- Rebuilding the profile table holds exclusive locks for the migration.
LOCK TABLE raob_flights, raob_profile IN ACCESS EXCLUSIVE MODE;

CREATE UNIQUE INDEX raob_flights_fid_valid_idx ON raob_flights (fid, valid);

ALTER TABLE raob_profile RENAME TO raob_profile_v1;
DO $do$
DECLARE
    child record;
BEGIN
    FOR child IN
        SELECT c.oid, n.nspname, c.relname
        FROM pg_inherits i
        JOIN pg_class c ON c.oid = i.inhrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE i.inhparent = 'raob_profile_v1'::regclass
    LOOP
        EXECUTE format('ALTER TABLE %I.%I RENAME TO %I',
            child.nspname, child.relname, 'raob_profile_v1_' || child.oid);
    END LOOP;
END;
$do$;

CREATE TABLE raob_profile (
    fid int NOT NULL,
    valid timestamptz NOT NULL,
    ts timestamptz,
    levelcode smallint,
    pressure real,
    height real,
    tmpc real,
    dwpc real,
    drct real,
    smps real,
    bearing real,
    range_miles real,
    FOREIGN KEY (fid, valid) REFERENCES raob_flights (fid, valid)
    ON DELETE CASCADE ON UPDATE CASCADE
) PARTITION BY RANGE (valid);
ALTER TABLE raob_profile OWNER TO mesonet;
CREATE INDEX raob_profile_v2_fid_idx ON raob_profile (fid);
GRANT SELECT ON raob_profile TO nobody;

DO $do$
DECLARE
    y int;
BEGIN
    FOR y IN 1946..2030 LOOP
        EXECUTE format($f$
            CREATE TABLE raob_profile_%s PARTITION OF raob_profile
                FOR VALUES FROM (%L) TO (%L);
            ALTER TABLE raob_profile_%s OWNER TO mesonet;
            GRANT SELECT ON raob_profile_%s TO nobody;
        $f$, y, format('%s-01-01 00:00:00+00', y),
            format('%s-01-01 00:00:00+00', y + 1), y, y);
    END LOOP;
END;
$do$;

-- A left join makes missing flights or null valid values fail the migration
-- rather than silently discarding their profile rows.
INSERT INTO raob_profile
(
    fid, valid, ts, levelcode, pressure, height, tmpc, dwpc, drct, smps,
    bearing, range_miles
)
SELECT
    p.fid, f.valid, p.ts, p.levelcode, p.pressure, p.height, p.tmpc, p.dwpc,
    p.drct, p.smps, p.bearing, p.range_miles
FROM raob_profile_v1 p
LEFT JOIN raob_flights f ON f.fid = p.fid;

-- Don't delete the old database until we ensure things are OK
