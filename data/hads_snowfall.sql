-- 6 hour snowfall
insert into raw2023_11(station, valid, key, value) values
('DNKI4', '2023-11-10 12:00+00', 'SFQRZZZ', 10),
('DNKI4', '2023-11-10 12:00+00', 'SDIRZZZ', 20),
('DNKI4', '2023-11-10 12:00+00', 'PPQRZZZ', 30),
('DNKI4', '2023-11-10 12:00+00', 'SWIRZZZ', 40);

insert into raw2024_12(station, valid, key, value) values
('DSXI4', '2024-12-31 18:00+00', 'SFQRZZZ', 0.0001),
('DSXI4', '2024-12-31 06:00+00', 'SFQRZZZ', 0.2);

-- needed for 6 hour join to work.
insert into stations(iemid, id, name, network, geom) values
(-1, 'DNKI4', 'Des Moines', 'IA_DCP', ST_Point(-93.648, 41.533, 4326));

insert into t2023(station, valid, tmpf) values
('DNKI4', '2023-11-10 12:00+00', 32.0);
