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
