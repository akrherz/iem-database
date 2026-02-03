
select create_iembot_channel('AFDDMX', 'Area Forecast Discussion DMX');

--

do $$
declare
  dmxchat bigint;
  dvnchat bigint;
  masto_iembot_test bigint;
  twitter_iembot bigint;
  slack_iemchat bigint;
  atmosphere_iembot bigint;
begin
  dmxchat := create_iembot_account('xmpp');
  dvnchat := create_iembot_account('xmpp');
  masto_iembot_test := create_iembot_account('mastodon');
  twitter_iembot := create_iembot_account('twitter');
  slack_iemchat := create_iembot_account('slack');
  atmosphere_iembot := create_iembot_account('atmosphere');

  insert into iembot_rooms(iembot_account_id, roomname) values
    (dmxchat, 'dmxchat'),
    (dvnchat, 'dvnchat');
end $$;

insert into iembot_subscriptions(
    iembot_account_id, channel_id
) values (
    (select iembot_account_id from iembot_rooms where roomname = 'dmxchat'),
    (select id from iembot_channels where channel_name = 'AFDDMX')
);

--

insert into iembot_mastodon_apps(id, server, client_id, client_secret)
 values (-1, 'masto.globaleas.org', 
 '...',
 '...');

insert into iembot_mastodon_oauth (id, appid, access_token, iembot_account_id,
screen_name)
values(-1, -1, '...',
    (select id from iembot_accounts where service = 'mastodon'),
    'iembot_test'
);

insert into iembot_subscriptions(
    iembot_account_id, channel_id
) values (
    (select id from iembot_accounts where service = 'mastodon'),
    (select id from iembot_channels where channel_name = 'AFDDMX')
);

--

insert into iembot_twitter_oauth (iembot_account_id, screen_name, user_id,
access_token, access_token_secret) values (
    (select id from iembot_accounts where service = 'twitter'),
    'iembot', 0,
    '...',
    '...'
);

insert into iembot_subscriptions(
    iembot_account_id, channel_id
) values (
    (select id from iembot_accounts where service = 'twitter'),
    (select id from iembot_channels where channel_name = 'AFDDMX')
);

--

insert into iembot_slack_teams (team_id, team_name, access_token, bot_user_id)
values ('TSS', 'IEM Chat', 
'...', '...');

insert into iembot_slack_team_channels(iembot_account_id, team_id, channel_id)
values (
    (select id from iembot_accounts where service = 'slack'),
    'TSS',
    'CSD'
);

insert into iembot_subscriptions(
    iembot_account_id, channel_id
) values (
    (select id from iembot_accounts where service = 'slack'),
    (select id from iembot_channels where channel_name = 'AFDDMX')
);

--

insert into iembot_atmosphere_accounts(iembot_account_id, handle, app_pass)
values (
    (select id from iembot_accounts where service = 'atmosphere'),
    'iembot.weather.im',
    '...'
);

insert into iembot_subscriptions(
    iembot_account_id, channel_id
) values (
    (select id from iembot_accounts where service = 'atmosphere'),
    (select id from iembot_channels where channel_name = 'AFDDMX')
);
