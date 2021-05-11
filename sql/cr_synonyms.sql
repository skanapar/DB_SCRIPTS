select object_type||'  '||'create synonym '||object_name||' for onecall_cen.'||object_name||';'
from dba_objects where owner='ONECALL_CEN'
order by object_type
/
