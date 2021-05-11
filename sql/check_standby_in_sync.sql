select case when scn_to_timestamp(current_scn)>= to_date('&1', 'YYYYMMDD_HH24MISS') then 'Y'||'ES' 
      else 'N'||'O' end stdby_sync_status
 from v$database
/

