-- Storage of a color for the road conditions
ALTER TABLE roads_conditions ADD color char(7) DEFAULT '#000000' NOT NULL;
