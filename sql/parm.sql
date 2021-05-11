SET LINESIZE 500

COLUMN name  FORMAT A30
COLUMN value FORMAT A60

SELECT
    p.con_id,
    p.inst_id,
    p.name,
    p.type,
    p.value,
    p.isses_modifiable,
    p.issys_modifiable,
    p.isinstance_modifiable
FROM gv$parameter p
WHERE p.name like '%&par%'
ORDER BY 1,2,3;