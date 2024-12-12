-- Correct isAG storage from bool to int
alter table fields rename isag to isag_old;
alter table fields add isag int;
update fields set isag = 0 where not isag_old;
update fields set isag = 1 where isag_old;
alter table fields drop isag_old;
