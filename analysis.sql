-- ============================================================
-- E-Commerce Sales Analysis — SQL Queries
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- Author: Sebastian Rios · linkedin.com/in/juansebastianrios
-- Engine: SQLite
-- ============================================================
-- HOW TO RUN:
--   1. Run load_data.py first to create olist.db
--   2. Open olist.db with SQLite Viewer in VS Code
--   3. Run each query individually
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- LEVEL 1 · BASIC — SELECT, GROUP BY, ORDER BY
-- ────────────────────────────────────────────────────────────

-- Query 1: Order volume by status
-- Business question: What is the current distribution of order statuses?
SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- Query 2: Top 10 revenue-generating product categories
-- Business question: Which categories should we prioritize for promotions?
SELECT
    cm.product_category_name_english AS category,
    COUNT(DISTINCT oi.order_id)      AS total_orders,
    ROUND(SUM(oi.price), 2)          AS total_revenue,
    ROUND(AVG(oi.price), 2)          AS avg_price
FROM order_items oi
JOIN products p         ON oi.product_id = p.product_id
JOIN category_map cm    ON p.product_category_name = cm.product_category_name
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;


-- Query 3: Monthly order volume and revenue trend
-- Business question: How has the business grown over time?
SELECT
    STRFTIME('%Y-%m', order_purchase_timestamp) AS month,
    COUNT(*)                                     AS total_orders,
    ROUND(SUM(oi.price), 2)                      AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE order_status = 'delivered'
GROUP BY month
ORDER BY month;


-- ────────────────────────────────────────────────────────────
-- LEVEL 2 · INTERMEDIATE — JOINs, HAVING, Subqueries
-- ────────────────────────────────────────────────────────────

-- Query 4: States with highest order volume and average ticket
-- Business question: Where are our most valuable customers located?
SELECT
    c.customer_state                            AS state,
    COUNT(DISTINCT o.order_id)                  AS total_orders,
    ROUND(SUM(oi.price), 2)                     AS total_revenue,
    ROUND(AVG(oi.price), 2)                     AS avg_ticket
FROM orders o
JOIN customers c    ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY state
ORDER BY total_orders DESC
LIMIT 10;


-- Query 5: Average delivery time and its impact on review score
-- Business question: Does faster delivery lead to better reviews?
SELECT
    r.review_score,
    COUNT(*)                                                        AS total_orders,
    ROUND(AVG(
        JULIANDAY(o.order_delivered_customer_date) -
        JULIANDAY(o.order_purchase_timestamp)
    ), 1)                                                           AS avg_delivery_days,
    ROUND(AVG(
        JULIANDAY(o.order_estimated_delivery_date) -
        JULIANDAY(o.order_delivered_customer_date)
    ), 1)                                                           AS avg_days_before_estimate
FROM orders o
JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score DESC;


-- Query 6: Categories with high volume but low average review score
-- Business question: Which categories have a quality or logistics problem?
SELECT
    cm.product_category_name_english    AS category,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    ROUND(AVG(r.review_score), 2)       AS avg_review_score,
    ROUND(SUM(oi.price), 2)             AS total_revenue
FROM orders o
JOIN order_items oi  ON o.order_id = oi.order_id
JOIN products p      ON oi.product_id = p.product_id
JOIN category_map cm ON p.product_category_name = cm.product_category_name
JOIN reviews r       ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY category
HAVING total_orders > 500
ORDER BY avg_review_score ASC
LIMIT 10;


-- Query 7: Orders delivered late vs on time
-- Business question: What percentage of orders miss the estimated delivery date?
SELECT
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
        THEN 'On Time'
        ELSE 'Late'
    END                                         AS delivery_status,
    COUNT(*)                                    AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_status;


-- ────────────────────────────────────────────────────────────
-- LEVEL 3 · ADVANCED — CTEs, Window Functions
-- ────────────────────────────────────────────────────────────

-- Query 8: Revenue ranking by category using window functions
-- Business question: How does each category rank and what is its revenue share?
WITH category_revenue AS (
    SELECT
        cm.product_category_name_english    AS category,
        ROUND(SUM(oi.price), 2)             AS total_revenue
    FROM order_items oi
    JOIN products p         ON oi.product_id = p.product_id
    JOIN category_map cm    ON p.product_category_name = cm.product_category_name
    GROUP BY category
)
SELECT
    category,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC)                           AS revenue_rank,
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (), 2)       AS pct_of_total,
    ROUND(SUM(total_revenue) OVER (ORDER BY total_revenue DESC), 2)    AS running_total
FROM category_revenue
ORDER BY revenue_rank
LIMIT 15;


-- Query 9: Month-over-month revenue growth
-- Business question: What is our growth rate each month?
WITH monthly AS (
    SELECT
        STRFTIME('%Y-%m', o.order_purchase_timestamp)   AS month,
        ROUND(SUM(oi.price), 2)                         AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY month
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)                              AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0
        / LAG(revenue) OVER (ORDER BY month),
    2)                                                              AS mom_growth_pct
FROM monthly
ORDER BY month;


-- Query 10: Customer value segmentation (RFM simplified)
-- Business question: Who are our most valuable customers?
WITH customer_metrics AS (
    SELECT
        c.customer_unique_id,
        c.customer_state,
        COUNT(DISTINCT o.order_id)      AS frequency,
        ROUND(SUM(oi.price), 2)         AS monetary,
        MAX(o.order_purchase_timestamp) AS last_purchase
    FROM orders o
    JOIN customers c    ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id, c.customer_state
)
SELECT
    customer_unique_id,
    customer_state,
    frequency,
    monetary,
    last_purchase,
    CASE
        WHEN monetary >= 500  AND frequency >= 3 THEN 'High Value'
        WHEN monetary >= 200  AND frequency >= 2 THEN 'Mid Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customer_metrics
ORDER BY monetary DESC
LIMIT 20;
