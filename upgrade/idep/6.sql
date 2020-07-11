--- Add delivery output to results table
ALTER TABLE results ADD delivery real;

--- Fix database perms
GRANT SELECT on results to nobody,apache;