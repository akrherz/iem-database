-- Storage of Google Oauth users for webhooks
create table iembot_webhook_users (
    id serial primary key,
    google_id text not null unique,
    created_at timestamptz default now()
);
alter table iembot_webhook_users owner to mesonet;
grant all on iembot_webhook_users to nobody;

-- Association of webooks to users
-- The account id is associated here as this is where channel subscriptions go
create table iembot_webhooks (
    id serial primary key,
    iembot_webhook_user_id int not null references iembot_webhook_users (id),
    iembot_account_id integer not null references iembot_accounts (id),
    url text not null unique,
    created_at timestamptz default now()
);
alter table iembot_webhooks owner to mesonet;
grant all on iembot_webhooks to nobody;
