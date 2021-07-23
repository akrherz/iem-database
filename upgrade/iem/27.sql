-- Storage of daily min/max stage akrherz/iem#278
ALTER TABLE summary ADD min_rstage real;
ALTER TABLE summary ADD max_rstage real;
