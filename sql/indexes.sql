set pages 9999
set verify off
select table_owner||'.'||table_name tname , index_name, index_type
from dba_indexes
where owner like nvl('&owner',owner)
--and table_name like nvl('&table_name',table_name)
and table_name in
 ('RPM_ZONE_LOCATION' ,
        'RPM_ZONE' ,
        'RPM_ITEM_ZONE_PRICE' ,
        'ITEM_MASTER' ,
        'ITEM_SUPP_COUNTRY' ,
        'DEPS',
	'GROUPS',
	'STORE',
	'WH')
order by 1,2
/
