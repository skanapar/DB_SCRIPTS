TIMESTAMP=$(date +"%Y%m%d_%H%M%S"); export TIMESTAMP
for  ORACLE_HOME in `cat /etc/oratab|grep -v "^#"| grep dbhome|cut -d":" -f2`
do

if grep  -q CATALOG_NP  $ORACLE_HOME/network/admin/tnsnames.ora 
then 
echo "CATALOG found"
else
echo CATALOG not found
cp -p $ORACLE_HOME/network/admin/tnsnames.ora $ORACLE_HOME/network/admin/tnsnames.ora.${TIMESTAMP}
sleep 5
echo "CATALOG_NP =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST =pphx.oraclevcn.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME =)
    )
  )" >>$ORACLE_HOME/network/admin/tnsnames.ora
fi
if grep  -q CATALOG_PR  $ORACLE_HOME/network/admin/tnsnames.ora 
then 
echo "CATALOG found"
else
echo CATALOG not found
cp -p $ORACLE_HOME/network/admin/tnsnames.ora $ORACLE_HOME/network/admin/tnsnames.ora.${TIMESTAMP}
sleep 5
echo "CATALOG_NP =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = .oraclevcn.com )(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = )
    )
  )" >>$ORACLE_HOME/network/admin/tnsnames.ora
fi
echo $ORACLE_HOME
done
