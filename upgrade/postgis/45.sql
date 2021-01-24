-- Storage of when this row was updated and the product_id
ALTER TABLE spc_outlooks ADD product_id varchar(32);
ALTER TABLE spc_outlooks ADD updated timestamptz DEFAULT now();
