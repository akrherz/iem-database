-- ________________________________________________________________
create table products_2015_0106( 
  CONSTRAINT __products20150106_check 
  CHECK(entered >= '2015-01-01 00:00+00'::timestamptz 
        and entered < '2015-07-01 00:00+00')) 
  INHERITS (products);

CREATE INDEX products_2015_0106_pil_idx on products_2015_0106(pil);
CREATE INDEX products_2015_0106_entered_idx on products_2015_0106(entered);
CREATE INDEX products_2015_0106_source_idx on products_2015_0106(source);
grant select on products_2015_0106 to nobody;

-- ________________________________________________________________
create table products_2015_0712( 
  CONSTRAINT __products20150712_check 
  CHECK(entered >= '2015-07-01 00:00+00'::timestamptz 
        and entered < '2016-01-01 00:00+00')) 
  INHERITS (products);

CREATE INDEX products_2015_0712_pil_idx on products_2015_0712(pil);
CREATE INDEX products_2015_0712_entered_idx on products_2015_0712(entered);
CREATE INDEX products_2015_0712_source_idx on products_2015_0712(source);
grant select on products_2015_0712 to nobody;
