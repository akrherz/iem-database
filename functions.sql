--- TODO: These are db specific and need to be moved
--- CREATE FUNCTION getl(text, date) RETURNS integer
---    LANGUAGE sql
---    AS $_$SELECT  low from alldata WHERE station = $1 and day = $2$_$;
---
--- CREATE FUNCTION gett(text, date) RETURNS integer
---    LANGUAGE sql
---    AS $_$SELECT high from alldata WHERE station = $1 and day = $2$_$;

CREATE OR REPLACE FUNCTION doy_after_july1(date date)
RETURNS integer
LANGUAGE plpgsql
AS $$
BEGIN
  DECLARE
    year integer;
  BEGIN
    year := case when date_part('month', date) < 7 then extract(year from date) - 1 else extract(year from date) end;

  RETURN
    (date - (year || '-07-01')::date) + 1;
  END;
END;
$$;


CREATE AGGREGATE sumtxt(text) (
    SFUNC = textcat,
    STYPE = text,
    INITCOND = ''
);


CREATE FUNCTION sdd86(real, real) RETURNS numeric
    LANGUAGE sql
    AS $_$select ( (CASE WHEN $1 > 86 THEN $1 - 86 ELSE 0 END) )::numeric$_$;
    
CREATE FUNCTION gdd48(real, real) RETURNS numeric
    LANGUAGE sql
    AS $_$select (( (CASE WHEN $1 > 48 THEN (case when $1 > 86 THEN 86 ELSE $1 END ) - 48 ELSE 0 END) + (CASE WHEN $2 > 48 THEN $2 - 48 ELSE 0 END) ) / 2.0)::numeric$_$;

CREATE FUNCTION gdd50(real, real) RETURNS numeric
    LANGUAGE sql
    AS $_$select (( (CASE WHEN $1 > 50 THEN (case when $1 > 86 THEN 86 ELSE $1 END ) - 50 ELSE 0 END) + (CASE WHEN $2 > 50 THEN $2 - 50 ELSE 0 END) ) / 2.0)::numeric$_$;

CREATE FUNCTION gdd52(real, real) RETURNS numeric
    LANGUAGE sql
    AS $_$
  select ((
   (CASE WHEN $1 > 52 THEN
     (case when $1 > 86 THEN 86 ELSE $1 END ) - 52
    ELSE 0 END)
  + (CASE WHEN $2 > 52 and $2 < 99 THEN $2 - 52 ELSE 0 END) ) / 2.0)::numeric
$_$;

--
-- base, max, high, low
 CREATE OR REPLACE FUNCTION gddxx(real, real, real, real) RETURNS numeric
    LANGUAGE sql
    AS $_$
    select case when $3 is null or $4 is null then null else (( (CASE WHEN $3 > $1 THEN (case when $3 > $2 THEN $2 ELSE $3 END ) - $1 ELSE 0 END) + 
		(CASE WHEN $4 > $1 THEN $4 - $1 ELSE 0 END) ) / 2.0)::numeric end
    $_$;

--
-- Growing Degree Days (only base, no floor nor ceiling)
-- (base, high, low)
CREATE FUNCTION gdd_onlybase(real, real, real) RETURNS numeric LANGUAGE sql
 AS $_$
  SELECT greatest(0, ($2 + $3) / 2. - $1)::numeric
 $_$;


---
--- Cooling Degree Days
--- (high, low, base)
 CREATE OR REPLACE FUNCTION cdd(real, real, real) RETURNS numeric
 	LANGUAGE sql
 	AS $_$select (case when (( $1 + $2 )/2.) > $3 then (( $1 + $2 )/2. - $3) else 0 end)::numeric$_$;

--- CDDs base 65
 CREATE OR REPLACE FUNCTION cdd65(real, real) RETURNS numeric
 	LANGUAGE sql
 	AS $_$select (case when (( 65 + $1 )/2.) > $2 then (( 65 + $1 )/2. - $2) else 0 end)::numeric$_$;


--- Convert celsuis to fahrenheit
CREATE FUNCTION c2f(real) RETURNS numeric
	LANGUAGE sql
	AS $_$ select ($1 * 1.8 + 32.0)::numeric $_$; 

---
--- Convert Fahrenheit to Celsuis
---
CREATE OR REPLACE FUNCTION f2c(real) RETURNS double precision
	LANGUAGE sql AS $_$
		SELECT ($1 - 32.0) / 1.8
	$_$;
COMMENT on FUNCTION f2c(real) IS 'Convert F to C f2c(temperature)';

---
--- Compute wind chill
---
CREATE OR REPLACE FUNCTION wcht(real, real) RETURNS double precision
	LANGUAGE sql AS $_$
		SELECT case when ($1 is null or $2 is null) THEN null ELSE
			(case when $2 < 1 or $1 > 32 THEN $1 ELSE
				35.74 + .6215 * $1 - 35.75 * power($2 * 1.15,0.16) 
						+ .4275 * $1 * power($2 * 1.15,0.16)
			END)
		END 
	$_$;
COMMENT on FUNCTION wcht(real, real) IS 'Wind Chill wcht(tmpf, sknt)';

CREATE OR REPLACE FUNCTION hdd65(real, real) RETURNS numeric
 	LANGUAGE sql
 	AS $_$select (case when (65 - (( $1 + $2 )/2.)) > 0 then (65. - ( $1 + $2 )/2.) else 0 end)::numeric$_$;

CREATE FUNCTION hdd(real, real, real) RETURNS numeric
    LANGUAGE sql
    AS $_$select (case when ($3 - (( $1 + $2 )/2.)) > 0 then ($3 - ( $1 + $2 )/2.) else 0 end)::numeric$_$;
ALTER FUNCTION public.hdd(real, real, real) OWNER TO mesonet;


---
--- Unsure of current usage of this, legacy asos database stuff perhaps
---
CREATE FUNCTION wind_chill(real, real) RETURNS double precision
    LANGUAGE sql
    AS $_$select 35.74 + .6215 * $1 - 35.75 * power($2 * 1.15,0.16) + .4275 * $1 * power($2 * 1.15,0.16)$_$;
 	
--
-- Used for throttling based on database server load
-- https://aaronparecki.com/2015/02/19/8
create extension file_fdw;
CREATE SERVER fileserver FOREIGN DATA WRAPPER file_fdw;
CREATE FOREIGN TABLE system_loadavg 
(one text, five text, fifteen text, scheduled text, pid text) 
SERVER fileserver 
OPTIONS (filename '/proc/loadavg', format 'text', delimiter ' ');
ALTER TABLE system_loadavg OWNER TO mesonet;
GRANT SELECT ON system_loadavg TO nobody, ldm;
