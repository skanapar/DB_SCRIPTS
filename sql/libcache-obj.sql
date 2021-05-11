col name format a50
col cursor format a12 noprint
col type format a7
col LOCKED_TOTAL heading Locked format 99999999
col PINNED_TOTAL heading Pinned format 99999999
col EXECUTIONS heading Executed format 99999999
col NAMESPACE heading Nsp format 999
set wrap on
set linesize 160
select * from (
   select case when (kglhdadr =  kglhdpar) then 'Parent' else 'Child '||kglobt09 end cursor,
             kglhdadr ADDRESS,substr(kglnaobj,1,50) name, kglnahsh hash_value,kglobtyd type,kglobt23 LOCKED_TOTAL,kglobt24 PINNED_TOTAL,kglhdexc EXECUTIONS,kglhdnsp NAMESPACE 
               from x$kglob  
               order by kglobt24 desc)
where rownum <= 10;
