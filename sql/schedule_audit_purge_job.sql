prompt "Creating OS_Audit_Trail_Purge Scheduler Job..."
BEGIN
DBMS_AUDIT_MGMT.CREATE_PURGE_JOB (
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_FILES,
AUDIT_TRAIL_PURGE_INTERVAL => 24,
AUDIT_TRAIL_PURGE_NAME => 'OS_Audit_Trail_Purge',
USE_LAST_ARCH_TIMESTAMP => TRUE,
CONTAINER => DBMS_AUDIT_MGMT.CONTAINER_ALL);
END;
/
