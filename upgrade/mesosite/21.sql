-- Storage of how stations are threaded together
CREATE TABLE station_threading(
    iemid int REFERENCES stations(iemid),
    source_iemid int REFERENCES stations(iemid),
    begin_date date NOT NULL,
    end_date date
);
ALTER TABLE station_threading OWNER to mesonet;
GRANT ALL on station_threading to ldm;
GRANT SELECT on station_threading to nobody;
