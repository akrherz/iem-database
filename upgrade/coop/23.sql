-- storage of soil min max temperature so to compute GDDs
ALTER TABLE alldata ADD nldas_soilt4_min real;
ALTER TABLE alldata ADD nldas_soilt4_max real;
ALTER TABLE alldata ADD era5land_soilt4_min real;
ALTER TABLE alldata ADD era5land_soilt4_max real;
