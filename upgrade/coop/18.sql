-- Stuff gleaned from the PDF reports, sick.
create table nass_iowa(
    valid date,
    metric text,
    nw numeric,
    nc numeric,
    ne numeric,
    wc numeric,
    c numeric,
    ec numeric,
    sw numeric,
    sc numeric,
    se numeric,
    iowa numeric,
    load_time timestamptz default now()
);
alter table nass_iowa owner to mesonet;
grant select on nass_iowa to nobody;
create index nass_iowa_valid_idx on nass_iowa(valid);
