--
-- Table storage for website telemetry data
--
create table website_telemetry(
    valid timestamptz not null default now(),
    timing real,
    status_code integer,
    client_addr inet,
    app text,
    request_uri text
);
create index website_telemetry_valid_idx on
  website_telemetry(valid);
alter table website_telemetry owner to mesonet;
grant all on website_telemetry to nobody;
