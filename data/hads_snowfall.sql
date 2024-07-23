-- 6 hour snowfall
insert into raw2023_11(station, valid, key, value) values
('DNKI4', '2023-11-10 12:00+00', 'SFQRZZZ', 10);

-- needed for 6 hour join to work.
insert into stations(iemid, id, name, network, geom) values
(-1, 'DNKI4', 'Des Moines', 'IA_DCP', ST_Point(-93.648, 41.533, 4326));

insert into t2023(station, valid, tmpf) values
('DNKI4', '2023-11-10 12:00+00', 32.0);
