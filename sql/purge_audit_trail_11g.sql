prompt "Purging Audit Trail OS Files, All RAC instances, All PDBs, as of last Archive Timestamp..."
BEGIN
  DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(
   AUDIT_TRAIL_TYPE           =>  DBMS_AUDIT_MGMT.AUDIT_TRAIL_FILES,
   USE_LAST_ARCH_TIMESTAMP    =>  TRUE);
END;
/
