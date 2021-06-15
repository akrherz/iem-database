-- Complete storage needs
ALTER TABLE nass_quickstats add short_desc text;
create index nass_quickstats_year_idx on nass_quickstats(year);
create index nass_quickstats_idx on nass_quickstats(year, short_desc);
