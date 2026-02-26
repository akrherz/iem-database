create or replace function abs(interval)
returns interval
as $$
select greatest(-$1,$1);
$$ language sql immutable;

create or replace function doy_after_july1(date date)
returns integer
language plpgsql
as $$
BEGIN
  DECLARE
    year integer;
  BEGIN
    year := case when date_part('month', date) < 7 then
    extract(year from date) - 1 else extract(year from date) end;

  RETURN
    (date - (year || '-07-01')::date) + 1;
  END;
END;
$$;


create aggregate sumtxt (text)(
    sfunc = textcat,
    stype = text,
    initcond = ''
);


create function sdd86(real, real) returns numeric
language sql
as $_$select ( (CASE WHEN $1 > 86 THEN $1 - 86 ELSE 0 END) )::numeric$_$;

create function gdd48(real, real) returns numeric
language sql
as $_$select (( (CASE WHEN $1 > 48 THEN 
(case when $1 > 86 THEN 86 ELSE $1 END ) - 48 ELSE 0 END) +
(CASE WHEN $2 > 48 THEN least($2, 86) - 48 ELSE 0 END) ) / 2.0)::numeric$_$;

create function gdd50(real, real) returns numeric
language sql
as $_$select (( (CASE WHEN $1 > 50 THEN
(case when $1 > 86 THEN 86 ELSE $1 END ) - 50 ELSE 0 END) +
(CASE WHEN $2 > 50 THEN least($2, 86) - 50 ELSE 0 END) ) / 2.0)::numeric$_$;

create function gdd52(real, real) returns numeric
language sql
as $_$
  select ((
   (CASE WHEN $1 > 52 THEN
     (case when $1 > 86 THEN 86 ELSE $1 END ) - 52
    ELSE 0 END)
  + (CASE WHEN $2 > 52 and $2 < 99 THEN least($2, 86) - 52 ELSE 0 END) ) / 2.0)::numeric
$_$;

--
-- base, max, high, low
create or replace function gddxx(real, real, real, real) returns numeric
language sql
as $_$
    select case when $3 is null or $4 is null then null else (( (CASE WHEN $3 > $1 THEN (case when $3 > $2 THEN $2 ELSE $3 END ) - $1 ELSE 0 END) + 
        (CASE WHEN $4 > $1 THEN least($4, $2) - $1 ELSE 0 END) ) / 2.0)::numeric end
    $_$;

--
-- Growing Degree Days (only base, no floor nor ceiling)
-- (base, high, low)
create function gdd_onlybase(real, real, real) returns numeric language sql
as $_$
  SELECT greatest(0, ($2 + $3) / 2. - $1)::numeric
 $_$;


---
--- Cooling Degree Days
--- (high, low, base)
create or replace function cdd(real, real, real) returns numeric
language sql
as $_$select (case when (( $1 + $2 )/2.) > $3 then
(( $1 + $2 )/2. - $3) else 0 end)::numeric$_$;

--- CDDs base 65
create or replace function cdd65(real, real) returns numeric
language sql
as $_$select (case when (( 65 + $1 )/2.) > $2 then
(( 65 + $1 )/2. - $2) else 0 end)::numeric$_$;


--- Convert celsuis to fahrenheit
create function c2f(real) returns numeric
language sql
as $_$ select ($1 * 1.8 + 32.0)::numeric $_$;

---
--- Convert Fahrenheit to Celsuis
---
create or replace function f2c(real) returns double precision
language sql as $_$
        SELECT ($1 - 32.0) / 1.8
    $_$;
comment on function f2c(real) is 'Convert F to C f2c(temperature)';

---
--- Compute wind chill
---
create or replace function wcht(real, real) returns double precision
language sql as $_$
        SELECT case when ($1 is null or $2 is null) THEN null ELSE
            (case when $2 < 1 or $1 > 32 THEN $1 ELSE
                35.74 + .6215 * $1 - 35.75 * power($2 * 1.15,0.16) 
                        + .4275 * $1 * power($2 * 1.15,0.16)
            END)
        END 
    $_$;
comment on function wcht(real, real) is 'Wind Chill wcht(tmpf, sknt)';

create or replace function hdd65(real, real) returns numeric
language sql
as $_$select (case when (65 - (( $1 + $2 )/2.)) > 0 then
(65. - ( $1 + $2 )/2.) else 0 end)::numeric$_$;

create function hdd(real, real, real) returns numeric
language sql
as $_$select (case when ($3 - (( $1 + $2 )/2.)) > 0 then
($3 - ( $1 + $2 )/2.) else 0 end)::numeric$_$;
alter function public.hdd(real, real, real) owner to mesonet;


---
--- Unsure of current usage of this, legacy asos database stuff perhaps
---
create function wind_chill(real, real) returns double precision
language sql
as $_$select 35.74 + .6215 * $1 - 35.75 * power($2 * 1.15,0.16) + .4275 *
$1 * power($2 * 1.15,0.16)$_$;

--
-- Used for throttling based on database server load
-- https://aaronparecki.com/2015/02/19/8
create extension file_fdw;
create server fileserver foreign data wrapper file_fdw;
create foreign table system_loadavg
(one text, five text, fifteen text, scheduled text, pid text)
server fileserver
options (filename '/proc/loadavg', format 'text', delimiter ' ');
alter table system_loadavg owner to mesonet;
grant select on system_loadavg to nobody, ldm;
