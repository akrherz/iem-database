-- Add storage of 2017 landuse codes
ALTER TABLE flowpath_points ADD lu2017 char(1);

-- default it's value to whatever we did in 2015
UPDATE flowpath_points SET lu2017 = lu2015;
