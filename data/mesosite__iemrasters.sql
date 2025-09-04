copy iemrasters(id,name,description,archive_start,archive_end,units,interval,filename_template,cf_long_name) from STDIN with (format csv);
9,composite_eet,This is a composite of 8bit Echo Tops (EET),,,kft,5,,
1,composite_n0r,This is a composite of Reflectivity (N0R),1996-01-01 00:00:00-06,,dBZ,5,/mesonet/ARCHIVE/data/%Y/%m/%d/GIS/uscomp/n0r_%Y%m%d%H%M.png,reflectivity
2,composite_n0q,This is a composite of 8bit Reflectivity (N0Q),2010-01-01 00:00:00-06,,dBZ,5,/mesonet/ARCHIVE/data/%Y/%m/%d/GIS/uscomp/n0q_%Y%m%d%H%M.png,reflectivity
4,mrms_lcref,NCEP MRMS 2 minute lowest elevation composite reflectivity.,,,dBZ,2,/mesonet/ARCHIVE/data/%Y/%m/%d/GIS/mrms/lcref_%Y%m%d%H%M.png,reflectivity
3,mrms_a2m,NCEP MRMS 2 minute interval precipitation accumulation.,,,mm,2,/mesonet/ARCHIVE/data/%Y/%m/%d/GIS/mrms/a2m_%Y%m%d%H%M.png,precipitation_amount
6,mrms_p24h,NCEP MRMS 24 Hour Accumulated Precipitation.,,,mm,60,/mesonet/ARCHIVE/data/%Y/%m/%d/GIS/mrms/p24h_%Y%m%d%H%M.png,precipitation_amount
7,mrms_p48h,NCEP MRMS 48 Hour Accumulated Precipitation,,,mm,60,/mesonet/ARCHIVE/data/%Y/%m/%d/GIS/mrms/p48h_%Y%m%d%H%M.png,precipitation_amount
8,mrms_p72h,NCEP MRMS 72 Hour Accumulated Precipitation.,,,mm,60,/mesonet/ARCHIVE/data/%Y/%m/%d/GIS/mrms/p72h_%Y%m%d%H%M.png,precipitation_amount
5,mrms_p1h,NCEP MRMS 1 Hour Accumulated Precipitation.,,,mm,60,/mesonet/ARCHIVE/data/%Y/%m/%d/GIS/mrms/p1h_%Y%m%d%H%M.png,precipitation_amount
\.

copy iemrasters_lookup(iemraster_id,coloridx,value,r,g,b) from STDIN with (format csv);
1,1,-30,0,0,0
1,2,-25,0,0,0
1,3,-20,0,0,0
1,4,-15,0,0,0
1,5,-10,0,0,0
1,6,-5,0,0,0
1,7,0,0,236,236
1,8,5,1,160,246
1,9,10,0,0,246
1,10,15,0,255,0
1,11,20,0,200,0
1,12,25,0,144,0
1,13,30,255,255,0
1,14,35,231,192,0
1,15,40,255,144,0
1,16,45,255,0,0
1,17,50,214,0,0
1,18,55,192,0,0
1,19,60,255,0,255
1,20,65,153,85,201
1,21,70,255,255,255
1,0,,0,0,0
\.

