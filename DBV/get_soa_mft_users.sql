select listagg(''''||username||'''',',')   within group (order by username)
 from dba_users where oracle_maintained='N'
and username like  'DEV%'
/
