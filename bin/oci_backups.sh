for profile in ASHBURN PHOENIX
do
for COMP_ID in `oci iam compartment list --all --compartment-id-in-subtree true|jq -r  '.data[]|select (."lifecycle-state" == "ACTIVE")|.id+","+."name"'`
do
CID=`echo $COMP_ID|awk -F"," '{print $1}'`
#NAME=`echo $COMP_ID|awk -F "," '{print $2}'`

 

for EXA_OCID in `oci db system list --compartment-id $CID |jq -r  '.data[]|.id'`
do
#echo $EXA_OCID
sleep 5
for db_id in `oci db database list --profile $profile  --compartment-id $CID --db-system-id $EXA_OCID |jq -r '.data[]| .id'`
do

 

 #oci db database get --profile $profile  --database-id $db_id|jq -r '.data|."db-name"+" "+ (."db-backup-config"."auto-backup-enabled"|tostring)+" "+."lifecycle-details"'
 oci db database get --profile $profile  --database-id $db_id|jq -r '.data|."db-name"+" "+  (."db-backup-config"."auto-backup-enabled"|tostring)+ " "+ (."db-backup-config"."auto-backup-window"|tostring)+ " "+ (."db-backup-config"."recovery-window-in-days"|tostring)+  " "+."lifecycle-details"'|xargs echo $profile
 #oci db database get --profile $profile  --database-id $db_id|jq -r '.data[]'
 #oci db database get --profile $profile  --database-id $db_id

 

 

 

done
done
done
done
