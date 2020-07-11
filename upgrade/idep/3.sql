--- Explicitly store the climate file location in the database to prevent 
--- confusion, by me
ALTER TABLE flowpaths add climate_file varchar(128);