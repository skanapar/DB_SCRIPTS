whenever sqlerror continue
revoke oem_monitor from  c##omc_user;
grant oem_monitor to c##omc_user container=all;
grant  INHERIT ANY PRIVILEGES  to c##omc_user container=all;
conn c##dbv_acctmgr_root/howREetha7$d
alter user c##omc_user set container_data=all CONTAINER=CURRENT;
--grant  INHERIT ANY PRIVILEGES  to c##omc_user container=all;
 

