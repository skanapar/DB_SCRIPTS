set linesize 120
column interval format 999999999999
column "Minutes Behind" format 99999999.99
column "master link" format a20
column "mview owner" format a10
column next_date format a20

SELECT mv.owner as "mview owner",
mv.mview_name as "mview name",
mv.master_link as "master link",
1440*(sysdate - mv.last_refresh_date) as "Minutes Behind",
int.next_date,
int.interval
FROM dba_mviews mv,
(
 SELECT child.owner,
 child.name,
 job.next_date,
 job.next_date - job.last_date as interval
 FROM dba_refresh ref,
 dba_refresh_children child,
 dba_jobs job
 WHERE ref.rname = child.rname
 AND ((upper(job.what) LIKE '%'||ref.rname||'%')
      OR (upper(job.what) LIKE '%'||ref.rname||'%'))
) int
WHERE mv.owner = int.owner(+)
AND mv.mview_name = int.name(+)
AND mv.refresh_method = 'FAST'
ORDER BY (sysdate - mv.last_refresh_date) * 1440 DESC, mv.owner, mv.mview_name;