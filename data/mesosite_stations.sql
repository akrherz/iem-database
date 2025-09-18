copy stations(id,synop,name,state,country,elevation,network,online,params,county,plot_name,climate_site,remote_id,nwn_id,spri,wfo,archive_begin,archive_end,modified,tzname,iemid,metasite,sigstage_low,sigstage_action,sigstage_bankfull,sigstage_flood,sigstage_moderate,sigstage_major,sigstage_record,ugc_county,ugc_zone,geom,ncdc81,temp24_hour,precip24_hour,ncei91) FROM STDIN (FORMAT CSV);
SRMS2,9999,Ramona,SD,US,553,KELO,f,,Lake,Ramona,SD5090,,506,0,ABR,2005-04-18,2014-05-28,2023-11-06 12:56:05.585489-06,America/Chicago,20813,f,,,,,,,,SDC079,SDZ055,0101000020E61000003D2CD49AE64D58C03A92CB7F480F4640,USC00395090,,,USC00395090
96404,,Tok 70 SE,AK,US,2000,USCRN,t,,Southeast Fairbanks,,AKTAGY,,,,AFG,,,2021-04-20 07:54:46.367603-05,America/Anchorage,254829,f,,,,,,,,AKC240,AKZ224,0101000020E61000006666666666A661C03D0AD7A3705D4F40,USC00507513,,,
S2031,,Ames,IA,US,327.1,SCAN,t,tmpf,Story,Ames,IA0200,,,,DMX,2002-02-01,,2023-11-07 18:33:02.285303-06,America/Chicago,45062,f,,,,,,,,IAC015,IAZ047,0101000020E6100000AE47E17A146E57C00000000000004540,USC00130200,,,
NSTL11,99999,NSTL11 Soy/Corn Residue,IA,US,316,NSTLFLUX,t,tmpf,Story,Corn Residue,IA0200,,,0,DMX,,,2021-05-05 05:48:22.037042-05,America/Chicago,45071,f,,,,,,,,IAC169,IAZ048,0101000020E6100000C0CB0C1B656C57C0E8C371E8C6FC4440,USW00094989,,,USW00094989
\.

-- WMO BUFR Station
copy stations(id,synop,name,state,country,elevation,network,online,params,county,plot_name,climate_site,remote_id,nwn_id,spri,wfo,archive_begin,archive_end,modified,tzname,iemid,metasite,sigstage_low,sigstage_action,sigstage_bankfull,sigstage_flood,sigstage_moderate,sigstage_major,sigstage_record,ugc_county,ugc_zone,ncdc81,ncei91,temp24_hour,precip24_hour,wigos,geom) FROM STDIN (FORMAT CSV);
0-756-1-456700,,Taminatal / Wildseehorn,,UN,2690,WMO_BUFR_SRF,t,,,Taminatal / Wildseehorn,,,,,,2023-12-06,,2023-12-10 07:17:29.094614-06,Europe/Zurich,301346,f,,,,,,,,,,,,,,0-756-1-456700,0101000020E61000005CCEA5B8AACC224064E94317D47B4740
\.

-- Some faked webcam data
COPY webcams(id, geom) FROM STDIN (FORMAT CSV);
IDOT-013-01,SRID=4326;POINT(-95 42)
IDOT-013-02,SRID=4326;POINT(-95 42)
\.

COPY camera_log (cam, valid, drct) FROM STDIN (FORMAT CSV);
IDOT-013-01,2021-01-01 12:00:00+00,0
IDOT-013-02,2021-01-01 12:04:00+00,0
\.
