-- Storage of ancillary LSR metadata
ALTER TABLE lsrs add product_id text;
ALTER TABLE lsrs add updated timestamptz DEFAULT now();
