-- Storage of IEMBot Slack info
create table iembot_slack_teams(
    id serial primary key,
    team_id text unique not null,
    team_name text,
    access_token text not null,
    bot_user_id text,
    installed_at timestamptz default now()
);
alter table iembot_slack_teams owner to mesonet;
grant all on iembot_slack_teams to nobody;
grant all on iembot_slack_teams_id_seq to nobody;

create table iembot_slack_subscriptions(
    id serial primary key,
    team_id text not null references iembot_slack_teams(team_id),
    channel_id text not null,
    subkey text not null,
    created_at timestamptz default now()
);
create unique index on iembot_slack_subscriptions(team_id, channel_id, subkey);
alter table iembot_slack_subscriptions owner to mesonet;
grant all on iembot_slack_subscriptions to nobody;
grant all on iembot_slack_subscriptions_id_seq to nobody;
