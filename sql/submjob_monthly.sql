VARIABLE jobno NUMBER;
BEGIN
   DBMS_JOB.SUBMIT(:jobno, 
      'extractmowo(to_char(sysdate-1,''MMYY''));', 
      SYSDATE, 'trunc(add_months(SYSDATE,1),''MM'')'); 
   COMMIT;
END;
/
print jobno
