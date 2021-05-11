for sid in `cat /etc/oratab|grep pd|grep -v "_2"|grep dbh|grep -v rmpd|grep -v "^#"|cut -d ":" -f1`
 do
 ORACLE_SID=$sid
 db_name=`echo $sid|cut -c1-8`
 echo "db_name=$db_name" >${ORACLE_HOME}/dbs/init${sid}.ora
du_name=`echo $db_name| sed -e 's/pd/dr/g'`

sqlplus  -s "/as sysdba" <<EOF
startup nomount
EOF

rman   <<EOF
connect auxiliary sys/${SYSPASSWORD}@${du_name}
connect target sys/${SYSPASSWORD}@${db_name}
DUPLICATE TARGET DATABASE
  FOR STANDBY
  FROM ACTIVE DATABASE
  DORECOVER
  SPFILE
    SET "db_unique_name"="${du_name}"
    SET LOG_ARCHIVE_DEST_2="service=${db_name} ASYNC REGISTER
     VALID_FOR=(online_logfile,primary_role)"
    SET FAL_SERVER="${db_name}" COMMENT "Is primary"
  NOFILENAMECHECK;
EOF

 done
