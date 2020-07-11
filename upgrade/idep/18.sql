-- Add storage of 2019 landuse codes
ALTER TABLE flowpath_points ADD lu2019 char(1);

-- default it's value to whatever we did in 2016
UPDATE flowpath_points SET lu2019 = lu2017;
