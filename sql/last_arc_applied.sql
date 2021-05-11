select thread#,sequence#,applied,count(*), max((sysdate-completion_time)*24*60) minutes_ago 
from v$archived_log 
where applied<>'YES'
and dest_id=2
group by thread#,sequence#, applied
order by minutes_ago
/
