-- Storage of product references
alter table sigmets_current add product_id varchar(36);
alter table sigmets_archive add product_id varchar(36);
