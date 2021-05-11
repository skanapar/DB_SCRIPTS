drop database link &&db_link
/
create database link  &&db_link  
connect to C##REMOTE_USER_FOR_CLONE identified by &pass_remote_clone_user 
using '(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = .oraclevcn.com)(PORT = 1521)) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = &&db_link..DOMAIN) (FAILOVER_MODE = (TYPE = select) (METHOD = basic))))'
/
select sysdate from dual@&&db_link
/
