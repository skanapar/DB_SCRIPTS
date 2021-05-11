select country,count(*)
from wwex.addressbook
group by country
order by 1
/
