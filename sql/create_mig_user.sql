create user mig_user identified by &mig_user_password
default tablespace &tablespace_name
/
grant connect, create table, select any table to mig_user
/
