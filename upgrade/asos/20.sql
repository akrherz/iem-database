-- Improved TAF storage
create table taf_ftype(
    ftype smallint not null,
    abbr text not null,
    label text not null
);
alter table taf_ftype owner to mesonet;
grant select on taf_ftype to nobody, ldm;
create unique index taf_ftype_idx on taf_ftype(ftype);

insert into taf_ftype(ftype, abbr, label) values
(0, 'OB', 'Observation'),
(1, 'FM', 'Forecast'),
(2, 'TEMPO', 'Temporary'),
(3, 'PROB30', 'Probability 30'),
(4, 'PROB40', 'Probability 40'),
(5, 'BECMG', 'Becoming');

alter table taf_forecast
    add column ftype smallint REFERENCES taf_ftype(ftype);
