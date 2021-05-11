SELECT *
    FROM "PERFSTAT"."STATS$SQL_PLAN"
    WHERE ( "PLAN_HASH_VALUE" = '&plan_hash_value' )
/
