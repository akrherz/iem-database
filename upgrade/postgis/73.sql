-- Storage of MCD most prob strings
-- akrherz/pyiem#1042
alter table mcd add most_prob_tornado text;
alter table mcd add most_prob_gust text;
alter table mcd add most_prob_hail text;