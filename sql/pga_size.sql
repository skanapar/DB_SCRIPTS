SELECT /*+ NO_MERGE */
       inst_id,
       name,
       value,
       unit,
       CASE unit WHEN 'bytes' THEN
       CASE
       WHEN value > POWER(2,50) THEN ROUND(value/POWER(2,50),1)||' P'
       WHEN value > POWER(2,40) THEN ROUND(value/POWER(2,40),1)||' T'
       WHEN value > POWER(2,30) THEN ROUND(value/POWER(2,30),1)||' G'
       WHEN value > POWER(2,20) THEN ROUND(value/POWER(2,20),1)||' M'
       WHEN value > POWER(2,10) THEN ROUND(value/POWER(2,10),1)||' K'
       ELSE value||' B' END
       END approx
  FROM gv$pgastat
 ORDER BY
       name,
       inst_id;
