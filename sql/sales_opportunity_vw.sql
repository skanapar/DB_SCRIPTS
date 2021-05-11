create or replace sales_oportunity_view as
select s2.lname||', '||s2.fname director, s1.lname||', '||s1.fname regional, e.l                                             
name||', '||e.fname salesperson,                                                                                             
c.cust_name customer, d.ps_m1, d.hw_sw_m1, d.pro_serv_tot, d.hw_sw_total, d.dura                                             
tion, t.description sales_map,                                                                                               
so.service_offering, d.cap_score, d.closing, d.closed                                                                        
from employee e, ot_detail d, employee s1, employee s2,                                                                      
ot_opps o, ot_type t, ot_cust c, service_offerings so                                                                        
where                                                                                                                        
e.empno = d.empno                                                                                                            
and e.spv_empno = s1.empno                                                                                                   
and s1.spv_empno = s2.empno                                                                                                  
and d.detail_num = o.detail_num                                                                                              
and t.ot_num = o.ot_num                                                                                                      
and c.cust_num = o.cust_num                                                                                                  
and d.service_offering_id = so.service_offering_id                                                                           
/
