set linesize 200
col sql_text for a88
select * from (
select substr(sql_text,1,88) sql_text, count(*)
from v$sql
group by sql_text
order by 2 desc)
where rownum < 5;
