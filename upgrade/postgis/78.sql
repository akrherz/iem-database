-- Ensure some of the LSR columns have no commas
ALTER TABLE lsrs
ADD CONSTRAINT check_city_no_comma CHECK (strpos(city, ',') = 0),
ADD CONSTRAINT check_county_no_comma CHECK (strpos(county, ',') = 0),
ADD CONSTRAINT check_source_no_comma CHECK (strpos(source, ',') = 0),
ADD CONSTRAINT check_typetext_no_comma CHECK (strpos(typetext, ',') = 0);
