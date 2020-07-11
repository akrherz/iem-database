-- More explicitly support the landuse codes stored in the database
ALTER TABLE flowpath_points RENAME landuse1 TO lu2007;
ALTER TABLE flowpath_points RENAME landuse2 TO lu2008;
ALTER TABLE flowpath_points RENAME landuse3 TO lu2009;
ALTER TABLE flowpath_points RENAME landuse4 TO lu2010;
ALTER TABLE flowpath_points RENAME landuse5 TO lu2011;
ALTER TABLE flowpath_points RENAME landuse6 TO lu2012;

ALTER TABLE flowpath_points ADD lu2013 char(1);
ALTER TABLE flowpath_points ADD lu2014 char(1);
ALTER TABLE flowpath_points ADD lu2015 char(1);
ALTER TABLE flowpath_points ADD lu2016 char(1);
