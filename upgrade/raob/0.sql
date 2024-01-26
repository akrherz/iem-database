-- Some metadata
alter table raob_flights add locked boolean default 'f';
alter table raob_flights add ingested_at timestamptz default now();
alter table raob_flights add computed_at timestamptz default now();
