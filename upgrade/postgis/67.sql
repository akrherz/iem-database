-- Storage of geometries
alter table spc_outlook_geometries add
    geom_layers geometry(MultiPolygon, 4326)
    CONSTRAINT _sog_geom_layers_isvalid CHECK (ST_IsValid(geom_layers));

create index spc_outlook_geometries_layers_gix
    on spc_outlook_geometries using gist(geom_layers);
