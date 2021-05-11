-- Drop and recreate the empty audit table

drop table disco_trail
/

create table disco_trail as
select
username, schemaname, osuser, machine, terminal, program,
module, action, logon_time, client_identifier, service_name
,SYSDATE as logoff_time
from v$session where 1=2
/

-- Create package to prevent problems with invalid database trigger

CREATE OR REPLACE PACKAGE chk_disco_pkg
AS
  PROCEDURE chk_disco_proc;
END chk_disco_pkg;
/

CREATE OR REPLACE PACKAGE BODY chk_disco_pkg
AS
PROCEDURE chk_disco_proc
IS
sess_rec disco_trail%ROWTYPE;
BEGIN
/* this requires the "select any dictionary" privilege on the user executing the proc */
select
username, schemaname, osuser, machine, terminal, program,
module, action, logon_time, client_identifier, service_name
,SYSDATE as logoff_time
into sess_rec
from sys.v_$session where AUDSID = SYS_CONTEXT('userenv','sessionid');
IF sess_rec.program like 'dis51ws%' /* web-based discoverer */
THEN
  INSERT INTO disco_trail
  values sess_rec;
END IF;
EXCEPTION
WHEN OTHERS THEN NULL;
END chk_disco_proc;
END chk_disco_pkg;
/


-- Create the database trigger calling the procedure in the package
-- Logoff trigger to be able to capture logon and logoff times

CREATE OR REPLACE TRIGGER chk_disco_trg
BEFORE LOGOFF ON DATABASE
BEGIN
chk_disco_pkg.chk_disco_proc;
EXCEPTION
WHEN OTHERS THEN NULL;
END chk_disco_trg;
/
