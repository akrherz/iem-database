-- fix grid
do
$do$
declare
     x int;
     y int;
     left_edge real = -10.0625;
     left_center real = -10.0;
     bottom_edge real = 34.9375;
     bottom_center real = 35.0;
     spacing real = 0.125;
     columns int = 400;
begin
    for x in 0..399
    loop
        for y in 0..279
        loop
        execute format($f$
            update iemre_grid set cell_center = ST_Point(%s, %s, 4326),
            cell_polygon = ST_MakeEnvelope(%s, %s, %s, %s, 4326)
            where gid = %s
        $f$,
        left_center + x * spacing,
        bottom_center + y * spacing,
        left_edge + x * spacing,
        bottom_edge + y * spacing,
        left_edge + (x + 1) * spacing,
        bottom_edge + (y  + 1) * spacing,
        x + y * columns
        );
        end loop;
    end loop;
end;
$do$;
