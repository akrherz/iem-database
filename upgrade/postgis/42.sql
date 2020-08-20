-- akrherz/pyIEM#276
ALTER TABLE warnings add hvtec_severity char(1);
ALTER TABLE warnings add hvtec_cause char(2);
ALTER TABLE warnings add hvtec_record char(2);

ALTER TABLE sbw add hvtec_severity char(1);
ALTER TABLE sbw add hvtec_cause char(2);
ALTER TABLE sbw add hvtec_record char(2);
