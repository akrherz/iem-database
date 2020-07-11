-- dailyerosion/dep#71 adjust storage of yearly management / tillage

ALTER TABLE flowpath_points ADD landuse varchar(32);

UPDATE flowpath_points SET landuse = lu2007 || lu2008 || lu2009 || lu2010
  || lu2011 || lu2012 || lu2013 || lu2014 || lu2015 || lu2016 || lu2017
  || lu2018 || lu2019;

ALTER TABLE flowpath_points DROP lu2007;
ALTER TABLE flowpath_points DROP lu2008;
ALTER TABLE flowpath_points DROP lu2009;
ALTER TABLE flowpath_points DROP lu2010;
ALTER TABLE flowpath_points DROP lu2011;
ALTER TABLE flowpath_points DROP lu2012;
ALTER TABLE flowpath_points DROP lu2013;
ALTER TABLE flowpath_points DROP lu2014;
ALTER TABLE flowpath_points DROP lu2015;
ALTER TABLE flowpath_points DROP lu2016;
ALTER TABLE flowpath_points DROP lu2017;
ALTER TABLE flowpath_points DROP lu2018;
ALTER TABLE flowpath_points DROP lu2019;

ALTER TABLE flowpath_points RENAME management to bogus;
ALTER TABLE flowpath_points ADD management varchar(32);

UPDATE flowpath_points SET management = repeat(bogus::text, 13);

ALTER TABLE flowpath_points DROP bogus;
