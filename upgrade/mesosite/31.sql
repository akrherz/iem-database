-- Enhance iemapps
alter table iemapps alter name type text;
alter table iemapps alter url type text;
alter table iemapps add category text not null default '';
alter table iemapps add subcategory text not null default '';
alter table iemapps add tags text [] not null default '{}';
alter table iemapps add importance int not null default 0;

-- migrate existing data in iemapps_tags
update iemapps i
set tags = (
    select array_agg(t.tag) from iemapps_tags as t
    where t.appid = i.appid
);
