-- Inversion station data
CREATE TABLE sm_inversion(
    station varchar(5),
    valid timestamptz,
    tair_15_c_avg real,
    tair_15_c_avg_qc real,
    tair_15_c_avg_f char(1),
    tair_5_c_avg real,
    tair_5_c_avg_qc real,
    tair_5_c_avg_f char(1),
    tair_10_c_avg real,
    tair_10_c_avg_qc real,
    tair_10_c_avg_f char(1),

    ws_ms_avg real,
    ws_ms_avg_qc real,
    ws_ms_avg_f char(1),
    ws_ms_max real,
    ws_ms_max_qc real,
    ws_ms_max_f char(1),
    duration smallint DEFAULT 1
);
ALTER TABLE sm_inversion OWNER to mesonet;
GRANT SELECT on sm_inversion to nobody,apache;
CREATE UNIQUE INDEX sm_inversion_idx on sm_inversion(station, valid);
