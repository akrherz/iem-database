-- Storage of raw reports
ALTER TABLE summary add report text;

ALTER TABLE current_shef add dv_interval interval;
ALTER TABLE current_shef add qualifier char(1);
ALTER TABLE current_shef add unit_convention char(1);

CREATE OR REPLACE RULE replace_current_shef AS ON 
    INSERT TO current_shef WHERE (EXISTS 
        (SELECT 1 FROM current_shef WHERE
        station = new.station and physical_code = new.physical_code and
        duration = new.duration and source = new.source and type = new.type and
        extremum = new.extremum and ((new.depth is null and depth is null) or 
        depth = new.depth))) DO INSTEAD 
        UPDATE current_shef SET value = new.value, valid = new.valid,
        dv_interval = new.dv_interval, qualifier = new.qualifier,
        unit_convention = new.unit_convention 
        WHERE station = new.station and physical_code = new.physical_code and
        duration = new.duration and source = new.source and
        type = new.type and extremum = new.extremum and valid < new.valid and
        ((new.depth is null and depth is null) or depth = new.depth);
