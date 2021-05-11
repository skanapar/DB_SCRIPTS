drop table plan_hashes;
create table plan_hashes(
sql_text varchar2(1000),
hash_value number,
plan_hash_value number,
username varchar2(30)
);

alter table plan_hashes add constraint plan_hashes_pk primary key (hash_value,sql_text,plan_hash_value);
