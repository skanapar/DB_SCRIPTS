column username format a10
column sid format 999
column lock_type format a15
column MODE_HELD format a11
column MODE_REQUESTED format a10
column LOCK_ID1 format a8
column LOCK_ID2 format a8
 select a.sid,
   decode(a.type,
   'MR', 'Media Recovery',
   'RT', 'Redo Thread',
   'UN', 'User Name',
   'TX', 'Transaction',
   'TM', 'DML',
   'UL', 'PL/SQL User Lock',
   'DX', 'Distributed Xaction',
   'CF', 'Control File',
   'IS', 'Instance State',
   'FS', 'File Set',
   'IR', 'Instance Recovery',
   'ST', 'Disk Space Transaction',
   'IR', 'Instance Recovery',
   'ST', 'Disk Space Transaction',
   'TS', 'Temp Segment',
   'IV', 'Library Cache Invalidation',
   'LS', 'Log Start or Switch',
   'RW', 'Row Wait',
   'SQ', 'Sequence Number',
   'TE', 'Extend Table',
   'TT', 'Temp Table',
   a.type) lock_type,
   decode(a.lmode,
   0, 'None',           /* Mon Lock equivalent */
   1, 'Null',           /* N */
   2, 'Row-S (SS)',     /* L */
   3, 'Row-X (SX)',     /* R */
   4, 'Share',          /* S */
   5, 'S/Row-X (SSX)',  /* C */
   6, 'Exclusive',      /* X */
   to_char(a.lmode)) mode_held,
   decode(a.request,
   0, 'None',           /* Mon Lock equivalent */
   1, 'Null',           /* N */
   2, 'Row-S (SS)',     /* L */
   3, 'Row-X (SX)',     /* R */
   4, 'Share',          /* S */
   5, 'S/Row-X (SSX)',  /* C */
   6, 'Exclusive',      /* X */
    to_char(a.request)) mode_requested,
   to_char(a.id1) lock_id1, to_char(a.id2) lock_id2
from v$lock a
   where (id1,id2) in
     (select b.id1, b.id2 from v$lock b where b.id1=a.id1 and
     b.id2=a.id2 and b.request>0);



