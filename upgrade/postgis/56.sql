-- mur space
ALTER TABLE text_products alter product_id type varchar(34);
ALTER TABLE sps alter product_id type varchar(34);

DROP view spc_outlooks;

ALTER TABLE spc_outlook alter product_id type varchar(34);

CREATE OR REPLACE VIEW spc_outlooks AS
    select id, issue, product_issue, expire, threshold, category, day,
    outlook_type, geom, product_id, updated, cycle
    from spc_outlook o LEFT JOIN spc_outlook_geometries g
    on (o.id = g.spc_outlook_id);
ALTER VIEW spc_outlooks OWNER to mesonet;
GRANT SELECT on spc_outlooks to ldm,nobody;

ALTER TABLE mcd alter product_id type varchar(34);
ALTER TABLE mpd alter product_id type varchar(34);
