set escape on
select bolnbr,dbms_lob.substr(html,30, dbms_lob.instr(html,'\&type=1''>')-10) from freightlables
/
