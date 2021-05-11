set line 125
column TABLE_NAME format a20
column CONST_NAME format a20
column C_TYPE format a6
column REF_TABLE format a20
column REF_CONST format a20
column R_TYPE format a6
select 
a.table_name TABLE_NAME, a.constraint_name CONST_NAME, a.constraint_type C_TYPE,
b.table_name REF_TABLE, b.constraint_name REF_CONST, b.constraint_type R_TYPE
from dba_constraints a, dba_constraints b
where a.r_constraint_name = b.constraint_name
and ( a.owner='&user' or b.owner='&user' )
order by a.table_name, a.constraint_type
/
