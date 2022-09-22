use sakila;

#1.Get number of monthly active customers.
CREATE OR REPLACE VIEW active_customers AS
SELECT COUNT(DISTINCT r.customer_id) customers, DATE_FORMAT(rental_date, '%m-%y') as activity_month, DATE_FORMAT(rental_date, '%y') as activity_year
 FROM rental AS r 
 GROUP BY activity_month
 ORDER BY activity_month;
 SELECT * FROM active_customers;
 
 
 #2.Active users in the previous month.
 CREATE OR REPLACE VIEW active_customers_months AS 
SELECT activity_month, activity_year, customers, lag(customers,1) OVER (PARTITION BY activity_year ORDER BY activity_month) active_customers_previous_month  FROM active_customers
ORDER BY activity_month, activity_year; 
 SELECT * FROM active_customers_months;
 
#3.Percentage change in the number of active customers.
 SELECT activity_month, activity_year, active_customers_previous_month,customers,  Round(100*(customers - active_customers_previous_month)/active_customers_previous_month,2) as percent_change 
 FROM active_customers_months
 ORDER BY activity_month, activity_year;
 
 
 #4.Retained customers every month. 
  WITH active_cust_ids AS (
 SELECT customer_id, rental_date from rental
 GROUP BY customer_id, rental_date
 )
 SELECT COUNT(DISTINCT a.customer_id) customers, DATE_FORMAT(a.rental_date, '%m-%y') AS  activity_month_year, 
 CASE WHEN b.customer_id IS NOT NULL THEN 'retained'
 ELSE 'new' END retain_status
 FROM active_cust_ids a 
 LEFT JOIN active_cust_ids b ON a.customer_id = b.customer_id AND  DATE_FORMAT(a.rental_date, '%m-%y')  = DATE_FORMAT(date_add(B.rental_date,interval 1  month), '%m-%y') 
 GROUP BY activity_month_year, retain_status 
 order by a.rental_date asc;
 