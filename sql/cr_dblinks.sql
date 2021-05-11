select 'create public database link '||name
	||' connect to '||userid
	||' identified by '|| password 
	||' using '''||host
	||''';' 
from link$
--where owner#=1
/

