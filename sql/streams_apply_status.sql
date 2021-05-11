
set lines 120
set pages 30
clear screen
prompt Transactions received and applied
prompt ---------------------------------
prompt
COLUMN APPLY_NAME HEADING 'Apply Process Name' FORMAT A25
COLUMN TOTAL_RECEIVED HEADING 'Total|Trans|Received' FORMAT 99999999
COLUMN TOTAL_APPLIED HEADING 'Total|Trans|Applied' FORMAT 99999999
COLUMN TOTAL_ERRORS HEADING 'Total|Apply|Errors' FORMAT 9999
COLUMN BEING_APPLIED HEADING 'Total|Trans Being|Applied' FORMAT 99999999

SELECT APPLY_NAME,
       TOTAL_RECEIVED,
       TOTAL_APPLIED,
       TOTAL_ERRORS,
       (TOTAL_ASSIGNED - (TOTAL_ROLLBACKS + TOTAL_APPLIED)) BEING_APPLIED
       FROM V$STREAMS_APPLY_COORDINATOR;

prompt Apply processes dequeueing LCRs
prompt ---------------------------------
prompt
COLUMN SUBSCRIBER_NAME HEADING 'Apply Process' FORMAT A20
COLUMN QUEUE_SCHEMA HEADING 'Queue|Owner' FORMAT A10
COLUMN QUEUE_NAME HEADING 'Queue|Name' FORMAT A20
COLUMN LAST_DEQUEUED_SEQ HEADING 'Last|Dequeued|Sequence' FORMAT 9999999999
COLUMN NUM_MSGS HEADING 'Number of|LCRs in|Queue' FORMAT 99999999
COLUMN TOTAL_SPILLED_MSG HEADING 'Number of|Spilled LCRs' FORMAT 99999999

SELECT s.SUBSCRIBER_NAME,
       q.QUEUE_SCHEMA,
       q.QUEUE_NAME,
       s.LAST_DEQUEUED_SEQ,
       s.NUM_MSGS,
       s.TOTAL_SPILLED_MSG
FROM V$BUFFERED_QUEUES q, V$BUFFERED_SUBSCRIBERS s, DBA_APPLY a
WHERE q.QUEUE_ID = s.QUEUE_ID AND
      s.SUBSCRIBER_ADDRESS IS NULL AND
      s.SUBSCRIBER_NAME = a.APPLY_NAME;

col QUEUE format a50 wrap
col "Message Count" format 99999999999 heading 'Current Number of|Outstanding|Messages|in Queue'
col "Spilled Msgs" format 99999999999 heading 'Current Number of|Spilled|Messages|in Queue'
col "Total Messages" format 99999999999 heading 'Cumulative |Number| of Messages|in Queue'
col "Total Spilled Msgs" format 99999999999 heading 'Cumulative Number|of Spilled|Messages|in Queue'

col QUEUE format a30 wrap
col "Message Count" format 99999999999 heading 'Current Number of|Outstanding|Messages|in Queue'
col "Spilled Msgs" format 99999999999 heading 'Current Number of|Spilled|Messages|in Queue'
col "Total Messages" format 99999999999 heading 'Cumulative |Number| of Messages|in Queue'
col "Total Spilled Msgs" format 99999999999 heading 'Cumulative Number|of Spilled|Messages|in Queue'

SELECT queue_schema||'.'||queue_name Queue, startup_time, num_msgs "Message Count", 
spill_msgs "Spilled Msgs", cnum_msgs "Total Messages", 
cspill_msgs "Total Spilled Msgs" FROM gv$buffered_queues;
