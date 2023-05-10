-- Storage of DEP versioning dailyerosion/dep#179
create table dep_version(
    label text unique not null,
    wepp text not null,
    acpf text not null,
    flowpath text not null,
    gssurgo text not null,
    software text not null
);
alter table dep_version owner to mesonet;
grant select on dep_version to nobody;
create unique index dep_version_idx
    on dep_version(label, wepp, acpf, flowpath, gssurgo, software);
