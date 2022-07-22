-- Storage of Type of Observation this is
CREATE TABLE alldata_report_type(
  id smallint UNIQUE NOT NULL,
  label varchar);
GRANT SELECT on alldata_report_type to nobody;

INSERT into alldata_report_type VALUES
    (0, 'Unknown'),
    (1, 'MADIS HFMETAR'),
    (2, 'Legacy Routine+Special'),
    (3, 'Routine'),
    (4, 'Special');

ALTER TABLE alldata ADD report_type smallint REFERENCES alldata_report_type(id);
