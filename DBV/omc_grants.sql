grant execute on sys.dbms_lock to  C##OMC_MON_ROLE;
grant execute on dbms_system to  C##OMC_MON_ROLE;
grant execute on SYS.DBMS_DRS to  C##OMC_MON_ROLE;
grant read on v_$system_parameter to  C##OMC_MON_ROLE;
grant read on gv_$system_parameter to  C##OMC_MON_ROLE;
grant read on v_$rsrcpdbmetric_history to  C##OMC_MON_ROLE;
grant read on gv_$rsrcpdbmetric_history to  C##OMC_MON_ROLE;
grant read on v_$con_sysmetric_history to  C##OMC_MON_ROLE;
grant read on gv_$con_sysmetric_history to  C##OMC_MON_ROLE;
grant  C##OMC_MON_ROLE to  c##omc_user;

