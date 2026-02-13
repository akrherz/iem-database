-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version (
    version int,  -- noqa
    updated timestamptz
);
INSERT INTO iem_schema_manager_version VALUES (-1, now());

CREATE TABLE real_flow (
    gauge_id int,
    valid timestamptz, -- noqa
    cfs int
);
CREATE INDEX real_flow_idx ON real_flow (gauge_id, valid);

CREATE TABLE storms (
    id serial UNIQUE,
    name varchar,  -- noqa
    created timestamptz,
    edited timestamptz,
    notes text
);

CREATE TABLE events (
    storm_id int REFERENCES storms (id),
    basin_id smallint,
    precip real,
    onset timestamptz,
    duration real
);
CREATE UNIQUE INDEX events_idx ON events (storm_id, basin_id);

CREATE TABLE scenarios (
    id serial UNIQUE,
    name varchar,  -- noqa
    created timestamptz,
    edited timestamptz,
    notes text
);

CREATE TABLE scenario_events (
    scenario_id int REFERENCES scenarios (id),
    basin_id smallint,
    precip real,
    onset timestamptz,
    duration real
);
