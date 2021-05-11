SELECT a.name,a.ptime Last_Changed,a.con_id from containers(sys.user$) a, cdb_users b where a.name=b.username and a.con_id=b.con_id order by 3,1
/
