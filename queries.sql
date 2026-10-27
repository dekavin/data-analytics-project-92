
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




-- 7.1. выподит количество покупателей по возрастным группам: 16-25, 26-40, 40+
SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        WHEN age > 40              THEN '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers
WHERE age >= 16
GROUP BY age_category
ORDER BY age_category;



-- 7.2. выводит количество уникальных покупателей и выручка по месяцам
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM')       AS selling_month,
    COUNT(DISTINCT s.customer_id)         AS total_customers,
    FLOOR(SUM(s.quantity * p.price))      AS income
FROM sales s
JOIN products p ON p.product_id = s.product_id
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY selling_month ASC;

-- 7.3. выводит покупателей, первая покупка которых пришлась на время проведения специальных акций
SELECT
    TRIM(c.first_name) || ' ' || TRIM(c.last_name) AS customer,
    t.sale_date                                    AS sale_date,
    TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller
FROM (
    SELECT DISTINCT ON (s.customer_id)
        s.customer_id,
        s.sale_date,
        s.sales_person_id,
        p.price
    FROM sales s
    JOIN products p ON p.product_id = s.product_id
    ORDER BY s.customer_id, s.sale_date, s.sales_id
) t
JOIN customers c ON c.customer_id = t.customer_id
JOIN employees e ON e.employee_id = t.sales_person_id
WHERE t.price = 0
ORDER BY t.customer_id;
