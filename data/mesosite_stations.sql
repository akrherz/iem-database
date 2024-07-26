copy stations(id,synop,name,state,country,elevation,network,online,params,county,plot_name,climate_site,remote_id,nwn_id,spri,wfo,archive_begin,archive_end,modified,tzname,iemid,metasite,sigstage_low,sigstage_action,sigstage_bankfull,sigstage_flood,sigstage_moderate,sigstage_major,sigstage_record,ugc_county,ugc_zone,geom,ncdc81,temp24_hour,precip24_hour,ncei91) FROM STDIN (FORMAT CSV);
96404,,Tok 70 SE,AK,US,2000,USCRN,t,,Southeast Fairbanks,,AKTAGY,,,,AFG,,,2021-04-20 07:54:46.367603-05,America/Anchorage,254829,f,,,,,,,,AKC240,AKZ224,0101000020E61000006666666666A661C03D0AD7A3705D4F40,USC00507513,,,
S2031,,Ames,IA,US,327.1,SCAN,t,tmpf,Story,Ames,IA0200,,,,DMX,2002-02-01,,2023-11-07 18:33:02.285303-06,America/Chicago,45062,f,,,,,,,,IAC015,IAZ047,0101000020E6100000AE47E17A146E57C00000000000004540,USC00130200,,,
RAMI4,,Ames (I-35),IA,US,313,IA_RWIS,t,"tmpf,dwpf,sknt,drct",Story,Ames (I-35),IA0200,4,,,DMX,2000-02-21,,2019-08-13 12:41:01.897685-05,America/Chicago,48120,f,,,,,,,,IAC169,IAZ048,0101000020E610000070004ABB796457C033D2FB9C5C044540,USW00094989,,,
_OAX,,Omaha Area -- KOMA KOVN KOAX,NE,US,344.00702,RAOB,f,,Douglas,"Omaha Area -- KOAX,KOMA,KOVN",NE3050,,,,OAX,,,2022-05-11 16:56:42.184461-05,America/Chicago,250581,t,,,,,,,,NEC055,NEZ052,0101000020E610000048E17A14AE1758C0295C8FC2F5A84440,USC00258795,,,
IA-PK-97,,Ankeny 1.5 NNE,IA,US,281.006,IACOCORAHS,t,,Polk,Ankeny 1.5 NNE,IA0241,,,,DMX,,,2019-08-13 12:41:01.897685-05,America/Chicago,256089,f,,,,,,,,IAC153,IAZ060,0101000020E610000012F758FAD06557C02785798F33DF4440,USC00130241,,,
NSTL11,99999,NSTL11 Soy/Corn Residue,IA,US,316,NSTLFLUX,t,tmpf,Story,Corn Residue,IA0200,,,0,DMX,,,2021-05-05 05:48:22.037042-05,America/Chicago,45071,f,,,,,,,,IAC169,IAZ048,0101000020E6100000C0CB0C1B656C57C0E8C371E8C6FC4440,USW00094989,,,USW00094989
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
