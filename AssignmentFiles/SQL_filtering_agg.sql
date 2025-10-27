-- ==================================
-- FILTERS & AGGREGATION
-- ==================================

USE coffeeshop_db;


-- Q1) Compute total items per order.
--     Return (order_id, total_items) from order_items.
Select order_id, sum(quantity) as total_items from order_items
group by order_id;
-- Q2) Compute total items per order for PAID orders only.
--     Return (order_id, total_items). Hint: order_id IN (SELECT ... FROM orders WHERE status='paid').
SELECT   orders.order_id, SUM(order_items.quantity) AS total_items FROM orders
JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.status = 'paid'
GROUP BY orders.order_id;
-- Q3) How many orders were placed per day (all statuses)?
--     Return (order_date, orders_count) from orders.
SELECT
    DATE(order_datetime) AS order_date, COUNT(*) AS orders_count
FROM orders
GROUP BY DATE(order_datetime)
ORDER BY DATE(order_datetime);
-- Q4) What is the average number of items per PAID order?
--     Use a subquery or CTE over order_items filtered by order_id IN (...).
SELECT avg(item_count) as avg_items_ppo
from (
	Select order_items.order_id, count(order_items.order_item_id) as item_count
    from order_items
    where order_items.order_id in (select orders.order_id from orders where orders.status = 'paid')
    group by order_items.order_id)
    as paid_order_items;
-- Q5) Which products (by product_id) have sold the most units overall across all stores?
--     Return (product_id, total_units), sorted desc.
Select product_id, sum(quantity) as total_units from order_items
group by product_id 
order by total_units desc;
-- Q6) Among PAID orders only, which product_ids have the most units sold?
--     Return (product_id, total_units_paid), sorted desc.
--     Hint: order_id IN (SELECT order_id FROM orders WHERE status='paid').
SELECT order_items.product_id, sum(order_items.quantity) as total_units_paid from order_items
where order_items.order_id in (select orders.order_id from orders where orders.status = 'paid')
group by order_items.product_id
order by total_units_paid desc;	
-- Q7) For each store, how many UNIQUE customers have placed a PAID order?
--     Return (store_id, unique_customers) using only the orders table.
select store_id, count(distinct customer_id) as unique_customers from orders
where status = 'paid'
group by store_id;
-- Q8) Which day of week has the highest number of PAID orders?
--     Return (day_name, orders_count). Hint: DAYNAME(order_datetime). Return ties if any.
select dayname(order_datetime) as day_name, count(order_id) as orders_count from orders
where status = 'paid'
group by day_name
order by orders_count desc;
-- Q9) Show the calendar days whose total orders (any status) exceed 3.
--     Use HAVING. Return (order_date, orders_count).
select dayname(order_datetime) as order_date, count(*) as orders_count from orders
group by order_date
having count(*)>3;
-- Q10) Per store, list payment_method and the number of PAID orders.
--      Return (store_id, payment_method, paid_orders_count).
select store_id, payment_method, count(*) as paid_orders_count from orders
where status = 'paid'
group by store_id, payment_method
order by store_id, payment_method;
-- Q11) Among PAID orders, what percent used 'app' as the payment_method?
--      Return a single row with pct_app_paid_orders (0–100).
Select 100 * sum(payment_method = 'app')/count(*) as pct_app_paid_orders from orders
where status = 'paid';
-- Q12) Busiest hour: for PAID orders, show (hour_of_day, orders_count) sorted desc.
Select hour(order_datetime) as hour_of_day, count(*) as orders_count from orders
where status = 'paid'
group by  hour_of_day
order by orders_count desc;

-- ================
