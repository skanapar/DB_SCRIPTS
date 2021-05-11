DROP TABLE t1;

CREATE TABLE t1 NOLOGGING 
AS 
SELECT * FROM sales_1b WHERE ROWNUM <= 1e7;

COL tablespace NEW_V tablespace;
SELECT default_tablespace tablespace FROM dba_users WHERE username = USER;

SPO comp_advisor.txt;

SET SERVEROUT ON;
DECLARE
  l_blkcnt_cmp   NUMBER;
  l_blkcnt_uncmp NUMBER;
  l_row_cmp      NUMBER;
  l_row_uncmp    NUMBER;
  l_cmp_ratio    NUMBER;
  l_comptype_str VARCHAR2(30);
  PROCEDURE get_compression_ratio(p_comptype IN NUMBER ) AS
  BEGIN
    DBMS_COMPRESSION.get_compression_ratio (
      scratchtbsname => '&&tablespace.',
      ownname		 => USER,
      tabname		 => 'T1',
      partname       => NULL,
      comptype		 => p_comptype,
      blkcnt_cmp	 => l_blkcnt_cmp,
      blkcnt_uncmp	 => l_blkcnt_uncmp,
      row_cmp		 => l_row_cmp,
      row_uncmp		 => l_row_uncmp,
      cmp_ratio		 => l_cmp_ratio,
      comptype_str	 => l_comptype_str
    );
    DBMS_OUTPUT.PUT_LINE('******************');
    DBMS_OUTPUT.PUT_LINE('blkcnt_cmp  : '||l_blkcnt_cmp);
    DBMS_OUTPUT.PUT_LINE('blkcnt_uncmp: '||l_blkcnt_uncmp);
    DBMS_OUTPUT.PUT_LINE('row_cmp     : '||l_row_cmp);
    DBMS_OUTPUT.PUT_LINE('row_uncmp   : '||l_row_uncmp);
    DBMS_OUTPUT.PUT_LINE('cmp_ratio   : '||l_cmp_ratio);
    DBMS_OUTPUT.PUT_LINE('comptype_str: '||l_comptype_str);
  END get_compression_ratio;
BEGIN
  get_compression_ratio(DBMS_COMPRESSION.comp_for_oltp);
  get_compression_ratio(DBMS_COMPRESSION.comp_for_query_low);
  get_compression_ratio(DBMS_COMPRESSION.comp_for_query_high);
  get_compression_ratio(DBMS_COMPRESSION.comp_for_archive_low);
  get_compression_ratio(DBMS_COMPRESSION.comp_for_archive_high);
END;
/

SPO OFF;