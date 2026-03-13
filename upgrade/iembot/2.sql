-- Store some additional slack stuff
alter table iembot_slack_teams add iem_owned bool default 'f';
alter table iembot_slack_teams add disabled bool default 'f';
