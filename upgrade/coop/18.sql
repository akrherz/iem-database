-- Stuff gleaned from the PDF reports, sick.
create table nass_iowa(
    valid date,
    metric text,
    nw int,
    nc int,
    ne int,
    wc int,
    c int,
    ec int,
    sw int,
    sc int,
    se int,
    load_time timestamptz default now(),
    iowa int
);
alter table nass_iowa owner to mesonet;
grant select on nass_iowa to nobody;
create index nass_iowa_valid_idx on nass_iowa(valid);
