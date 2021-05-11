/*
     This file is part of demos for "Mutex Internals" 
        presentation at Hotsos Symposium 2012
     Andrey S. Nikolaev (Andrey.Nikolaev@rdtex.ru) 
 
http://AndreyNikolaev.wordpress.com
 
     Compute the mutex statistics 
     For Oracle versions 11.2
 
     usage:
        sqlplus /nolog @mutex_stats mutex_identifier=<...> 
or
        sqlplus /nolog @mutex_stats mutex_address=0x<...> 
 
*/
connect / as sysdba
set verify off
set echo off
 
SET SERVEROUTPUT ON
set timing on
 
declare
   arg varchar2(1000);
   n PLS_INTEGER;
   i NUMBER;
   j number;
   idn number;
   Samples         NUMBER;
   SampleFreq      NUMBER;
   wordsize number;
   rho_s number;
   rho_x number;
   Error_ varchar2(2000);
   eta number;
   muvalue varchar2(20);
   dgets number;
   dsleeps number;
   lambda number;
   omega number;
   S number;
   kappa number;
   zeta number;
   K number;
   ssleep number;
   sigma number;
   omega_prime number;
   dmisses number;
   rho number;
   params varchar2(2000);
   lcname varchar2(1000);
   Nw number;
/* mutex statistics */
 cursor mustat(muindx number) is   
     select decode(dbms_utility.get_endianness,1,p2,p1) gets,decode(dbms_utility.get_endianness(),1,p1,p2) sleeps
       from (select FLOOR(val/POWER(2,4*wordsize)) p2, MOD (val,POWER(2,4*wordsize)) p1 from
         (select to_number(ksmmmval,'XXXXXXXXXXXXXXXX') val from x$ksmmem where indx=muindx)); /* next after mutex index */
 cursor Hold(muindx number) is select rawtohex(ksmmmval) from x$ksmmem where indx=muindx;
 cursor Wait(idn_ number) is select count(*) from v$session_wait where p1text='idn' and p1=idn_ and state='WAITING';
/*   mutexes: */
  TYPE mutex IS RECORD (addr RAW(8), mutex_type varchar2(30), indx number,
                              U number, Ux number,dtime number,
                             mus_start mustat%rowtype, mus_end mustat%rowtype); 
   TYPE mutex_tab is table of mutex index by PLS_INTEGER;  /* table for  all mutexes associated with this identifier */
   mu mutex_tab;
/* Library cache objects statistics */
   cursor ls_(idn_ in number) is select case when (kglhdadr =  kglhdpar) then 'Parent' else 'Child '||kglobt09 end par,
                 kglhdadr addr,kglobtyd type,kglnaown owner,kglnaobj name,kglobt23 locks,kglobt24 pins,kglhdexc executions,kglhdnsp namespace
                   from x$kglob where kglnahsh=idn_
                   order by name,decode(kglobt09,65535,-1,kglobt09);
   type lstat_ IS RECORD(addr RAW(8), par varchar2(15),name varchar2(1000),locks number,pins number, executions number,namespace number);
   type lstat__ is table of lstat_ index by varchar2(16);
   lstat lstat__;
BEGIN
   arg:='&1';
   SampleFreq := 1 / 10;   -- Hz
   Samples := 300;
    SELECT DECODE (INSTR (banner, '64'), 0, '4', '8') ws into wordsize FROM v$version WHERE ROWNUM = 1;
   Nw:=0;
/*     CPU count */
   select value into eta from v$parameter where name = 'cpu_count';
   eta:= eta/(eta-1);                                       /* correction coefficient */
 
/*  1. Argument is mutex identifier. There may be several mutexes with the same idn. */
   if  regexp_like(arg,'^(mutex_)?id(n|entifier)=[[:digit:]]+','i')  then
      /*     obtain mutex addresses from 10 minute history of recent waits */
      n:=0;
      idn:=to_number(substr(arg,regexp_instr(arg,'^(mutex_)?id(n|entifier)=',1,1,1,'i')));
      FOR lw in (select distinct mutex_addr,mutex_type 
              from x$mutex_sleep_history 
                 where mutex_identifier= idn
                 and sleep_timestamp > systimestamp - interval  '10' minute)
      LOOP
        n:=n+1;
        mu(n).addr := lw.mutex_addr;
        mu(n).mutex_type:=lw.mutex_type;
        mu(n).indx:=NULL;
       END LOOP;
       if n = 0 then raise_application_error(-20001,'Can not find mutex with idn: '||idn||' in x$mutex_sleep_history');
       end if;
/* 2.  Argument is mutex address.  */
   elsif  regexp_like(arg,'^(mutex_)?addr(ess)?=0x[[:xdigit:]]+','i') then
      n:=1;
      mu(n).addr := HEXTORAW (lpad(upper(substr(arg,regexp_instr(arg,'^(mutex_)?addr(ess)?=0x',1,1,1,'i'))),16,'0'));
      if mu(n).addr = '00' then 
          raise_application_error(-20001,'Invalid mutex address: '||arg);
      end if;
 
      idn:=null;
      mu(n).mutex_type:=NULL;
      mu(n).indx:=NULL;
       /*   find mutex identifier from x$mutex_sleep_history */
      for lw in (select mutex_identifier, mutex_type 
                     from x$mutex_sleep_history 
                        where mutex_addr=mu(1).addr)
      loop
         idn:= lw.mutex_identifier;
         mu(n).mutex_type:=lw.mutex_type;
      end loop;
   else
    raise_application_error(-20003,'Usage:   sqlplus /nolog @mutex_stat (mutex_identifier=... | mutex_address=0x...)');
   end if;
/* Compute indx in x$ksmmem for mutex address(es)  */
   FOR j IN 1 .. n
   loop
      for sga in (select indx  from x$ksmmem where addr=mu(j).addr)
      loop
         mu(j).indx:=sga.indx;
      end loop;
       
      if mu(j).indx is null then
        raise_application_error(-20002,'No such address in SGA: 0x'||rawtohex(mu(j).addr));
      end if;
      mu(j).U:=0;
      mu(j).Ux:=0;
/* library cache statistics at beginning */
      if idn > 0 then
         for ls in ls_(idn)
         loop
             params:=rawtohex(ls.addr);
             lstat(params).addr:=params;
             lstat(params).locks:=ls.locks;
             lstat(params).pins:=ls.pins;
             lstat(params).executions:=ls.executions;
             lstat(params).namespace:=ls.namespace;
         end loop;
      end if;
/*      Mutex statistics at start  */
      mu(j).dtime := DBMS_UTILITY.GET_TIME();
      OPEN mustat(mu(j).indx+1);
      FETCH mustat into mu(j).mus_start;
      CLOSE mustat;
   end loop;
 
/*     Sampling */
   FOR i IN 1 .. Samples
   LOOP
       DBMS_LOCK.sleep (SampleFreq);
/*       Average number of waiting sessions */
       OPEN Wait(idn);
       FETCH Wait into muvalue;
       CLOSE Wait;
       Nw:=Nw+muvalue;
/*         for all mutexes with this indx: */       
       FOR j IN 1 .. n
       loop
          OPEN  Hold(mu(j).indx);
          FETCH Hold into muvalue;
          CLOSE Hold;
          if muvalue <> '00' then
             mu(j).U:=mu(j).U+1;
             if length(ltrim(muvalue,'0')) > wordsize then   /* upper mutex bytes is not zero */
                mu(j).Ux:=mu(j).Ux+1;
             end if;
          end if;
       end loop;   
   END LOOP;
/*     End mutex statistics */
   FOR j IN 1 .. n
   loop
      OPEN mustat(mu(j).indx+1);
      FETCH mustat into mu(j).mus_end;
      CLOSE mustat;
      mu(j).dtime:=(DBMS_UTILITY.GET_TIME()-mu(j).dtime)*0.01; /* delta time in seconds */
   end loop;
/*     Compute derived statistics */
   FOR j IN 1 .. n
   loop
      Error_:='';
      rho_s:=(mu(j).U-mu(j).Ux)/Samples;
      rho_x:=mu(j).Ux/Samples;
      rho:=mu(j).U/Samples;
 
      dgets := mu(j).mus_end.gets - mu(j).mus_start.gets;
      dsleeps:= mu(j).mus_end.sleeps - mu(j).mus_start.sleeps;
 
      lambda:= dgets/mu(j).dtime;
      omega := dsleeps/mu(j).dtime;
      if(dgets>0) then
          S := rho_x/lambda  ; -- mutex holding time in usecs
      else
          Error_ := Error_||' Delta Gets='||dgets;   /* there was no mutex gets */
      end if;
    
      if(lambda*rho_x!=0) then
          kappa := omega/(lambda*rho_x);               -- sleep ratio
      else
          Error_ := Error_||' rho_x=0, lambda= '||trunc(lambda)||' Hz';                  /* we didn't saw mutex in X mode */
          kappa :=null;
      end if;
      zeta := lambda*rho_x;                                                    -- miss rate
      K := kappa/(1+kappa*rho_x);                                              -- spin efficiency
      sigma:=1-K;
      if(nvl(kappa,0)!=0) then
          ssleep := (sigma+kappa-1)/kappa  ;                       -- secondary sleep ratio
      else
          Error_ := Error_||' kappa=0 ';
          ssleep  :=null;
      end if;
          omega_prime:=zeta*K ;                                                              -- waits estimation from mutex stats
      if(length(Error_)>0 ) then
        DBMS_OUTPUT.put_LINE (' Error: '||Error_);
     else
       DBMS_OUTPUT.put_LINE (chr(10)||'--------------------------------------------');
       DBMS_OUTPUT.put_LINE ('Statistics for "'||mu(j).mutex_type||'" mutex');
       DBMS_OUTPUT.put_LINE ('idn: '||idn||' address  0x'||mu(j).addr);
       DBMS_OUTPUT.put_LINE ('Interval: '||to_char(mu(j).dtime,'999.9')||' s,  gets: ' ||dgets||', sleeps:'||dsleeps||chr(10));
       DBMS_OUTPUT.put_LINE ('Requests rate:                  lambda=' || to_char(lambda,'999999999.9')||' Hz');
       DBMS_OUTPUT.put_LINE ('Sleeps rate:                    omega= ' || to_char(omega,'999999999.9')||' Hz');
       DBMS_OUTPUT.put_LINE ('Utilization:                    rho=  ' || to_char(rho,'9.999999'));
       DBMS_OUTPUT.put_LINE ('Exclusive Utilization:          rho_x=' || to_char(rho_x,'9.999999'));
       DBMS_OUTPUT.put_LINE ('Shared Utilization:             rho_s=' || to_char(rho_s,'9.999999'));
       DBMS_OUTPUT.put_LINE ('Avg. holding time:              S=' || to_char(S*1000000,'9999999.99')||' us');
       DBMS_OUTPUT.put_LINE ('Service rate:                   mu=   ' || to_char(1/S,'9999999999.9')||' Hz');
       DBMS_OUTPUT.put_LINE ('Spin inefficiency:              k=    ' || to_char(K,'9.999999'));
       DBMS_OUTPUT.put_LINE (chr(10)||'Secondary statistics:');
       DBMS_OUTPUT.put_LINE ('Slps /Miss:               kappa=' || to_char(kappa,'9.999999'));
       DBMS_OUTPUT.put_LINE ('Spin_gets/miss:           sigma=' || to_char(sigma,'9.999999'));
       DBMS_OUTPUT.put_LINE ('correction coeff.         eta=' || to_char(eta,'9.9'));
       DBMS_OUTPUT.put_LINE ('Secondary sleeps ratio        ' || to_char(ssleep,'9.999'));
      end if;
   end loop;  
       DBMS_OUTPUT.put_LINE (chr(10)||'--------------------------------------------');
      DBMS_OUTPUT.put_LINE ('Avg. number of  sessions waiting:    ' || to_char(Nw/Samples,'9999.99'));
   /*   */
      if idn > 0 then
          lcname:=' ';
         DBMS_OUTPUT.put_LINE (chr(10)||'Library cache object related to  mutex idn ' || idn||' :'||chr(10));
         for ls in ls_(idn)
         loop
             if ls.name != lcname then
                if ls.type='CURSOR' then
                 DBMS_OUTPUT.put_LINE (ls.type||': '||ls.name);
                else
                 DBMS_OUTPUT.put_LINE (ls.type||': '||ls.owner||'.'||ls.name);
                end if;
              DBMS_OUTPUT.put_LINE (chr(10)||'ADDR:              TYPE        PIN/s:    LOCK/s:    EXEC/s: Namespc' );
              DBMS_OUTPUT.put_LINE ('-------------------------------------------------------------------');
              lcname:=ls.name;
             end if; 
             begin 
               params:=rawtohex(ls.addr);
              DBMS_OUTPUT.put_LINE (rpad(ls.addr,16)||'   '||rpad(rtrim(ls.par),10)||
                   to_char((ls.pins -lstat(params).pins )/mu(1).dtime,'9999999')||'   '||
                   to_char((ls.locks-lstat(params).locks)/mu(1).dtime,'9999999')||'   '||
                   to_char((ls.executions-lstat(params).executions)/mu(1).dtime,'9999999')||
                   '   '||to_char(ls.namespace,'9999'));
               exception when NO_DATA_FOUND then
                   null;
               end;
          end loop;
      end if;
      /* mutex parameters */
      params:='';
      for Param in (select  ksppinm,ksppstvl from x$ksppi x  join x$ksppcv using (indx )
                        where ksppinm like  '%mutex%' or ksppinm like  '%wait_yield%' order by ksppinm)
      loop
         params:=params||Param.ksppinm||'='||Param.ksppstvl||' ';
      end loop;
      DBMS_OUTPUT.put_LINE (chr(10) ||'Mutex related parameters:'||chr(10) || params);
END;
/
