create table ml
(mlname varchar2(50) constraint pk_ml primary key,
description varchar2(2000),
mod_by varchar2(50),
mod_date date,
inactive_d date)
/
create table title_mail
(mlname varchar2(50) constraint fk_tiltlemail_ml references ml,
job_code varchar2(6) constraint fk_titlemail_title references title)
/
create table bu_mail
(mlname varchar2(50) constraint fk_bumail_ml references ml,
bu_code varchar2(6) constraint fk_bumail_title references bu)
/
