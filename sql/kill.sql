select 'Alter System Kill Session '||''''||sid||','||serial#||'''' ||';'
from v$session
where sid = 133;
