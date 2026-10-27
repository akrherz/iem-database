ALTER TABLE stations DROP COLUMN sigstage_low;
ALTER TABLE stations RENAME COLUMN sigstage_bankfull TO sigstage_minor;
ALTER TABLE stations DROP COLUMN sigstage_flood;
