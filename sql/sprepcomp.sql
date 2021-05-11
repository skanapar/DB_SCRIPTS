--Script: sprepcomp.sql
--Author: Tie Peng
--Date: Feb 6, 2006
--Purpose: compare two statspack reports, and give the differences on load profile, top 5 events and SQL order by executions and physical reads, and tablespace IO stats.
--Courtesy: Oracle statspack report scripts.

column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column inst_name heading "Instance"  new_value inst_name format a12;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;

prompt
prompt Current Instance
prompt ~~~~~~~~~~~~~~~~

select d.dbid            dbid
     , d.name            db_name
     , i.instance_number inst_num
     , i.instance_name   inst_name
  from v$database d,
       v$instance i;

clear break compute;
repfooter off;
ttitle off;
btitle off;
set timing off veri off space 1 flush on pause off termout on numwidth 10;
set echo off feedback off pagesize 10000 linesize 125 newpage 1 recsep off;
set trimspool on trimout on;
define top_n_events = 5;
define top_n_sql = 65;
define top_n_segstat = 5;
define num_rows_per_hash=5;


--
-- Request the DB Id and Instance Number, if they are not specified

column instt_num  heading "Inst Num"  format 99999;
column instt_name heading "Instance"  format a12;
column dbb_name   heading "DB Name"   format a12;
column dbbid      heading "DB Id"     format 9999999999 just c;
column host       heading "Host"      format a12;

prompt
prompt
prompt Instances in this Statspack schema
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select distinct 
       dbid            dbbid
     , instance_number instt_num
     , db_name         dbb_name
     , instance_name   instt_name
     , host_name       host
  from stats$database_instance;

prompt
prompt Using &&dbid for database Id
prompt Using &&inst_num for instance number


--
--  Set up the binds for dbid and instance_number

variable dbid       number;
variable inst_num   number;
begin
  :dbid      :=  &dbid;
  :inst_num  :=  &inst_num;
end;
/


--
--  Ask for the snapshots Id's which are to be compared

set termout on;
column instart_fmt noprint;
column inst_name   format a12  heading 'Instance';
column db_name     format a12  heading 'DB Name';
column snap_id     format 999990 heading 'Snap|Id';
column snapdat     format a17  heading 'Snap Started' just c;
column lvl         format 99   heading 'Snap|Level';
column commnt      format a22  heading 'Comment';

break on inst_name on db_name on host on instart_fmt skip 1;

ttitle lef 'Completed Snapshots' skip 2;

select to_char(s.startup_time,' dd Mon "at" HH24:mi:ss') instart_fmt
     , di.instance_name                                  inst_name
     , di.db_name                                        db_name
     , s.snap_id                                         snap_id
     , to_char(s.snap_time,'dd Mon YYYY HH24:mi')        snapdat
     , s.snap_level                                      lvl
     , substr(s.ucomment, 1,60)                          commnt
  from stats$snapshot s
     , stats$database_instance di
 where s.dbid              = :dbid
   and di.dbid             = :dbid
   and s.instance_number   = :inst_num
   and di.instance_number  = :inst_num
   and di.dbid             = s.dbid
   and di.instance_number  = s.instance_number
   and di.startup_time     = s.startup_time
 order by db_name, instance_name, snap_id;

clear break;
ttitle off;


prompt
prompt
prompt Specify the Begin and End Snapshot Ids
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt enter begin and end snapshot id for report 1:
accept 1 char prompt 'Begin Snapshot Id specified: '
accept 2 char prompt 'End   Snapshot Id specified: '
prompt
prompt enter begin and end snapshot id for report 2:
accept 3 char prompt 'Begin Snapshot Id specified: '
accept 4 char prompt 'End   Snapshot Id specified: '


--
--  Set up the snapshot-related binds, and additional instance info

set termout off;

variable bid1        number;
variable eid1        number;
variable bid2	   number;
variable eid2        number;
begin
  :bid1       :=  &1;
  :eid1       :=  &2;
  :bid2       :=  &3;
  :eid2       :=  &4;
end;
/

column para       new_value para;
column versn      new_value versn;
column host_name  new_value host_name;
column db_name    new_value db_name;
column inst_name  new_value inst_name;
column btime      new_value btime;
column etime      new_value etime;
col btime1 new_value btime1
col etime1 new_value etime1
col btime2 new_value btime2
col etime2 new_value etime2

select parallel       para
     , version        versn
     , host_name      host_name
     , db_name        db_name
     , instance_name  inst_name
     , to_char(snap_time, 'YYYYMMDD HH24:MI:SS')  btime
     ,to_char(snap_time, 'YYYYMMDD HH24:MI:SS')  btime1
  from stats$database_instance di
     , stats$snapshot          s
 where s.snap_id          = :bid1
   and s.dbid             = :dbid
   and s.instance_number  = :inst_num
   and di.dbid            = s.dbid
   and di.instance_number = s.instance_number
   and di.startup_time    = s.startup_time;

select to_char(snap_time, 'YYYYMMDD HH24:MI:SS')  etime,to_char(snap_time, 'YYYYMMDD HH24:MI:SS')  etime1
  from stats$snapshot     s
 where s.snap_id          = :eid1
   and s.dbid             = :dbid
   and s.instance_number  = :inst_num;
select to_char(snap_time, 'YYYYMMDD HH24:MI:SS')  btime2
  from stats$snapshot     s
 where s.snap_id          = :bid2
   and s.dbid             = :dbid
   and s.instance_number  = :inst_num;
select to_char(snap_time, 'YYYYMMDD HH24:MI:SS')  etime2
  from stats$snapshot     s
 where s.snap_id          = :eid2
   and s.dbid             = :dbid
   and s.instance_number  = :inst_num;

variable para       varchar2(9);
variable versn      varchar2(10);
variable host_name  varchar2(64);
variable db_name    varchar2(20);
variable inst_name  varchar2(20);
variable btime      varchar2(25);
variable etime      varchar2(25);
begin
  :para      := '&para';
  :versn     := '&versn';
  :host_name := '&host_name';
  :db_name   := '&db_name';
  :inst_name := '&inst_name';
  :btime     := '&btime';
  :etime     := '&etime';
end;
/

set termout on;

--
--  Call statspack to calculate certain statistics
-- for report 1
variable lhtr1   number;
variable bfwt1   number;
variable tran1   number;
variable chng1   number;
variable ucal1   number;
variable urol1   number;
variable ucom1   number;
variable rsiz1   number;
variable phyr1   number;
variable phyrd1  number;
variable phyrdl1 number;
variable phyw1   number;
variable prse1   number;
variable hprs1   number;
variable recr1   number;
variable gets1   number;
variable rlsr1   number;
variable rent1   number;
variable srtm1   number;
variable srtd1   number;
variable srtr1   number;
variable strn1   number;
variable call1   number;
variable lhr1    number;
variable sp1     varchar2(512);
variable bc1     varchar2(512);
variable lb1     varchar2(512);
variable bs1     varchar2(512);
variable twt1    number;
variable logc1   number;
variable prscpu1 number;
variable prsela1 number;
variable tcpu1   number;
variable exe1    number;
variable bspm1   number;
variable espm1   number;
variable bfrm1   number;
variable efrm1   number;
variable blog1   number;
variable elog1   number;
variable bocur1  number;
variable eocur1  number;
variable dmsd1   number;
variable dmfc1   number;
variable dmsi1   number;
variable pmrv1   number;
variable pmpt1   number;
variable npmrv1   number;
variable npmpt1   number;
variable dbfr1   number;
variable dpms1   number;
variable dnpms1   number;
variable glsg1   number;
variable glag1   number;
variable glgt1   number;
variable glsc1   number;
variable glac1   number;
variable glct1   number;
variable glrl1   number;
variable gcdfr1  number;
variable gcge1   number;
variable gcgt1   number;
variable gccv1   number;
variable gcct1   number;
variable gccrrv1   number;
variable gccrrt1   number;
variable gccurv1   number;
variable gccurt1   number;
variable gccrsv1   number;
variable gccrbt1   number;
variable gccrft1   number;
variable gccrst1   number;
variable gccusv1   number;
variable gccupt1   number;
variable gccuft1   number;
variable gccust1   number;
variable msgsq1    number;
variable msgsqt1   number;
variable msgsqk1   number;
variable msgsqtk1  number;
variable msgrq1    number;
variable msgrqt1   number;

begin
  STATSPACK.STAT_CHANGES
   ( :bid1,    :eid1
   , :dbid,   :inst_num
   , :para                 -- End of IN arguments
   , :lhtr1,   :bfwt1
   , :tran1,   :chng1
   , :ucal1,   :urol1
   , :rsiz1
   , :phyr1,   :phyrd1
   , :phyrdl1
   , :phyw1,   :ucom1
   , :prse1,   :hprs1
   , :recr1,   :gets1
   , :rlsr1,   :rent1
   , :srtm1,   :srtd1
   , :srtr1,   :strn1
   , :lhr1,    :bc1
   , :sp1,     :lb1
   , :bs1,     :twt1
   , :logc1,   :prscpu1
   , :tcpu1,   :exe1
   , :prsela1
   , :bspm1,   :espm1
   , :bfrm1, :efrm1
   , :blog1,   :elog1
   , :bocur1,  :eocur1
   , :dmsd1,   :dmfc1    -- Begin of RAC
   , :dmsi1
   , :pmrv1,   :pmpt1 
   , :npmrv1,  :npmpt1 
   , :dbfr1
   , :dpms1,   :dnpms1 
   , :glsg1,   :glag1 
   , :glgt1,   :glsc1 
   , :glac1,   :glct1 
   , :glrl1,   :gcdfr1
   , :gcge1,   :gcgt1 
   , :gccv1,   :gcct1
   , :gccrrv1, :gccrrt1 
   , :gccurv1, :gccurt1 
   , :gccrsv1
   , :gccrbt1, :gccrft1 
   , :gccrst1, :gccusv1 
   , :gccupt1, :gccuft1 
   , :gccust1
   , :msgsq1,  :msgsqt1
   , :msgsqk1, :msgsqtk1
   , :msgrq1,  :msgrqt1           -- End RAC
   );
   :call1 := :ucal1 + :recr1;
end;
/

--for report 2
variable lhtr2   number;
variable bfwt2   number;
variable tran2   number;
variable chng2   number;
variable ucal2   number;
variable urol2   number;
variable ucom2   number;
variable rsiz2   number;
variable phyr2   number;
variable phyrd2  number;
variable phyrdl2 number;
variable phyw2   number;
variable prse2   number;
variable hprs2   number;
variable recr2   number;
variable gets2   number;
variable rlsr2   number;
variable rent2   number;
variable srtm2   number;
variable srtd2   number;
variable srtr2   number;
variable strn2   number;
variable call2   number;
variable lhr2    number;
variable sp2     varchar2(512);
variable bc2     varchar2(512);
variable lb2     varchar2(512);
variable bs2     varchar2(512);
variable twt2    number;
variable logc2   number;
variable prscpu2 number;
variable prsela2 number;
variable tcpu2   number;
variable exe2    number;
variable bspm2   number;
variable espm2   number;
variable bfrm2   number;
variable efrm2   number;
variable blog2   number;
variable elog2   number;
variable bocur2  number;
variable eocur2  number;
variable dmsd2   number;
variable dmfc2   number;
variable dmsi2   number;
variable pmrv2   number;
variable pmpt2   number;
variable npmrv2   number;
variable npmpt2   number;
variable dbfr2   number;
variable dpms2   number;
variable dnpms2   number;
variable glsg2   number;
variable glag2   number;
variable glgt2   number;
variable glsc2   number;
variable glac2   number;
variable glct2   number;
variable glrl2   number;
variable gcdfr2  number;
variable gcge2   number;
variable gcgt2   number;
variable gccv2   number;
variable gcct2   number;
variable gccrrv2   number;
variable gccrrt2   number;
variable gccurv2   number;
variable gccurt2   number;
variable gccrsv2   number;
variable gccrbt2   number;
variable gccrft2   number;
variable gccrst2   number;
variable gccusv2   number;
variable gccupt2   number;
variable gccuft2   number;
variable gccust2   number;
variable msgsq2    number;
variable msgsqt2   number;
variable msgsqk2   number;
variable msgsqtk2  number;
variable msgrq2    number;
variable msgrqt2   number;

begin
  STATSPACK.STAT_CHANGES
   ( :bid2,    :eid2
   , :dbid,   :inst_num
   , :para                 -- End of IN arguments
   , :lhtr2,   :bfwt2
   , :tran2,   :chng2
   , :ucal2,   :urol2
   , :rsiz2
   , :phyr2,   :phyrd2
   , :phyrdl2
   , :phyw2,   :ucom2
   , :prse2,   :hprs2
   , :recr2,   :gets2
   , :rlsr2,   :rent2
   , :srtm2,   :srtd2
   , :srtr2,   :strn2
   , :lhr2,    :bc2
   , :sp2,     :lb2
   , :bs2,     :twt2
   , :logc2,   :prscpu2
   , :tcpu2,   :exe2
   , :prsela2
   , :bspm2,   :espm2
   , :bfrm2, :efrm2
   , :blog2,   :elog2
   , :bocur2,  :eocur2
   , :dmsd2,   :dmfc2    -- Begin of RAC
   , :dmsi2
   , :pmrv2,   :pmpt2 
   , :npmrv2,  :npmpt2 
   , :dbfr2
   , :dpms2,   :dnpms2 
   , :glsg2,   :glag2 
   , :glgt2,   :glsc2 
   , :glac2,   :glct2 
   , :glrl2,   :gcdfr2
   , :gcge2,   :gcgt2 
   , :gccv2,   :gcct2
   , :gccrrv2, :gccrrt2 
   , :gccurv2, :gccurt2 
   , :gccrsv2
   , :gccrbt2, :gccrft2 
   , :gccrst2, :gccusv2 
   , :gccupt2, :gccuft2 
   , :gccust2
   , :msgsq2,  :msgsqt2
   , :msgsqk2, :msgsqtk2
   , :msgrq2,  :msgrqt2           -- End RAC
   );
   :call2 := :ucal2 + :recr2;
end;
/

column ela1        new_value ELA1     noprint;
column ela2        new_value ELA2     noprint;
select round(((e.snap_time - b.snap_time) * 1440 * 60), 0) ela1  -- secs
 from stats$snapshot b
     , stats$snapshot e
 where b.snap_id         = :bid1
   and e.snap_id         = :eid1
   and b.dbid            = :dbid
   and e.dbid            = :dbid
   and b.instance_number = :inst_num
   and e.instance_number = :inst_num
   and b.startup_time    = e.startup_time
   and b.snap_time       < e.snap_time;
select round(((e.snap_time - b.snap_time) * 1440 * 60), 0) ela2  -- secs
 from stats$snapshot b
     , stats$snapshot e
 where b.snap_id         = :bid2
   and e.snap_id         = :eid2
   and b.dbid            = :dbid
   and e.dbid            = :dbid
   and b.instance_number = :inst_num
   and e.instance_number = :inst_num
   and b.startup_time    = e.startup_time
   and b.snap_time       < e.snap_time;
variable ela1     number;
variable ela2 number;
begin
   :ela1     :=  &ela1;
   :ela2     :=  &ela2;
end;
/

set heading on;

--
--  Load Profile
set heading off feedback off
column dscr     format a28 newline;
column val      format 9,999,999,999,990.99;
column sval     format 99,990.99;
column svaln    format 99,990.99 newline;
column totcalls new_value totcalls noprint
column pctval   format 990.99;
column bpctval  format 9990.99;
col reportname new_value reportname noprint
select '/home/oracle/dbscripts/log/sp_comp_'||:bid1||'_'||:eid1||'_'||:bid2||'_'||:eid2||'.lst' reportname from dual;
spool &reportname
ttitle center 'STATSPACK REPORT COMPARISON' skip 2 -
       center 'Report1: begin_snapid: ' 1 ' ' btime1 ' end_snapid: ' 2 ' ' etime1 skip -
       center 'Report2: begin_snapid: ' 3 ' ' btime2 ' end_snapid: ' 4 ' ' etime2 skip 3

select 'Load Profile                                     Per Second'
      ,'~~~~~~~~~~~~                            Report1              Report2'
      ,'                                   ---------------       ---------------'
      ,'                  Redo size:' dscr, round(:rsiz1/:ela1,2)  val
                                          , round(:rsiz2/:ela2,2) val
      ,'              Logical reads:' dscr, round(:gets1/:ela1,2)  val
                                          , round(:gets2/:ela2,2) val
      ,'              Block changes:' dscr, round(:chng1/:ela1,2)  val
                                          , round(:chng2/:ela2,2) val
      ,'             Physical reads:' dscr, round(:phyr1/:ela1,2)  val
                                          , round(:phyr2/:ela2,2) val
      ,'            Physical writes:' dscr, round(:phyw1/:ela1,2)  val
                                          , round(:phyw2/:ela2,2) val
      ,'                 User calls:' dscr, round(:ucal1/:ela1,2)  val
                                          , round(:ucal2/:ela2,2) val
      ,'                     Parses:' dscr, round(:prse1/:ela1,2)  val
                                          , round(:prse2/:ela2,2) val
      ,'                Hard parses:' dscr, round(:hprs1/:ela1,2)  val
                                          , round(:hprs2/:ela2,2) val
      ,'                      Sorts:' dscr, round((:srtm1+:srtd1)/:ela1,2)  val
                                          , round((:srtm2+:srtd2)/:ela2,2) val
      ,'                     Logons:' dscr, round(:logc1/:ela1,2)  val
                                          , round(:logc2/:ela2,2) val
      ,'                   Executes:' dscr, round(:exe1/:ela1,2)   val
                                          , round(:exe2/:ela2,2)  val
      ,'               Transactions:' dscr, round(:tran1/:ela1,2)  val
							, round(:tran2/:ela2,2) val
 from sys.dual;
ttitle off;

prompt
set heading on
--
--  Top Wait Events

col idle     noprint;
col event    format a30          heading 'Top 5 Timed Events|~~~~~~~~~~~~~~~~~~|Event';
col waits1    format 999,999,990  heading 'Waits';
col time1     format 99,999,990   heading 'Report1|       |Time (s)';
col pctwtt1   format 999.99       heading '% Total|Ela Time';
col waits2    format 999,999,990  heading 'Waits';
col time2     format 99,999,990   heading 'Report2|       |Time (s)';
col pctwtt2   format 999.99       heading '% Total|Ela Time';

select report2.event event,waits1,time1,pctwtt1,waits2,time2,pctwtt2
  from (select * from (select event, waits2, time2, pctwtt2
          from (select e.event                               event
                     , e.total_waits - nvl(b.total_waits,0)  waits2
                     , (e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000  time2
                     , decode(:twt2 + :tcpu2*10000, 0, 0,
                                100
                              * (e.time_waited_micro - nvl(b.time_waited_micro,0))
                              / (:twt2 + :tcpu2*10000)                        
                              )                              pctwtt2
                 from stats$system_event b
                    , stats$system_event e
                where b.snap_id(+)          = :bid2
                  and e.snap_id             = :eid2
                  and b.dbid(+)             = :dbid
                  and e.dbid                = :dbid
                  and b.instance_number(+)  = :inst_num
                  and e.instance_number     = :inst_num
                  and b.event(+)            = e.event
                  and e.total_waits         > nvl(b.total_waits,0)
                  and e.event not in (select event from stats$idle_event)
               union all
               select 'CPU time'                              event
                    , to_number(null)                         waits2
                    , :tcpu2/100                               time2
                    , decode(:twt2 + :tcpu2*10000, 0, 0,
                               100
                             * :tcpu2*10000 
                             / (:twt2 + :tcpu2*10000)
                            )                                 pctwait2
                 from dual
                where :tcpu2 > 0
               )
         order by time2 desc, waits2 desc)
 where rownum <= &&top_n_events) report2,
 (select e.event                               event
                     , e.total_waits - nvl(b.total_waits,0)  waits1
                     , (e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000  time1
                     , decode(:twt1 + :tcpu1*10000, 0, 0,
                                100
                              * (e.time_waited_micro - nvl(b.time_waited_micro,0))
                              / (:twt1 + :tcpu1*10000)                        
                              )                              pctwtt1
                 from stats$system_event b
                    , stats$system_event e
                where b.snap_id(+)          = :bid1
                  and e.snap_id             = :eid1
                  and b.dbid(+)             = :dbid
                  and e.dbid                = :dbid
                  and b.instance_number(+)  = :inst_num
                  and e.instance_number     = :inst_num
                  and b.event(+)            = e.event
                  and e.total_waits         > nvl(b.total_waits,0)
                  and e.event not in (select event from stats$idle_event)
               union all
               select 'CPU time'                              event
                    , to_number(null)                         waits1
                    , :tcpu1/100                               time1
                    , decode(:twt1 + :tcpu1*10000, 0, 0,
                               100
                             * :tcpu1*10000 
		 	     / (:twt1 + :tcpu1*10000)
                            )                                 pctwait1
                 from dual
                where :tcpu1 > 0) report1
where report1.event(+)=report2.event
order by time2 desc,waits2 desc;
ttitle off
prompt

--
--  SQL statements ordered by physical reads
set underline off
ttitle lef 'SQL ordered by Physical Reads' skip 2
col aa format a99 heading -
'                               Report1                                 Report2| Hashvalue Physical_Reads   Executions  Reads_per_Exec  Physical_Reads  Executions  Reads_per_Exec|---------- --------------- ------------ -------------- --------------- ------------ --------------' 
col hv noprint
break on hv skip 1
select decode(report2.piece,0,lpad(report2.hash_value,10)||' '||
       lpad(to_char(disk_reads1,'99,999,999,999'),15)||' '||
       lpad(to_char(executions1,'999,999,999'),12)||' '||
       lpad(to_char(readsperexec1,'999,999,990.0'),14)||' '||
       lpad(to_char(disk_reads2,'99,999,999,999'),15)||' '||
       lpad(to_char(executions2,'999,999,999'),12)||' '||
       lpad(to_char(readsperexec2,'999,999,990.0'),14)||' '||
       decode(report2.module,null,report2.sql_text,rpad('Module: '||report2.module,99)||report2.sql_text),report2.sql_text) aa, report2.hash_value hv
from 
(select * from 
 (select /*+ ordered use_nl (b st) */
  st.piece piece,e.disk_reads - nvl(b.disk_reads,0) disk_reads2,e.executions - nvl(b.executions,0) executions2,
  decode(e.executions - nvl(b.executions,0),0, to_number(null),
         (e.disk_reads - nvl(b.disk_reads,0)) /(e.executions - nvl(b.executions,0))) readsperexec2,
  e.hash_value hash_value,e.module module,st.sql_text sql_text
  from stats$sql_summary e
     , stats$sql_summary b
     , stats$sqltext     st 
      where b.snap_id(+)         = :bid2
        and b.dbid(+)            = e.dbid
        and b.instance_number(+) = e.instance_number
        and b.hash_value(+)      = e.hash_value
        and b.address(+)         = e.address
        and b.text_subset(+)     = e.text_subset
        and e.snap_id            = :eid2
        and e.dbid               = :dbid
        and e.instance_number    = :inst_num
        and e.hash_value         = st.hash_value 
        and e.text_subset        = st.text_subset
        and st.piece             < &&num_rows_per_hash
        and e.executions         > nvl(b.executions,0)
        and :phyr2                > 0
      order by (e.disk_reads - nvl(b.disk_reads,0)) desc, e.hash_value, st.piece
      )
where rownum < &&top_n_sql) report2,
 (select /*+ ordered use_nl (b st) */
  st.piece piece,e.disk_reads - nvl(b.disk_reads,0) disk_reads1,e.executions - nvl(b.executions,0) executions1,
  decode(e.executions - nvl(b.executions,0),0, to_number(null),
         (e.disk_reads - nvl(b.disk_reads,0)) /(e.executions - nvl(b.executions,0))) readsperexec1,
  e.hash_value hash_value,e.module module,st.sql_text sql_text
  from stats$sql_summary e
     , stats$sql_summary b
     , stats$sqltext     st 
      where b.snap_id(+)         = :bid1
        and b.dbid(+)            = e.dbid
        and b.instance_number(+) = e.instance_number
        and b.hash_value(+)      = e.hash_value
        and b.address(+)         = e.address
        and b.text_subset(+)     = e.text_subset
        and e.snap_id            = :eid1
        and e.dbid               = :dbid
        and e.instance_number    = :inst_num
        and e.hash_value         = st.hash_value 
        and e.text_subset        = st.text_subset
        and st.piece             < &&num_rows_per_hash
        and e.executions         > nvl(b.executions,0)
        and :phyr1                > 0
      order by (e.disk_reads - nvl(b.disk_reads,0)) desc, e.hash_value, st.piece
      ) report1
where report2.hash_value=report1.hash_value and report2.piece=report1.piece
order by disk_reads2 desc,report2.hash_value,report2.piece;
ttitle off

--
--  SQL statements ordered by executions
prompt
ttitle lef 'SQL ordered by Executions' skip 2 
col aa format a103 heading -
'                                  Report1                                 Report2| Hashvalue   Executions  Rows_Processed   Rows_per_Exec   Executions  Rows_Processed   Rows_per_Exec|---------- ------------ --------------- ---------------- ------------ --------------- ----------------'
col hv noprint
break on hv skip 1
select decode( report2.piece
                , 0
                , lpad(report2.hash_value,10)||' '||
                  lpad(to_char(executions1,'999,999,999'),12)||' '||
                  lpad(to_char(rows_processed1,'99,999,999,999'),15)||' '||
                  lpad(to_char(rowsperexec1,'9,999,999,990.0'),16) ||' '||
       		  lpad(to_char(executions2,'999,999,999'),12)||' '||
                  lpad(to_char(rows_processed2,'99,999,999,999'),15)||' '||
                  lpad(to_char(rowsperexec2,'9,999,999,990.0'),16) ||' '||
                  decode(report2.module,null,report2.sql_text,rpad('Module: '||report2.module,103)||report2.sql_text)
                , report2.sql_text) aa, report2.hash_value hv
from
(select * from
  (select /*+ ordered use_nl (b st) */
     st.piece piece,(e.executions - nvl(b.executions,0)) executions2,
     (nvl(e.rows_processed,0) - nvl(b.rows_processed,0)) rows_processed2,
     (decode(nvl(e.rows_processed,0) - nvl(b.rows_processed,0),0, 0
            ,(e.rows_processed - nvl(b.rows_processed,0)) /(e.executions - nvl(b.executions,0)))) rowsperexec2,
     e.hash_value hash_value,e.module module,st.sql_text sql_text
    from stats$sql_summary e
        ,stats$sql_summary b
        ,stats$sqltext     st 
      where b.snap_id(+)         = :bid2
        and b.dbid(+)            = e.dbid
        and b.instance_number(+) = e.instance_number
        and b.hash_value(+)      = e.hash_value
        and b.address(+)         = e.address
        and b.text_subset(+)     = e.text_subset
        and e.snap_id            = :eid2
        and e.dbid               = :dbid
        and e.instance_number    = :inst_num
        and e.hash_value         = st.hash_value 
        and e.text_subset        = st.text_subset
        and st.piece             < &&num_rows_per_hash
        and e.executions         > nvl(b.executions,0)
      order by (e.executions - nvl(b.executions,0)) desc, e.hash_value, st.piece
      )
where rownum < &&top_n_sql) report2,
  (select /*+ ordered use_nl (b st) */
     st.piece piece,(e.executions - nvl(b.executions,0)) executions1,
     (nvl(e.rows_processed,0) - nvl(b.rows_processed,0)) rows_processed1,
     (decode(nvl(e.rows_processed,0) - nvl(b.rows_processed,0),0, 0
            ,(e.rows_processed - nvl(b.rows_processed,0)) /(e.executions - nvl(b.executions,0)))) rowsperexec1,
     e.hash_value hash_value,e.module module,st.sql_text sql_text
    from stats$sql_summary e
        ,stats$sql_summary b
        ,stats$sqltext     st 
      where b.snap_id(+)         = :bid1
        and b.dbid(+)            = e.dbid
        and b.instance_number(+) = e.instance_number
        and b.hash_value(+)      = e.hash_value
        and b.address(+)         = e.address
        and b.text_subset(+)     = e.text_subset
        and e.snap_id            = :eid1
        and e.dbid               = :dbid
        and e.instance_number    = :inst_num
        and e.hash_value         = st.hash_value 
        and e.text_subset        = st.text_subset
        and st.piece             < &&num_rows_per_hash
        and e.executions         > nvl(b.executions,0)
      order by (e.executions - nvl(b.executions,0)) desc, e.hash_value, st.piece
      ) report1
where report2.hash_value=report1.hash_value and report2.piece=report1.piece
order by executions2 desc,report2.hash_value,report2.piece;

--  Tablespace IO summary statistics

ttitle lef 'Tablespace IO Stats';
set underline on
col tsname     format a20           heading 'Tablespace';
col reads1      format 9,999,999,990 heading 'Reads';
col writes1     format 999,999,990   heading 'Writes';
col rps1        format 99,999        heading 'Report1|Av|Reads/s'    just c;
col wps1        format 99,999        heading 'Av|Writes/s'   just c;
col ios        noprint
col reads2      format 9,999,999,990 heading 'Reads';
col writes2     format 999,999,990   heading 'Writes';
col rps2        format 99,999        heading 'Report2|Av|Reads/s'    just c;
col wps2        format 99,999        heading 'Av|Writes/s'   just c;
select report1.tsname,reads1,rps1,writes1,wps1,reads2,rps2,writes2,wps2,ios
from
(select e.tsname
     , sum (e.phyrds - nvl(b.phyrds,0))                     reads1
     , sum (e.phyrds - nvl(b.phyrds,0))/:ela1                rps1
     , sum (e.phywrts    - nvl(b.phywrts,0))                writes1
     , sum (e.phywrts    - nvl(b.phywrts,0))/:ela1           wps1
 from stats$filestatxs e
     , stats$filestatxs b
 where b.snap_id(+)         = :bid1
   and e.snap_id            = :eid1
   and b.dbid(+)            = :dbid
   and e.dbid               = :dbid
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = :inst_num
   and e.instance_number    = :inst_num
   and b.instance_number(+) = e.instance_number
   and b.tsname(+)          = e.tsname
   and b.filename(+)        = e.filename
   and ( (e.phyrds  - nvl(b.phyrds,0)  )  + 
         (e.phywrts - nvl(b.phywrts,0) ) ) > 0
 group by e.tsname) report1,
(select e.tsname
     , sum (e.phyrds - nvl(b.phyrds,0))                     reads2
     , sum (e.phyrds - nvl(b.phyrds,0))/:ela2                rps2
     , sum (e.phywrts    - nvl(b.phywrts,0))                writes2
     , sum (e.phywrts    - nvl(b.phywrts,0))/:ela2           wps2
     , sum (e.phyrds  - nvl(b.phyrds,0))  +  
       sum (e.phywrts - nvl(b.phywrts,0))                   ios
  from stats$filestatxs e
     , stats$filestatxs b
 where b.snap_id(+)         = :bid2
   and e.snap_id            = :eid2
   and b.dbid(+)            = :dbid
   and e.dbid               = :dbid
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = :inst_num
   and e.instance_number    = :inst_num
   and b.instance_number(+) = e.instance_number
   and b.tsname(+)          = e.tsname
   and b.filename(+)        = e.filename
   and ( (e.phyrds  - nvl(b.phyrds,0)  )  + 
         (e.phywrts - nvl(b.phywrts,0) ) ) > 0
 group by e.tsname) report2
where report1.tsname(+)=report2.tsname
order by ios desc;
spool off
set termout on
prompt
prompt End of Report
prompt report file is located at &reportname
set termout off;
clear columns sql;
ttitle off;
btitle off;
repfooter off;
set linesize 78 termout on feedback 6 underline on;
undefine begin_snap
undefine end_snap
undefine dbid
undefine inst_num
undefine report_name
undefine top_n_sql
undefine top_n_events
undefine btime
undefine etime
whenever sqlerror continue;
