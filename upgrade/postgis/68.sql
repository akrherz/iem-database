-- akrherz/pyIEM#857
alter table warnings add product_ids varchar(36)[] not null default '{}';
alter table sbw add product_id varchar(36);
