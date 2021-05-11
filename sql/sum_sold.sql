SELECT /*+ gather_plan_statistics monitor */
       SUM(amount_sold) sum_sold
  FROM sales_big
 WHERE cust_id = TO_NUMBER('&&nn.');