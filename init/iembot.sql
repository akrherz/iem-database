-- Boilerplate IEM schema_manager_version, the version gets incremented each
-- time we make an upgrade script
create table iem_schema_manager_version (
    version int,  -- noqa
    updated timestamptz
);
insert into iem_schema_manager_version values (1, now());

-- A global account identifier for IEMBot, referenced by the various tables
-- and subscriptions
create table iembot_accounts (
    id serial primary key,
    service text not null,
    created_at timestamptz default now()
);
alter table iembot_accounts owner to mesonet;
grant all on iembot_accounts_id_seq to nobody;
grant all on iembot_accounts to nobody;

-- Helper function to make inserts easier
create or replace function create_iembot_account(svc text)
returns bigint as $$
declare
    acct_id bigint;
begin
    insert into iembot_accounts(service) values (svc) returning id into acct_id;
    return acct_id;
end;
$$ language plpgsql;

-- Channels
--   - The most basic level of information organization
create table iembot_channels (
    id serial primary key,
    channel_name varchar(64) unique not null,
    description text,
    created_at timestamptz default now()
);
alter table iembot_channels owner to mesonet;
grant all on iembot_channels_id_seq to nobody;
grant all on iembot_channels to nobody;

-- Helper function to make inserts easier
create or replace function get_or_create_iembot_channel_id(chname varchar)
returns int as $$
declare
    chan_id int;
begin
    select id into chan_id from iembot_channels where channel_name = chname;
    if chan_id is not null then
        return chan_id;
    end if;
    insert into iembot_channels(channel_name, "description")
    values (chname, chname) returning id into chan_id;
    return chan_id;
end;
$$ language plpgsql;

-- Channel Groups
--   - Next level up of organization of channels into a group
--   - Nomenclature that these start with an underscore
create table iembot_channel_groups (
    id serial primary key,
    group_name varchar(64) unique not null,
    description text,
    created_at timestamptz default now(),
    check (
        strpos(group_name, '_') = 1
    )
);
alter table iembot_channel_groups owner to mesonet;
grant all on iembot_channel_groups_id_seq to nobody;
grant all on iembot_channel_groups to nobody;

-- Junction table for channels to channel groups
create table iembot_channel_group_membership (
    id serial primary key,
    channel_id int references iembot_channels (id),
    group_id int references iembot_channel_groups (id),
    created_at timestamptz default now()
);
create unique index on iembot_channel_group_membership (channel_id, group_id);
alter table iembot_channel_group_membership owner to mesonet;
grant all on iembot_channel_group_membership_id_seq to nobody;
grant all on iembot_channel_group_membership to nobody;

-- Subscriptions to either channels or channel groups
create table iembot_subscriptions (
    id serial primary key,
    iembot_account_id bigint not null references iembot_accounts (id),
    channel_id int references iembot_channels (id),
    group_id int references iembot_channel_groups (id),
    created_at timestamptz default now(),
    check (
        (channel_id is not null and group_id is null)
        or
        (channel_id is null and group_id is not null)
    )
);
create unique index on iembot_subscriptions (
    iembot_account_id, channel_id, group_id
);
alter table iembot_subscriptions owner to mesonet;
grant all on iembot_subscriptions_id_seq to nobody;
grant all on iembot_subscriptions to nobody;

-- ________________________________________________________________________
-- SLACK

-- Storage of IEMBot Slack info
create table iembot_slack_teams (
    id serial primary key,
    team_id text unique not null,
    team_name text,
    access_token text not null,
    bot_user_id text,
    installed_at timestamptz default now()
);
alter table iembot_slack_teams owner to mesonet;
grant all on iembot_slack_teams_id_seq to nobody;
grant all on iembot_slack_teams to nobody;

-- Storage of IEMBot Slack Channels, sadly redundant name
create table iembot_slack_team_channels (
    id serial primary key,
    iembot_account_id bigint not null references iembot_accounts (id),
    team_id text not null references iembot_slack_teams (team_id),
    channel_id text not null,
    created_at timestamptz default now()
);
create unique index on iembot_slack_team_channels (team_id, channel_id);
alter table iembot_slack_team_channels owner to mesonet;
grant all on iembot_slack_team_channels_id_seq to nobody;
grant all on iembot_slack_team_channels to nobody;

-- _________________________________________________________________________
-- MASTODON

create table iembot_mastodon_apps (
    id serial unique not null,
    server text unique not null,  -- noqa
    created timestamptz default now(),
    updated timestamptz default now(),
    client_id text not null,
    client_secret text not null
);
alter table iembot_mastodon_apps owner to mesonet;
grant all on iembot_mastodon_apps_id_seq to nobody;
grant all on iembot_mastodon_apps to nobody;

-- This is where the accounts lie / xref to subscriptions
create table iembot_mastodon_oauth (
    id serial unique not null,
    iembot_account_id bigint not null references iembot_accounts (id),
    appid int references iembot_mastodon_apps (id) not null,
    screen_name text not null,
    created timestamptz default now(),
    updated timestamptz default now(),
    password text,  --noqa
    access_token text,
    iem_owned bool default 'f',
    disabled bool default 'f'
);
alter table iembot_mastodon_oauth owner to mesonet;
grant all on iembot_mastodon_oauth_id_seq to nobody;
grant all on iembot_mastodon_oauth to nobody;

---
--- Table to track iembot's use of social media
---
create table iembot_social_log (
    iembot_account_id bigint not null references iembot_accounts (id),
    valid timestamp with time zone default now(),  --noqa
    medium varchar(24),
    source varchar(256),
    resource_uri varchar(256),
    message text,
    message_link varchar(256),
    response text,
    response_code int
);
alter table iembot_social_log owner to mesonet;
create index iembot_social_log_valid_idx on iembot_social_log (valid);

-- _______________________________________________________________________
-- Atmosphere/Bluesky
create table iembot_atmosphere_accounts (
    id serial unique not null,
    iembot_account_id bigint not null references iembot_accounts (id),
    handle text not null,
    app_pass text not null,
    disabled bool default 'f',
    iem_owned bool default 'f'
);
alter table iembot_atmosphere_accounts owner to mesonet;
grant all on iembot_atmosphere_accounts_id_seq to nobody;
grant all on iembot_atmosphere_accounts to nobody;

-- _________________________________________________________________
-- Twitter/X
create table iembot_twitter_oauth (
    user_id bigint not null unique,
    iembot_account_id bigint not null references iembot_accounts (id),
    screen_name text,
    access_token text,
    access_token_secret text,
    created timestamptz default now(),
    updated timestamptz default now(),
    disabled bool default 'f',
    iem_owned bool default 'f'
);
alter table iembot_twitter_oauth owner to mesonet;
grant all on iembot_twitter_oauth to nobody;

-- ______________________________________________________________________
-- IEMBot rooms on weather.im
create table iembot_rooms (
    iembot_account_id bigint not null references iembot_accounts (id),
    roomname varchar unique not null
);
alter table iembot_rooms owner to mesonet;
grant all on iembot_rooms to nobody;

-- Storage of Google Oauth users for webhooks
create table iembot_webhook_users (
    id serial primary key,
    google_id text not null unique,
    created_at timestamptz default now()
);
alter table iembot_webhook_users owner to mesonet;
grant all on iembot_webhook_users to nobody;
grant all on iembot_webhook_users_id_seq to nobody;

-- Association of webooks to users
-- The account id is associated here as this is where channel subscriptions go
create table iembot_webhooks (
    id serial primary key,
    iembot_webhook_user_id int not null references iembot_webhook_users (id),
    iembot_account_id integer not null references iembot_accounts (id),
    url text not null unique,
    hook_label text,
    created_at timestamptz default now()
);
alter table iembot_webhooks owner to mesonet;
grant all on iembot_webhooks to nobody;
grant all on iembot_webhooks_id_seq to nobody;
