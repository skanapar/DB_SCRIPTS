select statistic_name, count(*) 
from v$segment_statistics
group by statistic_name
order by 2
/
