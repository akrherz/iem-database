--- Add delivery to output table
---
ALTER TABLE results_by_huc12 add min_delivery real;
ALTER TABLE results_by_huc12 add avg_delivery real;
ALTER TABLE results_by_huc12 add max_delivery real;