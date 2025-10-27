USE coffeeshop_db;

-- =========================================================
-- JOINS & RELATIONSHIPS PRACTICE
-- =========================================================

-- Q1) Join products to categories: list product_name, category_name, price.
select products.name as product_name, categories.name as category_name, products.price from products
join categories on products.category_id = categories.category_id;
-- Q2) For each order item, show: order_id, order_datetime, store_name,
--     product_name, quantity, line_total (= quantity * products.price).
--     Sort by order_datetime, then order_id.
select orders.order_id, orders.order_datetime, stores.name as store_name, 
products.name as product_name, order_items.quantity, (order_items.quantity * products.price) as line_total
from order_items
Join orders on order_items.order_id = orders.order_id
Join products on order_items.product_id = products.product_id
Join stores on orders.store_id = stores.store_id
Order by order_datetime, order_id;
-- Q3) Customer order history (PAID only):
--     For each order, show customer_name, store_name, order_datetime,
--     order_total (= SUM(quantity * products.price) per order).
select concat_ws(customers.first_name ,' ', customers.last_name) as customer_name,
stores.name as store_name, orders.order_datetime, sum(order_items.quantity * products.price) as order_total 
from orders
Join customers on orders.customer_id = customers.customer_id
Join stores on orders.store_id = stores.store_id
join order_items on orders.order_id = order_items.order_id
join products on order_items.product_id = products.product_id
where orders.status = 'paid'
group by orders.order_id, customers.first_name, customers.last_name, stores.name, orders.order_datetime
order by orders.order_datetime desc;
-- Q4) Left join to find customers who have never placed an order.
--     Return first_name, last_name, city, state.
select customers.first_name, customers.last_name, customers.city, customers.state from customers
left join orders on customers.customer_id = orders.customer_id
where orders.order_id is null;
-- Q5) For each store, list the top-selling product by units (PAID only).
--     Return store_name, product_name, total_units.
--     Hint: Use a window function (ROW_NUMBER PARTITION BY store) or a correlated subquery.
with products_sold as (select stores.name as store_name, products.name as product_name,
 sum(order_items.quantity) as total_units from order_items
join orders on order_items.order_id = orders.order_id
join stores on orders.store_id = stores.store_id
join products on order_items.product_id = products.product_id
where orders.status = 'paid'
group by stores.store_id, products.product_id),
ranked_sales as ( select store_name, product_name, total_units,
row_number() over(partition by store_name order by total_units desc) as rn
from products_sold)
select store_name, product_name, total_units from ranked_sales
where rn = 1 
order by store_name;
-- Q6) Inventory check: show rows where on_hand < 12 in any store.
--     Return store_name, product_name, on_hand.
select stores.name as store_name, products.name as product_name, inventory.on_hand 
from inventory
join stores on inventory.store_id = stores.store_id
join products on inventory.product_id = products.product_id
where inventory.on_hand < 12
order by store_name, product_name, on_hand; 
-- Q7) Manager roster: list each store's manager_name and hire_date.
--     (Assume title = 'Manager').
select stores.name as store_name, concat(employees.first_name,' ', employees.last_name) as manager_name,
employees.hire_date from employees
join stores on employees.store_id = stores.store_id
where employees.title = 'Manager'
order by store_name;
-- Q8) Using a subquery/CTE: list products whose total PAID revenue is above
--     the average PAID product revenue. Return product_name, total_revenue.
with product_revenue as (
  Select products.product_id, products.name as product_name,
  sum(order_items.quantity * products.price) as total_revenue
  from order_items
  Join orders on order_items.order_id = orders.order_id
  join products on order_items.product_id = products.product_id
  where orders.status = 'paid'
  group by products.product_id, products.name),
  avg_revenue as (
	select avg(total_revenue) as avg_rev
    from product_revenue)
    select product_revenue.product_name, product_revenue.total_revenue
    from product_revenue
    join avg_revenue on product_revenue.total_revenue = avg_revenue.avg_rev
    order by product_revenue.total_revenue desc;
-- Q9) Churn-ish check: list customers with their last PAID order date.
--     If they have no PAID orders, show NULL.
--     Hint: Put the status filter in the LEFT JOIN's ON clause to preserve non-buyer rows.
select customers.first_name, customers.last_name,
max(orders.order_datetime) as last_paid_order
from customers
left join orders
 on customers.customer_id = orders.customer_id
 and orders.status = 'paid'
 group by customers.customer_id, customers.first_name, customers.last_name
 order by last_paid_order;
-- Q10) Product mix report (PAID only):
--     For each store and category, show total units and total revenue (= SUM(quantity * products.price)).
select stores.name as store_name, categories.name as category_name,
sum(order_items.quantity) as total_units,
sum(order_items.quantity * products.price) as total_revenue
from order_items
join orders on order_items.order_id = orders.order_id
join stores on orders.store_id = stores.store_id
join products on order_items.product_id = products.product_id
join categories on products.category_id = categories.category_id
where orders.status = 'paid'
group by stores.store_id, categories.category_id, store_name, category_name
order by store_name, category_name;