SPOOL_FILE="/tmp/add_service_$$PID.lst"
echo $SPOOL_FILE
sqlplus -s "/as sysdba" <<EOF
show pdbs
set linesize 300
set heading off
set feedback off
set echo off
spool $SPOOL_FILE
select  'srvctl add service -d '|| d.db_unique_name|| ' -s '||p.name||'.HARDCODED_DOMAIN -pdb '||p.name ||' -preferred '||
        substr(d.db_unique_name,1, instr(d.db_unique_name,'_')-1) ||'1,'
        ||substr(d.db_unique_name,1, instr(d.db_unique_name,'_')-1) ||'2'
         ||' -role primary'
from  v\$database d, v\$pdbs p
where p.con_id >1
and p.name <>'PDB\$SEED'
and p.name not like '%JUNK%'
union
select 'srvctl start service -d '|| db_unique_name
from v\$database
/

select 'srvctl status service -d '|| db_unique_name
from v\$database
/
spool off

EOF
cat $SPOOL_FILE
echo "********************************************************************************"
echo "executing above in 10 seconds. Hit CTRL+C to exit"
echo "********************************************************************************"
sleep 10
set -x

`sh $SPOOL_FILE`






