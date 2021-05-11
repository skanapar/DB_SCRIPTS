select username, account_status from dba_users where username in ('BOOKER','OLTP_USER','DOSQL','UADMIN','SYSTEM','ADMIN');
alter user BOOKER account lock;
alter user OLTP_USER account lock;
alter user DOSQL account lock;
alter user UADMIN account lock;
alter user SYSTEM account lock;
alter user ADMIN account lock;

