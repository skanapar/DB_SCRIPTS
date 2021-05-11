create or replace procedure np (PrevMth IN integer , PrevYr IN integer, CurMth IN integer , CurYr IN integer)
AS                                                                                                                      
  CURSOR PreviousMonthCur IS                                                                                            
 SELECT * from  tse
        WHERE month = CurMth AND year = CurYr                                                                           
        AND gin NOT IN                                                                                                  
  (select gin                                                                                                           
    from  tse
                 where Month = PrevMth and year = PrevYr);                                                              
                                                                                                                        
--  vEmpRec t_sap_employees%ROWTYPE;                                                                                    
                                                                                                                        
BEGIN                                                                                                                   
                                                                                                                        
-- Empty the table                                                                                                      
--Delete from t_sap_employees_newhires;                                                                                 
--Commit;                                                                                                               
                                                                                                                        
-- for every row in Cursor PreviousMonthCur LOOP                                                                        
  FOR vEmpRec IN PreviousMonthCur LOOP                                                                                  
                                                                                                                        
          INSERT INTO mia                                                                          
  (SAP_EMPLOYEES_ID,                                                                                                    
   MONTH            ,                                                                                                   
   YEAR             ,                                                                                                   
   NAME             ,                                                                                                   
   GIN              ,                                                                                                   
   AREA             ,                                                                                                   
   GEOMARKET        ,                                                                                                   
   COUNTRY          ,                                                                                                   
   PRODUCTGROUP     ,                                                                                                   
   SEGMENT_PRODUCTLINE,                                                                                                 
   SUBSEGMENT       ,                                                                                                   
   EMPLOYEEGROUP    ,                                                                                                   
   EMPLOYEESUBGROUP ,                                                                                                   
   JOBDISCIPLINE    ,                                                                                                   
   JOBGROUP)                                                                                                            
           VALUES                                                                                                       
                (vEmpRec.SAP_EMPLOYEES_ID,                                                                              
   vEmpRec.MONTH            ,                                                                                           
   vEmpRec.YEAR             ,                                                                                           
   vEmpRec.NAME             ,                                                                                           
   vEmpRec.GIN              ,                                                                                           
   vEmpRec.AREA             ,                                                                                           
   vEmpRec.GEOMARKET        ,                                                                                           
   vEmpRec.COUNTRY          ,                                                                                           
   vEmpRec.PRODUCTGROUP     ,                                                                                           
   vEmpRec.SEGMENT_PRODUCTLINE,                                                                                         
   vEmpRec.SUBSEGMENT       ,                                                                                           
   vEmpRec.EMPLOYEEGROUP    ,                                                                                           
   vEmpRec.EMPLOYEESUBGROUP ,                                                                                           
   vEmpRec.JOBDISCIPLINE    ,                                                                                           
   vEmpRec.JOBGROUP);                                                                                                   
  commit;                                                                                                               
                                                                                                                        
  END LOOP;                                                                                                             
END;                                                                                                                    
/
show errors
