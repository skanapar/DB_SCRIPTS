DECLARE
    long	INTEGER;
    CURSOR num1cur IS SELECT PROJECT_DESCRIPTION FROM sa.soe;
    num1    sa.soe.PROJECT_DESCRIPTION%TYPE;
BEGIN
    OPEN num1cur;
    LOOP
        FETCH num1cur INTO num1;
	DBMS_OUTPUT.ENABLE(100000);
        IF (num1cur%FOUND) THEN
		long := DBMS_LOB.GETLENGTH(num1);
		DBMS_OUTPUT.PUT_LINE(long);
        ELSE
            EXIT;
        END IF;
    END LOOP;
    CLOSE num1cur;
END;
/
