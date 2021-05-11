for ohdb in `grep -v -E "^#"\|"^\+"\|"^$" /etc/oratab | awk -F: '{print $2":"$1}'`
do
  oh=`echo $ohdb | awk -F: '{print $1}'`
  db=`echo $ohdb | awk -F: '{print $2}'| awk -F_ '{print $1}'`
  dbs=`echo $ohdb | awk -F: '{print $2}'`
  echo "ORACLE_HOME= $oh"
  echo "Database= $db"
  echo "Database with sffx= $dbs"
. ~/${db}.env

sqlplus -s / as sysdba <<EOF
@/db_share/DBA/prod/scripts/sql/set_audit_trc_timestamp.sql
@/db_share/DBA/prod/scripts/sql/purge_audit_trail.sql  
@/db_share/DBA/prod/scripts/sql/schedule_audit_purge_job.sql
  exit
EOF
  echo "==========================================================="
done
