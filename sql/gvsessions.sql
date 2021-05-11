set lines 132 pages 100
break on inst_id skip 1
compute sum of active on inst_id
compute sum of total on inst_id
col inst_id for 99
col machine for a40
select inst_id,machine,active+inactive total,active from ( select inst_id,machine,max(decode(status,'ACTIVE',total,0)) ACTIVE,max(decode(status,'INACTIVE',total,0)) INACTIVE from( select inst_id,nvl(machine,'BACKGROUND') machine,status,count(*) Total 
from gv$session group by inst_id,nvl(machine,'BACKGROUND'),status
)
group by inst_id,machine
)
order by inst_id,total,active
/
