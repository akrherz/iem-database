-- Add alias
alter table iembot_webhooks add hook_label text;

-- Fix permissions
grant all on iembot_webhook_users_id_seq to nobody;
grant all on iembot_webhooks_id_seq to nobody;
