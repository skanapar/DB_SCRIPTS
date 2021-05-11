set pagesize 300
set linesize 140
col db_unique_name format a21
col STATUS A10

spool &1
alter session set nls_date_format='dd-mon-yyyy '
/
select all_dbs.db_unique_name, database_role,nvl(backup_end,backup_date) Report_date, ARCHIVELOG_BACKUPS, DATABASE_BACKUPS, status,
        case when nvl(database_backups,0) <1 then '<--***Needs attention ' end Remarks
  from
      (select db_unique_name, backup_date
         from rco.rc_site, (  select rownum -(trunc(sysdate) - trunc(SYSDATE - nvl(&2,1)))+ trunc(sysdate)   backup_date
                                from dba_objects
                          where rownum< 1+&2)
        ) all_dbs,
       (select f.DB_UNIQUE_NAME
              ,f.database_role
              ,trunc(c.end_time) backup_end
              --,g.incremental_level --,c.OUTPUT_DEVICE_TYPE
              --c.session_key --||','||a.db_key --"SESSION_KEY,CDB,CDB_KEY,PDB,PRIMARY_STANDBY,BACKUP_TYPE,INCREMENTAL_LEVEL,OUTPUT,START_DTTM,END_DTTM,STATUS"
              --"CDB,CPRIMARY_STANDBY, BACKUP_DATE,BACKUP_TYPE,INCREMENTAL_LEVEL,OUTPUT,START_DTTM,END_DTTM,STATUS"
              ,sum(decode(c.object_type,'ARCHIVELOG',1,0) ) ARCHIVELOG_BACKUPS
              ,sum(decode(c.object_type,'DB INCR',1,0) ) DATABASE_BACKUPS
              ,c.status
               ,count(*)
              ,(select  listagg(name, '|')  within group (order by name asc) from rco.rc_pdbs b where a.db_key = b.db_key and name <> 'PDB$SEED') PDBS
         from rco.rc_database a,
              rco.rc_rman_status c,
              rco.rc_rman_backup_job_details d,
              rco.rc_rman_backup_subjob_details e,
              rco.rc_site f,
              (select session_key, db_key, backup_type, incremental_level from rco.rc_backup_set_details group by session_key, db_key, backup_type, incremental_level) g
        where  a.db_key = c.db_key
          and a.db_key = g.db_key
          and c.session_key = d.session_key
          and c.session_key = e.session_key
          and c.session_key = g.session_key
          and c.operation = 'BACKUP'
          and c.object_type in ('ARCHIVELOG','DB INCR')
          and c.status NOT LIKE '%RUNNING%'
                    and c.site_key = f.site_key
          and g.backup_type in ('I','L')
          and c.object_type = case when g.backup_type IN ('I') then 'DB INCR' else 'ARCHIVELOG' end
          and c.end_time between   trunc(SYSDATE - nvl(&2,1))  and (sysdate)
          and c.output_device_type='SBT_TAPE'
          group by f.DB_UNIQUE_NAME ,a.db_key ,f.database_role ,trunc(c.end_time) ,c.status
order by  db_unique_name, trunc(c.end_time) desc) backups
where all_dbs.db_unique_name = backups.db_unique_name (+)
and  all_dbs.backup_date = backups.backup_end(+)
order by db_unique_name, Report_date
/
spool off
