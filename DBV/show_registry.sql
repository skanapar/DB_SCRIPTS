COLUMN comp_id FORMAT A10
COLUMN comp_name FORMAT A35
COLUMN version FORMAT A14

SELECT comp_id,comp_name,version FROM dba_registry;
