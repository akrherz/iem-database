-- More explicit storage of how things map
ALTER TABLE scenarios ADD climate_scenario int;
ALTER TABLE scenarios ADD huc12_scenario int;
ALTER TABLE scenarios add flowpath_scenario int;

UPDATE scenarios SET climate_scenario = 0;
UPDATE scenarios SET huc12_scenario = 0;
UPDATE scenarios SET flowpath_scenario = 0;
