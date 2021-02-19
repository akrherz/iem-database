-- Storage of multiple years
alter table climate drop max_high_yr;
alter table climate add max_high_yr int[];
alter table climate drop max_low_yr;
alter table climate add max_low_yr int[];
alter table climate drop min_high_yr;
alter table climate add min_high_yr int[];
alter table climate drop min_low_yr;
alter table climate add min_low_yr int[];
alter table climate drop max_precip_yr;
alter table climate add max_precip_yr int[];

alter table ncdc_climate71 drop max_high_yr;
alter table ncdc_climate71 add max_high_yr int[];
alter table ncdc_climate71 drop max_low_yr;
alter table ncdc_climate71 add max_low_yr int[];
alter table ncdc_climate71 drop min_high_yr;
alter table ncdc_climate71 add min_high_yr int[];
alter table ncdc_climate71 drop min_low_yr;
alter table ncdc_climate71 add min_low_yr int[];
alter table ncdc_climate71 drop max_precip_yr;
alter table ncdc_climate71 add max_precip_yr int[];

alter table ncdc_climate81 drop max_high_yr;
alter table ncdc_climate81 add max_high_yr int[];
alter table ncdc_climate81 drop max_low_yr;
alter table ncdc_climate81 add max_low_yr int[];
alter table ncdc_climate81 drop min_high_yr;
alter table ncdc_climate81 add min_high_yr int[];
alter table ncdc_climate81 drop min_low_yr;
alter table ncdc_climate81 add min_low_yr int[];
alter table ncdc_climate81 drop max_precip_yr;
alter table ncdc_climate81 add max_precip_yr int[];

alter table climate71 drop max_high_yr;
alter table climate71 add max_high_yr int[];
alter table climate71 drop max_low_yr;
alter table climate71 add max_low_yr int[];
alter table climate71 drop min_high_yr;
alter table climate71 add min_high_yr int[];
alter table climate71 drop min_low_yr;
alter table climate71 add min_low_yr int[];
alter table climate71 drop max_precip_yr;
alter table climate71 add max_precip_yr int[];

alter table climate51 drop max_high_yr;
alter table climate51 add max_high_yr int[];
alter table climate51 drop max_low_yr;
alter table climate51 add max_low_yr int[];
alter table climate51 drop min_high_yr;
alter table climate51 add min_high_yr int[];
alter table climate51 drop min_low_yr;
alter table climate51 add min_low_yr int[];
alter table climate51 drop max_precip_yr;
alter table climate51 add max_precip_yr int[];

alter table climate81 drop max_high_yr;
alter table climate81 add max_high_yr int[];
alter table climate81 drop max_low_yr;
alter table climate81 add max_low_yr int[];
alter table climate81 drop min_high_yr;
alter table climate81 add min_high_yr int[];
alter table climate81 drop min_low_yr;
alter table climate81 add min_low_yr int[];
alter table climate81 drop max_precip_yr;
alter table climate81 add max_precip_yr int[];
