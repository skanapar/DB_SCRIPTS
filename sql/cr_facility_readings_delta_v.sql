create public database link ekpspp_ods
connect to ods identified by ods
using '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=serv0e.oxy.com)(PORT=1522))(CONNECT_DATA=(SID = EKPSPP)))'
/
create or replace view facility_readings_delta_v as
-- eduardo fierro - 012207
select 
facility_name,
reading_date,
oil_prod,
gas_prod,
ngl_prod,
gas_press,
avg_oil_prod,
avg_gas_prod,
avg_ngl_prod,
avg_gas_press,
var_oil_prod,
var_gas_prod,
var_ngl_prod,
var_gas_press,
round(decode(avg_oil_prod,0,0,100*var_oil_prod/avg_oil_prod),1) var_oil_pct,
round(decode(avg_gas_prod,0,0,100*var_gas_prod/avg_gas_prod),1) var_gas_pct,
round(decode(avg_ngl_prod,0,0,100*var_ngl_prod/avg_ngl_prod),1) var_ngl_pct,
round(decode(avg_gas_press,0,0,100*var_gas_press/avg_gas_press),1) var_gaspress_pct
from
 (select
   facility_name,
   reading_date,
   oil_prod,
   gas_prod,
   ngl_prod,
   gas_press,
   avg_oil_prod,
   avg_gas_prod,
   avg_ngl_prod,
   avg_gas_press,
   oil_prod-avg_oil_prod var_oil_prod,
   gas_prod-avg_gas_prod var_gas_prod,
   ngl_prod-avg_ngl_prod var_ngl_prod,
   gas_press-avg_gas_press var_gas_press
 from
  (select
    facility_name, 
    reading_date,
    sum(decode(commodity,'OIL',meter_volume,0)) oil_prod,
    sum(decode(commodity,'GAS',meter_volume,0)) gas_prod,
    sum(decode(commodity,'NGL',meter_volume,0)) ngl_prod,
    max(decode(commodity,'GAS PRESSURE',meter_volume,0)) gas_press,
    round(avg(decode(commodity,'OIL',meter_volume,0))) avg_oil_prod,
    round(avg(decode(commodity,'GAS',meter_volume,0))) avg_gas_prod,
    round(avg(decode(commodity,'NGL',meter_volume,0))) avg_ngl_prod,
    round(avg(decode(commodity,'GAS PRESSURE',meter_volume,0))) avg_gas_press
   from facility_readings@ekpspp_ods
   where 
    trunc(sysdate)-7 < trunc(reading_date)
    and meter_volume <> -9999
    group by facility_name, reading_date
  )
 )
/
