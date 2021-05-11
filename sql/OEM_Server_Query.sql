select distinct database_name,instance_name, NVL (SUBSTR (a.host_name, 1, INSTR (a.host_name, '.') - 1),
            a.host_name)
           host_short,dbversion
from sysman.MGMT_DB_DBNINSTANCEINFO_ECM a
where startup_time > sysdate -400
order by database_name, instance_name
