set linesize 132
REM set pagesize 66
break on Kill on username on terminal
column Kill heading 'Kill String' format a13
column res heading 'Resource Type' format 999
column id1 format 9999990
column id2 format 9999990
column lmode heading 'Lock Held' format a20
column request heading 'Lock Requested' format a20
column serial# format 99999
column username  format a10  heading "Username"
column terminal heading Term format a6
column tab format a35 heading "Table Name"
column owner format a9
column Address format a18
select  nvl(S.USERNAME,'Internal') username,
        nvl(S.TERMINAL,'None') terminal,
        L.SID||','||S.SERIAL# Kill,
        U1.NAME||'.'||substr(T1.NAME,1,20) tab,
        decode(L.LMODE,1,'No Lock',
                2,'Row Share',
                3,'Row Exclusive',
                4,'Share',
                5,'Share Row Exclusive',
                6,'Exclusive',null) lmode,
        decode(L.REQUEST,1,'No Lock',
                2,'Row Share',
                3,'Row Exclusive',
                4,'Share',
                5,'Share Row Exclusive',
                6,'Exclusive',null) request
from    V$LOCK L,
        V$SESSION S,
        SYS.USER$ U1,
        SYS.OBJ$ T1
where   L.SID = S.SID
and     T1.OBJ# = decode(L.ID2,0,L.ID1,L.ID2)
and     U1.USER# = T1.OWNER#
and     S.TYPE != 'BACKGROUND'
order by 1,2,5
/
