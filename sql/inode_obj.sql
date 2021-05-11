Prompt Objects that are concurrently accessed across more than 1 instance 
set numwidth 8 
column name format a20 tru 
column kind format a10 tru 

select inst_id, name, kind, file#, status, BLOCKS,  
READ_PINGS, WRITE_PINGS 
from (select p.inst_id, p.name, p.kind, p.file#, p.status,  
count(p.block#) BLOCKS, sum(p.forced_reads) READ_PINGS,  
sum(p.forced_writes) WRITE_PINGS 
from gv$ping p, gv$datafile df 
where p.file# = df.file# (+) 
group by p.inst_id, p.name, p.kind, p.file#, p.status 
order by sum(p.forced_writes) desc) 
where rownum < 11 
order by WRITE_PINGS desc;
