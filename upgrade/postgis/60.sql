-- Storage of Watch Probabilites
ALTER TABLE watches add tornadoes_2m smallint;
ALTER TABLE watches add tornadoes_1m_strong smallint;
ALTER TABLE watches add wind_10m smallint;
ALTER TABLE watches add wind_1m_65kt smallint;
ALTER TABLE watches add hail_10m smallint;
ALTER TABLE watches add hail_1m_2inch smallint;
ALTER TABLE watches add hail_wind_6m smallint;
ALTER TABLE watches add max_hail_size float;
ALTER TABLE watches add max_wind_gust_knots float;
ALTER TABLE watches add max_tops_feet int;
ALTER TABLE watches add storm_motion_drct int;
ALTER TABLE watches add storm_motion_sknt int;
ALTER TABLE watches add is_pds bool;
ALTER TABLE watches add product_id_wwp varchar(36);
ALTER TABLE watches add product_id_saw varchar(36);
ALTER TABLE watches add product_id_wou varchar(36);
