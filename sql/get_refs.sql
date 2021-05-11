select 'alter constraint '||b.constraint_name||' disable;'
from all_constraints a, all_constraints b
where a.constraint_name = b.R_CONSTRAINT_NAME
and a.table_name = 'EMPLOYEE'
and b.constraint_type='R'
/
