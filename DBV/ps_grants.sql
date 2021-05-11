set serveroutput on
begin for rec in( select owner,  object_name, role_to_be_granted.role, privs.priv from
  (select   role
  from dba_roles
  where  (role  like 'PS_%')
  and role not like '%DBA%' 
  and role not like '%OBJ%')  role_to_be_granted,
(select   case when rownum= 1 then 'SELECT'
                                 when rownum =2 then 'INSERT'
                                 when rownum =3 then 'UPDATE'
                                 when rownum=4 then 'DELETE'
                                 end priv
             from dba_tables
             where rownum <5) privs,
(
(SELECT o.*,
             DECODE (s.object_name, NULL, 'REGULAR', 'SECURITY') sec_code
        FROM dba_objects o,
             (SELECT object_name
                FROM dba_objects
               WHERE object_name IN
('PSACCESSLOG', 'PSACCESSPROFILE', 'PSAPMSGDOMSTAT', 'PSAPMSGDSPSTAT', 'PS_CDM_DIST_NODE', 'PS_CDM_TRANSFER', 'PSCERTDB', 'PSCERTDEFN',
'PSCERTISSUER', 'PSCONN', 'PSCONNPROP', 'PS_DAEMONGROUP', 'PSGATEWAY', 'PSIBGATEWAYURLS', 'PSIBLBURLS', 'PSIBLOADBALURL',
'PSIBRTNGDEFN', 'PSIBRTNGSUBDEFN', 'PSIBSVCSETUP', 'PSKEYDB', 'PSMCFRENURLID', 'PSMSGNODEDEFN', 'PSNODECONPROP', 'PSNODEPROP',
'PSNODETRX', 'PSNODEURITEXT', 'PSOBJGROUP', 'PSOPROBJ', 'PSOPTIONS', 'PSPRCSCHLDINFO', 'PS_PRCSSEQUENCE', 'PS_PRCSSYSTEM',
'PS_PT_ERR_RUNCNTL', 'PS_PTPP_OPTIONS', 'PS_PTSF_ATTRS', 'PS_PTSF_AUDIT_DEPO',
'PS_PTSF_AUDIT_SRCE', 'PS_PTSF_CAT_ADVFLD', 'PS_PTSF_CAT_ATTRS', 'PS_PTSF_CATCHLDFCT', 'PS_PTSF_CAT_DSPFLD', 'PS_PTSF_CAT_FACETS', 'PS_PTSF_CAT_LANG',
'PS_PTSF_CAT_PSFTSD', 'PS_PTSF_CATPSFTSDL', 'PS_PTSF_CAT_SES_SD', 'PS_PTSF_CAT_SESSDL', 'PS_PTSF_DEPLOY_OBJ', 'PS_PTSF_DEPLY_PRMS',
'PS_PTSF_DOC_TYPES', 'PS_PTSF_ES_PUBDATA', 'PS_PTSF_FEED_DATA', 'PS_PTSF_INDEX_STAT', 'PS_PTSF_LOG_SDATA', 'PS_PTSF_NODE_ATR_L', 'PS_PTSF_NODE_ATTRS', 'PS_PTSF_OPTN_LOAD', 'PS_PTSF_OPTN_SAVED', 'PS_PTSF_PSFT_SDATR', 'PS_PTSF_SBO',
'PS_PTSF_SBO_ATTR', 'PS_PTSF_SBO_ATTR_H', 'PS_PTSF_SBO_DOCACL', 'PS_PTSF_SBO_DOCATR', 'PS_PTSF_SBO_LANG', 'PS_PTSF_SBO_PNLGRP',
'PS_PTSF_SBO_SCRACL', 'PS_PTSF_SCHED_STAT', 'PS_PTSF_SCHEDU_AET', 'PS_PTSF_SCHEDULE', 'PS_PTSF_SES_ATTR_L', 'PS_PTSF_SES_ATTRS', 'PS_PTSF_SES_FACTS',
'PS_PTSF_SES_SD_ATR', 'PS_PTSF_SRCHCAT', 'PS_PTSF_SRCHCATATR', 'PS_PTSF_SRCH_ENGN', 'PS_PTSF_SRCH_NODES', 'PS_PTSF_STAT_ARCH',
'PS_PTSF_URLDEFN', 'PS_PTSF_USER_INST', 'PSPTTSTLOG_IMG', 'PSPTTSTLOG_LIST', 'PSPTTSTLOG_LNS', 'PSPTTSTLOG_OPTS', 'PSPTTSTLOG_XTRA',
'PSREN', 'PSRENCLUS_OWNER', 'PSRENCLUSTER', 'PSRF_FLIST_TBL', 'PSRTNGDFNCONPRP', 'PSRTNGDFNPARM', 'PS_RUN_LOADCACHE', 'PS_SERVERACTVTY',
'PS_SERVERCATEGORY', 'PS_SERVERCLASS', 'PS_SERVERDEFN', 'PS_SERVERMESSAGE', 'PS_SERVERNOTIFY', 'PS_SERVEROPRTN', 'PS_SERVERPURGLIST',
'PSSERVERSTAT', 'PSTRUSTNODES', 'PSWEBPROFBROW', 'PSWEBPROFCOOK', 'PSWEBPROFDEF', 'PSWEBPROFHIST',
'PSWEBPROFILE', 'PSWEBPROFNVP', 'PTPPB_ADMN_PRMS', 'PTPPB_DISP_PRMS', 'PTPPB_DISP_VALS', 'PTPPB_DS_SETTGS',
'PTPPB_LINKPARMS', 'PTPPB_LINKPATHS', 'PTPPB_PAGELET', 'PTPPB_PARM_VALS', 'PTPPB_PGLT_HTML', 'PTPPB_PGLT_LANG', 'PTPPB_PGLT_PRMS', 'PTPPB_PGLT_URL',
'PTPPB_PRMS_LANG', 'PTPPB_PVAL_LANG', 'PTPPB_SECURITY', 'PTPPB_SOAP_REQ', 'PTPPB_THRESHOLD', 'PTPPB_TRSH_LANG',
'PTPPB_TRSH_VAL', 'PTSF_SBO', 'PTSF_SBO_ATTR', 'PTSF_SBO_ATTR_H', 'PTSF_SCHEDULE', 'PTSF_SRCHCATATR', 'PTSF_SRCH_ENGN', '')
                     AND object_type IN ('TABLE', 'VIEW') and owner='SYSADM') s
       WHERE     o.object_name = s.object_name(+)
             AND o.object_type IN ('TABLE', 'VIEW')
             AND o.status <> 'INVALID'
             AND owner IN ('SYSADM')) ) o
          where      
          ( case when (sec_code = 'SECURITY'  or object_type ='VIEW' )   and  priv <> 'SELECT' THEN 'N' ELSE 'Y' END = 'Y'
          and         
            CASE WHEN role_to_be_granted.role like '%READ'  and priv<>  'SELECT' THEN 'N' ELSE 'Y' END = 'Y')
          minus
          select T.owner, t.table_name, t.grantee, t.privilege
          from dba_tab_privs t)
loop
begin
execute immediate 'grant '|| rec.priv || ' on '|| rec.owner||'.'||  rec.object_name||' to '|| rec.role; 
exception 
when others then 
dbms_output.put_line('grant '|| rec.priv || ' on '|| rec.owner||'.'||  rec.object_name||' to '|| rec.role);
end;
end loop;
end;
/
