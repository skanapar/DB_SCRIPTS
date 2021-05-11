col xh00 for a4  justify right head "00"
col xh01 like xh00 head "01"
col xh02 like xh00 head "02"
col xh03 like xh00 head "03"
col xh04 like xh00 head "04"
col xh05 like xh00 head "05"
col xh06 like xh00 head "06"
col xh07 like xh00 head "07"
col xh08 like xh00 head "08"
col xh09 like xh00 head "09"
col xh10 like xh00 head "10"
col xh11 like xh00 head "11"
col xh12 like xh00 head "12"
col xh13 like xh00 head "13"
col xh14 like xh00 head "14"
col xh15 like xh00 head "15"
col xh16 like xh00 head "16"
col xh17 like xh00 head "17"
col xh18 like xh00 head "18"
col xh19 like xh00 head "19"
col xh20 like xh00 head "20"
col xh21 like xh00 head "21"
col xh22 like xh00 head "22"
col xh23 like xh00 head "23"
col xhtot like xh00 head "TOT"

select trunc(first_time) day,
	lpad(sum(decode(to_char(first_time,'hh24'),'00',1,0)),4) xh00,
	lpad(sum(decode(to_char(first_time,'hh24'),'01',1,0)),4) xh01,
	lpad(sum(decode(to_char(first_time,'hh24'),'02',1,0)),4) xh02,
	lpad(sum(decode(to_char(first_time,'hh24'),'03',1,0)),4) xh03,
	lpad(sum(decode(to_char(first_time,'hh24'),'04',1,0)),4) xh04,
	lpad(sum(decode(to_char(first_time,'hh24'),'05',1,0)),4) xh05,
	lpad(sum(decode(to_char(first_time,'hh24'),'06',1,0)),4) xh06,
	lpad(sum(decode(to_char(first_time,'hh24'),'07',1,0)),4) xh07,
	lpad(sum(decode(to_char(first_time,'hh24'),'08',1,0)),4) xh08,
	lpad(sum(decode(to_char(first_time,'hh24'),'09',1,0)),4) xh09,
	lpad(sum(decode(to_char(first_time,'hh24'),'10',1,0)),4) xh10,
	lpad(sum(decode(to_char(first_time,'hh24'),'11',1,0)),4) xh11,
	lpad(sum(decode(to_char(first_time,'hh24'),'12',1,0)),4) xh12,
	lpad(sum(decode(to_char(first_time,'hh24'),'13',1,0)),4) xh13,
	lpad(sum(decode(to_char(first_time,'hh24'),'14',1,0)),4) xh14,
	lpad(sum(decode(to_char(first_time,'hh24'),'15',1,0)),4) xh15,
	lpad(sum(decode(to_char(first_time,'hh24'),'16',1,0)),4) xh16,
	lpad(sum(decode(to_char(first_time,'hh24'),'17',1,0)),4) xh17,
	lpad(sum(decode(to_char(first_time,'hh24'),'18',1,0)),4) xh18,
	lpad(sum(decode(to_char(first_time,'hh24'),'19',1,0)),4) xh19,
	lpad(sum(decode(to_char(first_time,'hh24'),'20',1,0)),4) xh10,
	lpad(sum(decode(to_char(first_time,'hh24'),'21',1,0)),4) xh21,
	lpad(sum(decode(to_char(first_time,'hh24'),'22',1,0)),4) xh22,
	lpad(sum(decode(to_char(first_time,'hh24'),'23',1,0)),4) xh23,
	lpad(count(first_time),4) xhtot
from v$log_history
group by trunc(first_time)
order by 1
/
