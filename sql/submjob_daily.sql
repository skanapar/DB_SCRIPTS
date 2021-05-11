VARIABLE jobno NUMBER;
BEGIN
   DBMS_JOB.SUBMIT(:jobno, 
	'extract;', 
	trunc(sysdate+1), 'trunc(SYSDATE+1)-(1/24)');
   COMMIT;
END;
/
print jobno
