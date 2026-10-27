
-- выводит общее количество покупателей
SELECT COUNT(*) FROM customers;



-- 6.1. выводит топ 10 продавцов по общей выручке
SELECT
    CONCAT(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM employees e
JOIN sales s
    ON s.sales_person_id = e.employee_id
JOIN products p
    ON p.product_id = s.product_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY income DESC
LIMIT 10;


-- 6.2. выводит продавцов, у которых средняя выручка за сделку ниже общей
SELECT
    TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller,
    FLOOR(AVG(s.quantity * p.price))               AS average_income
FROM sales s
JOIN employees e ON e.employee_id = s.sales_person_id
JOIN products  p ON p.product_id  = s.product_id
GROUP BY e.employee_id, e.first_name, e.last_name
HAVING AVG(s.quantity * p.price) < (
    SELECT AVG(s2.quantity * p2.price)
    FROM sales s2
    JOIN products p2 ON p2.product_id = s2.product_id
)
ORDER BY average_income ASC;


-- 6.3. выводит выручку каждого продавца по дням недели
SELECT
    TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller,
    LOWER(TRIM(TO_CHAR(s.sale_date, 'day')))       AS day_of_week,
    FLOOR(SUM(s.quantity * p.price))               AS income
FROM sales s
JOIN employees e ON e.employee_id = s.sales_person_id
JOIN products  p ON p.product_id  = s.product_id
GROUP BY e.employee_id, e.first_name, e.last_name,
         EXTRACT(ISODOW FROM s.sale_date),
         LOWER(TRIM(TO_CHAR(s.sale_date, 'day')))
ORDER BY EXTRACT(ISODOW FROM s.sale_date), seller;
