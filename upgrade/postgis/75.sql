-- Reorg for new SPC thresholds akrherz/pyIEM#1156

-- More intuitively align old thresholds
update spc_outlook_thresholds SET priority = 2 where threshold = '0.02';
update spc_outlook_thresholds SET priority = 5 where threshold = '0.05';
update spc_outlook_thresholds SET priority = 10 where threshold = '0.10';
update spc_outlook_thresholds SET priority = 15 where threshold = '0.15';
update spc_outlook_thresholds SET priority = 25 where threshold = '0.25';
update spc_outlook_thresholds SET priority = 30 where threshold = '0.30';
update spc_outlook_thresholds SET priority = 35 where threshold = '0.35';
update spc_outlook_thresholds SET priority = 40 where threshold = '0.40';
update spc_outlook_thresholds SET priority = 45 where threshold = '0.45';
update spc_outlook_thresholds SET priority = 60 where threshold = '0.60';

-- meh
update spc_outlook_thresholds SET priority = 104 where threshold = 'SIGN';

-- Add new ones
insert into spc_outlook_thresholds(priority, threshold) values
    (75, '0.75'),
    (90, '0.90'),
    (101, 'CIG1'),
    (102, 'CIG2'),
    (103, 'CIG3');
