set verify off
delete from plan_table;
insert into plan_table (statement_id, 
timestamp, operation, options, object_node,
object_owner, object_name, object_instance,
optimizer, search_columns, id, parent_id, position,
cost, cardinality, bytes, other_tag, partition_start,
partition_stop, partition_id, other, distribution,
cpu_cost, io_cost, temp_space, access_predicates, 
filter_predicates)
select id statement_id,
sysdate timestamp, operation, options, object_node,
object_owner, object_name, 0 object_instance,
p.optimizer, search_columns, id, parent_id, position,
p.cost, cardinality, bytes, other_tag, partition_start,
partition_stop, partition_id, other, distribution,
cpu_cost, io_cost, temp_space, access_predicates,
filter_predicates
from stats$sql_plan p
where p.plan_hash_value = &&plan_hash_value
-- and p.plan_hash_value = pu.plan_hash_value
/
update plan_table set statement_id = (select max(
rawtohex(address)||'-0') from stats$sql_plan_usage
where plan_hash_value = &&plan_hash_value)
/
@xplan
undef plan_hash_value

