-- SPC Outlooks join
--
CREATE OR REPLACE VIEW spc_outlooks AS
    select id, issue, product_issue, expire, threshold, category, day,
    outlook_type, geom, product_id, updated, cycle
    from spc_outlook o LEFT JOIN spc_outlook_geometries g
    on (o.id = g.spc_outlook_id);
ALTER VIEW spc_outlooks OWNER to mesonet;
GRANT SELECT on spc_outlooks to ldm,nobody;

create index spc_outlook_combo_idx
     on spc_outlook(outlook_type, day, cycle);
create index spc_outlook_geometries_combo_idx
    on spc_outlook_geometries(threshold, category);

