-- Storage of citations of the website
create table website_citations (
    publication_date date not null,
    title text not null,
    link text,
    iem_resource text
);
alter table website_citations owner to mesonet;
grant select,insert on website_citations to nobody;
