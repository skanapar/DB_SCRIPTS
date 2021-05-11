break on hash_value
select hash_value, sql_text
from stats$sqltext
where hash_value = nvl('&hash_value',hash_value)
order by hash_value, piece
/
