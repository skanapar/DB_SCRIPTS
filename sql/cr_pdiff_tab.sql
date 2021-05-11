drop table pdiff
/
create table pdiff
(param varchar2(100) not null primary key,
src_v varchar2(200),
tgt_v varchar2(200),
deprecated char(1))
tablespace administrator
/