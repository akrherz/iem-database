-- Store more wind erosion output
ALTER TABLE field_wind_erosion_results ADD pm10_kgm2 real;
ALTER TABLE field_wind_erosion_results ADD pm2_5_kgm2 real;
ALTER TABLE field_wind_erosion_results ADD salt_creep_kgm2 real;
