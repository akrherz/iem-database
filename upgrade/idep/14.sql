-- Grid order storage
ALTER TABLE flowpath_points ADD gridorder smallint;
UPDATE flowpath_points SET gridorder = 4;
