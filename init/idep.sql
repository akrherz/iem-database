---
--- Version information storage
---

CREATE EXTENSION postgis;

CREATE TABLE iem_version(
  name varchar(50) UNIQUE,
  version int);
  
insert into iem_version values ('schema', -1);
