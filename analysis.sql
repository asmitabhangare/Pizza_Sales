CREATE DATABASE pizzahut;
use pizzahut;

-- Retrieve the total number of orders placed. 
SELECT 
    COUNT(*) AS Total_no_of_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(p.price * od.quantity), 2) AS total_revenue
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id;
    
-- Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(od.order_details_id) AS order_count
FROM
    order_details AS od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(od.quantity) AS Total_quantity
FROM
    order_details AS od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY Total_quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS Total_quantity
FROM
    order_details AS od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY Total_quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(time);

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS pizza_count
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(total_quantity), 0) AS avg_pizza_order
FROM
    (SELECT 
        o.date, SUM(od.quantity) AS total_quantity
    FROM
        orders AS o
    JOIN order_details AS od ON o.order_id = od.order_id
    GROUP BY o.date) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, ROUND(SUM(p.price * od.quantity), 2) AS total_revenue
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
WITH ct AS(
SELECT 
    ROUND(SUM(p.price * od.quantity), 2)
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id)
SELECT 
    pt.category, ROUND(SUM(p.price * od.quantity)*100/(SELECT * FROM ct), 2) AS percent
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category;

-- Analyze the cumulative revenue generated over time.
WITH ct AS(
SELECT 
    o.date,ROUND(SUM(p.price * od.quantity), 2) AS revenue
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
   JOIN orders o ON o.order_id = od.order_id
   GROUP BY o.date)
SELECT date, SUM(revenue) OVER (ORDER BY date) AS cum_revenue
FROM ct;
    
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
-- Determine the top 3 most ordered pizza types based on revenue.
WITH ct AS(
SELECT 
   pt.category, pt.name, ROUND(SUM(p.price * od.quantity), 2) AS revenue
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category,pt.name
ORDER BY revenue DESC),
ct2 AS(
SELECT category, name , revenue,
RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rk
FROM ct)
SELECT category, name,revenue
FROM ct2
WHERE rk <=3;