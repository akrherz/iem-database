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
alter table website_telemetry owner to mesonet;
grant all on website_telemetry to nobody;
