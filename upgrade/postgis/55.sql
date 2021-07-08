-- SPC Outlooks join
--
CREATE VIEW spc_outlooks AS
    select id, issue, product_issue, expire, threshold, category, day,
    outlook_type, geom, product_id, updated
    from spc_outlook o JOIN spc_outlook_geometries g
    on (o.id = g.spc_outlook_id);
ALTER VIEW spc_outlooks OWNER to mesonet;
GRANT SELECT on spc_outlooks to ldm,nobody,apache;
