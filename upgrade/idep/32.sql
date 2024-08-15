-- Log clifile requests
create table clifile_requests(
  valid timestamptz default now(),
  client_addr text,
  geom geometry(Point, 4326),
  provided_file text,
  distance_degrees float
);
alter table clifile_requests owner to mesonet;
grant insert on clifile_requests to nobody;
