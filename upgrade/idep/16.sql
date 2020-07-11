-- Add storage of 2018 landuse codes
ALTER TABLE flowpath_points ADD lu2018 char(1);

-- default it's value to whatever we did in 2016
UPDATE flowpath_points SET lu2018 = lu2016;
