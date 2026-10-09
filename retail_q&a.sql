-- Tables: customers , products , orders , order_items
select * from customers;
select * from products;
select * from orders;
select * from order_items;

--Q1. List every order with the customer’s name, order date, and status.
SELECT o.order_id,
       c.name AS customer_name,
       o.order_date,
       o.status
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
ORDER BY o.order_date;

--- 25 order 
---------------------------------------------------------------------------
--Q2. Find customers who have never placed an order.

SELECT c.customer_id,
       c.name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

---------------------------------------------------------------------------------------------------
--Q3. (JOIN – SELF) Show each customer along with the name of the customer who referred them
SELECT c.name AS customer,
       r.name AS referred_by
FROM customers c
LEFT JOIN customers r
    ON c.referred_by = r.customer_id
ORDER BY c.customer_id;
-- 12 
------------------------------------------------------------------------------------------------------------------
--Q4.Find customers whose total spend is above the average spend of all customers.
SELECT customer_name,
       SUM(order_total) AS total_spend
FROM vw_order_summary
WHERE status != 'cancelled'
GROUP BY customer_name
HAVING SUM(order_total) > (
    SELECT AVG(order_total)
    FROM vw_order_summary
    WHERE status != 'cancelled'
);-- 8 

---------------------------------------------------------------------------------------------------------------
--Q5. Find orders whose total is higher than that customer’s own average order value.
SELECT vs.order_id,
       vs.customer_name,
       vs.order_total
FROM vw_order_summary vs
WHERE vs.order_total > (
    SELECT AVG(vs2.order_total)
    FROM vw_order_summary vs2
    WHERE vs2.customer_id = vs.customer_id
);-- 10
---------------------------------------------------------------------------------------------------------------
--Q6.Find customers who have ordered at least one “Electronics” product.
SELECT DISTINCT c.name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    WHERE o.customer_id = c.customer_id
      AND p.category = 'Electronics'
); -- 7
---------------------------------------------------------------------------------------------------------------

--Q7.Show total revenue per category, only for categories earning more than 5000.
SELECT p.category,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.status != 'cancelled'
GROUP BY p.category
HAVING SUM(oi.quantity * oi.unit_price) > 5000
ORDER BY revenue DESC; -- 4
---------------------------------------------------------------------------------------------------------------
--Q8.List the top 5 customers by total spend, highest first.
SELECT customer_name,
       SUM(order_total) AS total_spend
FROM vw_order_summary
WHERE status !='cancelled'
GROUP BY customer_name
ORDER BY total_spend DESC
LIMIT 5;
---------------------------------------------------------------------------------------------------------------
--Q9.Calculate monthly revenue for 2026.
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', order_date) AS month,
           SUM(order_total) AS revenue
    FROM vw_order_summary
    WHERE status != 'cancelled'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT month,
       revenue
FROM monthly_revenue
ORDER BY month; -- 7 
---------------------------------------------------------------------------------------------------------------
--Q10.Show monthly revenue alongside a running (cumulative) total.
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', order_date) AS month,
           SUM(order_total) AS revenue
    FROM vw_order_summary
    WHERE status != 'cancelled'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT month,
       revenue,
       SUM(revenue) OVER (
           ORDER BY month
       ) AS running_total
FROM monthly_revenue
ORDER BY month; -- 7 
---------------------------------------------------------------------------------------------------------------
--Q11. Find each customer’s very first order.
WITH ranked AS (
    SELECT customer_id,
           order_id,
           order_date,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date
           ) AS rn
    FROM orders
)
SELECT customer_id,
       order_id,
       order_date
FROM ranked
WHERE rn = 1; -- 12
---------------------------------------------------------------------------------------------------------------
--Q12.Rank products by total revenue within their own category.
WITH product_revenue AS (
    SELECT p.category,
           p.product_name,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY p.category, p.product_name
)
SELECT category,
       product_name,
       revenue,
       RANK() OVER (
           PARTITION BY category
           ORDER BY revenue DESC
       ) AS category_rank
FROM product_revenue
ORDER BY category, category_rank; -- 10
---------------------------------------------------------------------------------------------------------------
--Q13. Dense-rank customers by total spend (no gaps for ties).
WITH customer_spend AS (
    SELECT customer_name,
           SUM(order_total) AS total_spend
    FROM vw_order_summary
    WHERE status <> 'cancelled'
    GROUP BY customer_name
)
SELECT customer_name,
       total_spend,
       DENSE_RANK() OVER (
           ORDER BY total_spend DESC
       ) AS spend_rank
FROM customer_spend; -12 
---------------------------------------------------------------------------------------------------------------
--Q14. Trace the referral chain — who ultimately brought in each customer.
WITH RECURSIVE referral_chain AS (
    SELECT customer_id,
           name,
           referred_by,
           1 AS level
    FROM customers
    WHERE referred_by IS NULL

    UNION ALL

    SELECT c.customer_id,
           c.name,
           c.referred_by,
           rc.level + 1
    FROM customers c
    JOIN referral_chain rc
        ON c.referred_by = rc.customer_id
)
SELECT *
FROM referral_chain
ORDER BY level, customer_id; -- 12
---------------------------------------------------------------------------------------------------------------
--Q15.Use vw_order_summary to list all delivered orders worth more than 2000.
SELECT *
FROM vw_order_summary
WHERE status = 'delivered'
  AND order_total > 2000
ORDER BY order_total DESC; -- 10
---------------------------------------------------------------------------------------------------------------
--Q16.Show how the index on orders.customer_id is used, and why it helps.
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 3; -- 6
---------------------------------------------------------------------------------------------------------------
