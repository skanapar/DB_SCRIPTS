define SID=tusl1
Alter database add standby logfile group 5 '/redo-01-a/databases/&&SID/stby-t01-g05-m1.log' size 128m reuse;
Alter database add standby logfile group 6 '/redo-02-a/databases/&&SID/stby-t01-g06-m1.log' size 128m reuse;
Alter database add standby logfile group 7 '/redo-03-a/databases/&&SID/stby-t01-g07-m1.log' size 128m reuse;
Alter database add standby logfile group 8 '/redo-04-a/databases/&&SID/stby-t01-g08-m1.log' size 128m reuse;
Alter database add standby logfile group 9 '/redo-01-a/databases/&&SID/stby-t01-g09-m1.log' size 128m reuse;
Alter database add standby logfile group 10 '/redo-02-a/databases/&&SID/stby-t01-g10-m1.log' size 128m reuse;
Alter database add standby logfile group 11 '/redo-03-a/databases/&&SID/stby-t01-g11-m1.log' size 128m reuse;
Alter database add standby logfile group 12 '/redo-04-a/databases/&&SID/stby-t01-g12-m1.log' size 128m reuse;
