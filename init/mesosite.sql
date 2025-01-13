CREATE EXTENSION postgis;

-- bandaid
insert into spatial_ref_sys
    select 9311, 'EPSG', 9311, srtext, proj4text from spatial_ref_sys
    where srid = 2163;

-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
CREATE TABLE iem_schema_manager_version(
    version int,
    updated timestamptz);
INSERT into iem_schema_manager_version values (28, now());

--- ==== TABLES TO investigate deleting
--- counties
--- states

-- Storage of citations of the website
create table website_citations (
    publication_date date not null,
    title text not null,
    link text,
    iem_resource text
);
alter table website_citations owner to mesonet;
grant select,insert on website_citations to nobody;

--
create table tz_world(
    gid serial unique not null,
    tzid varchar(30),
    geom geometry(MultiPolygon,4326)
);
create index tz_world_geom_idx on tz_world using gist(geom);
alter table tz_world owner to mesonet;
grant select on tz_world to ldm, nobody;

--
create table website_telemetry(
    valid timestamptz not null default now(),
    timing real,
    status_code integer,
    client_addr inet,
    app text,
    request_uri text,
    vhost text
);
create index website_telemetry_valid_idx on
  website_telemetry(valid);
alter table website_telemetry owner to mesonet;
grant all on website_telemetry to nobody;

---
--- Store 404s for downstream analysis
CREATE TABLE weblog(
    valid timestamptz DEFAULT now(),
    client_addr inet,
    uri text,
    referer text,
    http_status int,
    x_forwarded_for text
);
ALTER TABLE weblog OWNER to mesonet;
GRANT ALL on weblog to nobody;

---
--- Store metadata used to drive the /timemachine/
---
CREATE TABLE archive_products(
    id SERIAL,
    name varchar,
    template varchar,
    sts timestamptz,
    interval int,
    groupname varchar,
    time_offset int,
    avail_lag int);
alter table archive_products owner to mesonet;
GRANT SELECT on archive_products to nobody;

create table iembot_mastodon_apps(
    id serial unique not null,
    server text unique not null,
    created timestamptz default now(),
    updated timestamptz default now(),
    client_id text not null,
    client_secret text not null
);
alter table iembot_mastodon_apps owner to mesonet;
grant all on iembot_mastodon_apps to nobody;

create table iembot_mastodon_oauth(
    id serial unique not null,
    appid int references iembot_mastodon_apps(id) not null,
    screen_name text not null,
    created timestamptz default now(),
    updated timestamptz default now(),
    password text,
    access_token text,
    iem_owned bool default 'f',
    disabled bool default 'f'
);
alter table iembot_mastodon_oauth owner to mesonet;
grant all on iembot_mastodon_oauth to nobody;

create table iembot_mastodon_subs(
    user_id int references iembot_mastodon_oauth(id),
    channel varchar(64)
);
alter table iembot_mastodon_subs owner to mesonet;
create unique index iembot_mastodon_subs_idx
    on iembot_mastodon_subs(user_id, channel);
grant all on iembot_mastodon_subs to nobody;

-- Mostly for slack at the moment
CREATE TABLE iembot_webhooks(
  channel varchar,
  url varchar);
ALTER TABLE iembot_webhooks OWNER to mesonet;
GRANT ALL on iembot_webhooks to nobody;


CREATE TABLE iembot_room_syndications (
    roomname character varying(64),    
    endpoint character varying(64),    
    convtype character(1));
alter table iembot_room_syndications owner to mesonet;

CREATE TABLE iembot_fb_access_tokens (
    fbpid bigint,
    access_token text
);
alter table iembot_fb_access_tokens owner to mesonet;

CREATE TABLE iembot_fb_subscriptions (
    fbpid bigint,
    channel character varying
);
alter table iembot_fb_subscriptions owner to mesonet;

---
--- Table to track iembot's use of social media
---
CREATE TABLE iembot_social_log(
  valid timestamp with time zone default now(),
  medium varchar(24),
  source varchar(256),
  resource_uri varchar(256),
  message text,
  message_link varchar(256),
  response text,
  response_code int
);
ALTER TABLE iembot_social_log OWNER to mesonet;
CREATE index iembot_social_log_valid_idx on iembot_social_log(valid);

---
--- networks we process!
---
CREATE TABLE networks(
  id varchar(12) unique,
  name varchar,
  tzname varchar(32),
  extent geometry(Polygon,4326),
  windrose_update timestamptz
);
CREATE UNIQUE index networks_id_idx on networks(id);
ALTER TABLE networks OWNER to mesonet;
GRANT ALL on networks to ldm;
GRANT SELECT on networks to nobody;

---
--- Missing table: news
---
CREATE TABLE news(
  id serial not null,
  entered timestamptz default now(),
  body text,
  author varchar(100),
  title varchar(100),
  url varchar,
  views int default 0,
  tags varchar(128)[]);
CREATE INDEX news_entered_idx on news(entered);
GRANT ALL on news to nobody;
GRANT ALL on news_id_seq to nobody;

---
--- IEMBOT Twitter Page subscriptions
---
CREATE TABLE iembot_twitter_oauth(
  user_id bigint NOT NULL UNIQUE,
  screen_name text,
  access_token text,
  access_token_secret text,
  created timestamptz DEFAULT now(),
  updated timestamptz DEFAULT now(),
  disabled bool default 'f',
  iem_owned bool default 'f',
  at_handle text,
  at_app_pass text
);
ALTER TABLE iembot_twitter_oauth OWNER to mesonet;
GRANT ALL on iembot_twitter_oauth to nobody;

CREATE TABLE iembot_twitter_subs(
  user_id bigint REFERENCES iembot_twitter_oauth(user_id),
  screen_name varchar(128),
  channel varchar(64)
);
ALTER TABLE iembot_twitter_subs OWNER to mesonet;
CREATE UNIQUE index iembot_twitter_subs_idx on 
 iembot_twitter_subs(screen_name, channel);
GRANT ALL on iembot_twitter_subs to nobody;

---
--- IEMBot channels
---
CREATE TABLE iembot_channels(
  id varchar not null UNIQUE,
  name varchar,
  channel_key character varying DEFAULT substr(md5((random())::text), 0, 12)
);
alter table iembot_channels owner to mesonet;
GRANT all on iembot_channels to nobody;

---
--- IEMBot rooms
---
CREATE TABLE iembot_room_subscriptions (
    roomname character varying(64),
    channel character varying(24)
);
ALTER TABLE iembot_room_subscriptions OWNER to mesonet;
CREATE UNIQUE index iembot_room_subscriptions_idx on
  iembot_room_subscriptions(roomname, channel);
GRANT all on iembot_room_subscriptions to nobody;
---
--- IEMBot room subscriptions
---
CREATE TABLE iembot_rooms (
    roomname varchar(64),
    fbpage varchar,
    twitter varchar
);
ALTER TABLE iembot_rooms OWNER to mesonet;
GRANT all on iembot_rooms to nobody;

---
--- Racoon Work Tasks
---
CREATE TABLE racoon_jobs(
  jobid varchar(32) default md5(random()::text),
  wfo varchar(3),
  sts timestamp with time zone,
  ets timestamp with time zone,
  radar varchar(3),
  processed boolean default false,
  nexrad_product char(3),
  wtype varchar(32)
);
GRANT all on racoon_jobs to nobody;

---
--- IEM Apps Database!
---
CREATE TABLE iemapps(
  appid serial unique,
  name varchar(256) unique not null,
  description text,
  url varchar(256) not null
);
GRANT ALL on iemapps to nobody;

CREATE TABLE iemapps_tags(
    appid int references iemapps(appid),
    tag varchar(24) not null
);
CREATE UNIQUE INDEX iemapps_tags_idx on iemapps_tags(appid,tag);
GRANT ALL on iemapps_tags to nobody;


---
--- webcam logs
---
CREATE TABLE camera_log(
    cam varchar(11),
    valid timestamp with time zone,
    drct smallint
) PARTITION by range(valid);
ALTER TABLE camera_log OWNER to mesonet;
GRANT ALL on camera_log to ldm;
GRANT SELECT on camera_log to nobody;


do
$do$
declare
     year int;
     mytable varchar;
begin
    for year in 2003..2030
    loop
        mytable := format($f$camera_log_%s$f$, year);
        execute format($f$
            create table %s partition of camera_log
            for values from ('%s-01-01 00:00+00') to ('%s-01-01 00:00+00')
            $f$, mytable, year, year + 1);
        execute format($f$
            ALTER TABLE %s OWNER to mesonet
        $f$, mytable);
        execute format($f$
            GRANT ALL on %s to ldm
        $f$, mytable);
        execute format($f$
            GRANT SELECT on %s to nobody
        $f$, mytable);
        -- Indices
        execute format($f$
            CREATE INDEX %s_valid_idx on %s(valid)
        $f$, mytable, mytable);
    end loop;
end;
$do$;


---
--- webcam currents
---
CREATE TABLE camera_current(
    cam varchar(11) UNIQUE,
    valid timestamp with time zone,
    drct smallint);
GRANT SELECT on camera_current to nobody;
GRANT ALL on camera_current to mesonet,ldm;

---
--- Webcam scheduling
---
CREATE TABLE webcam_scheduler(
    cid varchar(10),
    begints timestamp with time zone,
    endts timestamp with time zone,
    is_daily boolean,
    filename varchar,
    movie_seconds smallint);
CREATE UNIQUE index webcam_scheduler_filename_idx on
    webcam_scheduler(filename);
GRANT ALL on webcam_scheduler to nobody;

---
--- Store IEM settings
---
CREATE TABLE properties(
  propname varchar,
  propvalue varchar
);
ALTER TABLE properties OWNER to mesonet;
-- TODO: fix this permissions
GRANT ALL on properties to nobody,ldm;
CREATE UNIQUE index properties_idx on properties(propname, propvalue);

--- Alias for pyWWA nwschat support
create view nwschat_properties as select * from properties;

---
--- Webcam configurations
---
CREATE TABLE webcams(
    id varchar(11),
    ip inet,
    name varchar,
    pan0 smallint,
    online boolean,
    port int,
    network varchar(10),
    iservice varchar,
    iserviceurl varchar,
    sts timestamp with time zone,
    ets timestamp with time zone,
    county varchar,
    hosted varchar,
    hostedurl varchar,
    sponsor varchar,
    sponsorurl varchar,
    removed boolean,
    state varchar(2),
    moviebase varchar,
    scrape_url varchar,
    is_vapix boolean,
    fullres varchar(9) DEFAULT '640x480' NOT NULL,
  fqdn varchar
    );
SELECT AddGeometryColumn('webcams', 'geom', 4326, 'POINT', 2);
GRANT all on webcams to mesonet,ldm;
GRANT select on webcams to nobody;

CREATE TABLE stations(
    id varchar(64),
    synop int,
    name varchar(64),
    state char(2),
    country char(2),
    elevation real,
    network varchar(20),
    online boolean NOT NULL default 't',
    params varchar(300),
    county varchar(50),
    plot_name varchar(64),
    climate_site varchar(6),
    remote_id int,
    nwn_id int,
    spri smallint,
    wfo varchar(3),
    archive_begin date,
    archive_end date,
    modified timestamptz default now(),
    tzname varchar(32),
    iemid SERIAL UNIQUE NOT NULL,
    metasite boolean,
    sigstage_low real,
    sigstage_action real,
    sigstage_bankfull real,
    sigstage_flood real,
    sigstage_moderate real,
    sigstage_major real,
    sigstage_record real,
    ugc_county char(6),
    ugc_zone char(6),
    ncdc81 varchar(11),
    ncei91 varchar(11),
    temp24_hour smallint,
    precip24_hour smallint,
    wigos varchar(64)
);
ALTER TABLE stations OWNER to mesonet;
-- no commas in name please
alter table stations add constraint stations_nocommas check(strpos(name, ',') = 0);
CREATE UNIQUE index stations_idx on stations(id, network);
create UNIQUE index stations_iemid_idx on stations(iemid);
SELECT AddGeometryColumn('stations', 'geom', 4326, 'POINT', 2);
GRANT SELECT on stations to nobody;
grant all on stations_iemid_seq to nobody;
GRANT ALL on stations to mesonet,ldm;
GRANT ALL on stations_iemid_seq to mesonet,ldm;

CREATE OR REPLACE FUNCTION update_modified_column()
    RETURNS TRIGGER AS $$
    BEGIN
       NEW.modified = now(); 
       RETURN NEW;
    END;
    $$ language 'plpgsql';
    
CREATE TRIGGER update_stations_modtime BEFORE UPDATE
        ON stations FOR EACH ROW EXECUTE PROCEDURE 
        update_modified_column();

-- Storage of how stations are threaded together
CREATE TABLE station_threading(
    iemid int REFERENCES stations(iemid),
    source_iemid int REFERENCES stations(iemid),
    begin_date date NOT NULL,
    end_date date
);
ALTER TABLE station_threading OWNER to mesonet;
GRANT ALL on station_threading to ldm;
GRANT SELECT on station_threading to nobody;

-- Storage of station attributes
CREATE TABLE station_attributes(
    iemid int REFERENCES stations(iemid),
    attr varchar(128) NOT NULL,
  value varchar NOT NULL);
GRANT ALL on station_attributes to mesonet,ldm;
CREATE UNIQUE index station_attributes_idx on station_attributes(iemid, attr);
create index station_attributes_iemid_idx on station_attributes(iemid);
GRANT SELECT on station_attributes to nobody;

---
create table iemmaps(
  id SERIAL,
  title varchar(256),
  entered timestamp with time zone DEFAULT now(),
  description text,
  keywords varchar(256),
  views int,
  ref varchar(32),
  category varchar(24)
);
GRANT all on iemmaps to nobody;
GRANT all on iemmaps_id_seq to nobody;

CREATE table feature(
  valid timestamp with time zone DEFAULT now(),
  title varchar(256),
  story text,
  caption varchar(256),
  good smallint default 0,
  bad smallint default 0,
  abstain smallint default 0,
  voting boolean default true,
  tags varchar(1024),
  fbid bigint,
  appurl varchar(1024),
  javascripturl varchar(1024),
  views int default 0,
  mediasuffix varchar(8) DEFAULT 'png',
  media_height int,
  media_width int
);
CREATE unique index feature_title_check_idx on feature(title);
CREATE index feature_valid_idx on feature(valid);
GRANT all on feature to nobody;
GRANT all on feature to mesonet,ldm;

CREATE table shef_physical_codes(
  code char(2),
  name varchar(128),
  units varchar(64));
GRANT select on shef_physical_codes to nobody;

CREATE table shef_duration_codes(
  code char(1),
  name varchar(128));
GRANT select on shef_duration_codes to nobody;

CREATE table shef_extremum_codes(
  code char(1),
  name varchar(128));
GRANT select on shef_extremum_codes to nobody;

-- Storage of metadata
CREATE TABLE iemrasters(
  id SERIAL UNIQUE,
  name varchar,
  description text,
  archive_start timestamptz,
  archive_end   timestamptz,
  units varchar(12),
  interval int,
  filename_template varchar,
  cf_long_name varchar
);
GRANT SELECT on iemrasters to nobody;

-- Storage of color tables and values
CREATE TABLE iemrasters_lookup(
  iemraster_id int REFERENCES iemrasters(id),
  coloridx smallint,
  value real,
  r smallint,
  g smallint,
  b smallint
);
GRANT SELECT on iemrasters_lookup to nobody;

-- Storage of Autoplot timings and such
CREATE TABLE autoplot_timing(
    appid smallint NOT NULL,
    valid timestamptz NOT NULL,
    timing real NOT NULL,
    uri varchar,
    hostname varchar(24) NOT NULL);
GRANT SELECT on autoplot_timing to nobody;
CREATE INDEX autoplot_timing_idx on autoplot_timing(appid);

-- Storage of talltowers analog request queue
CREATE TABLE talltowers_analog_queue
    (stations varchar(32),
    sts timestamptz,
    ets timestamptz,
    fmt varchar(32),
    email varchar(128),
    aff varchar(256),
    filled boolean DEFAULT 'f',
    valid timestamptz DEFAULT now());
GRANT ALL on talltowers_analog_queue to nobody, mesonet;
