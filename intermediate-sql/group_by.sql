-- ============================================
-- DataCamp: Intermediate SQL
-- Lesson 2: One Grouping Column (GROUP BY)
-- ============================================


-- FRAMEWORK: Three questions before writing a grouped aggregation query:
-- 1. By which column do we group?
-- 2. Which column(s) do we summarize?
-- 3. Which summary operation(s) do we apply?


-- ============================================
-- 1. CHECK UNIQUE VALUES BEFORE GROUPING
-- ============================================

-- Always inspect distinct values in your grouping column first.
-- This confirms what groups exist and catches unexpected data quality issues.

-- E-commerce: unique categories
SELECT DISTINCT category
FROM orders_int;

-- Ride-hailing: unique ride types
SELECT DISTINCT ride_type
FROM trips;


-- ============================================
-- 2. OVERALL SUMMARY (no grouping — recap from Lesson 1)
-- ============================================

SELECT
    COUNT(order_id)         AS order_count,
    COUNT(DISTINCT user_id) AS unique_user_count,
    SUM(amount)             AS total_revenue,
    AVG(amount)             AS avg_order_value
FROM orders_int;


-- ============================================
-- 3. GROUP BY — Break summary down by category
-- ============================================

-- Clause order: SELECT → FROM → GROUP BY → ORDER BY
-- GROUP BY is placed after FROM, before ORDER BY

-- E-commerce: summary by product category
SELECT
    category,
    COUNT(order_id)         AS order_count,
    COUNT(DISTINCT user_id) AS unique_user_count,
    SUM(amount)             AS total_revenue,
    AVG(amount)             AS avg_order_value
FROM orders_int
GROUP BY category;


-- ============================================
-- 4. ADDING ORDER BY TO SORTED RESULTS
-- ============================================

-- Sort by revenue ascending (default — lowest first)
SELECT
    category,
    COUNT(order_id)         AS order_count,
    COUNT(DISTINCT user_id) AS unique_user_count,
    SUM(amount)             AS total_revenue,
    AVG(amount)             AS avg_order_value
FROM orders_int
GROUP BY category
ORDER BY total_revenue;

-- Sort by revenue descending (highest first — most common for analysis)
SELECT
    category,
    COUNT(order_id)         AS order_count,
    COUNT(DISTINCT user_id) AS unique_user_count,
    SUM(amount)             AS total_revenue,
    AVG(amount)             AS avg_order_value
FROM orders_int
GROUP BY category
ORDER BY total_revenue DESC;


-- ============================================
-- 5. RIDE-HAILING EXAMPLES
-- ============================================

-- Summary metrics per ride type
SELECT
    ride_type,
    SUM(fare)      AS total_fare,
    AVG(fare)      AS avg_fare,
    COUNT(trip_id) AS trip_count
FROM trips
GROUP BY ride_type
ORDER BY trip_count DESC;    -- most popular ride type first

-- Unique riders per ride type (fewest first)
SELECT
    ride_type,
    COUNT(DISTINCT rider_id) AS unique_rider_count
FROM trips
GROUP BY ride_type
ORDER BY unique_rider_count;    -- ascending = fewest first


-- ============================================
-- 6. WHAT NOT TO DO — Poor grouping column choices
-- ============================================

-- BAD: Grouping by a numeric column with many unique values
-- Creates nearly as many groups as rows — no meaningful insight
SELECT
    amount,
    COUNT(order_id) AS order_count
FROM orders_int
GROUP BY amount;
-- Result: hundreds of groups, most with order_count = 1
-- Avoid this pattern — stick to discrete categories


-- ============================================
-- 7. CLAUSE ORDER — REQUIRED SEQUENCE
-- ============================================

-- SQL enforces strict clause ordering. Violating it causes a syntax error.
-- Correct order:
--   SELECT
--   FROM
--   GROUP BY
--   ORDER BY

-- WRONG (causes error: "Expected end of input but got keyword GROUP"):
-- SELECT category, SUM(amount) AS total_revenue
-- FROM orders_int
-- ORDER BY total_revenue DESC
-- GROUP BY category;

-- CORRECT:
SELECT
    category,
    SUM(amount) AS total_revenue
FROM orders_int
GROUP BY category
ORDER BY total_revenue DESC;


-- ============================================
-- NOTE: SPLIT-APPLY-COMBINE (behind the scenes)
-- ============================================
-- When GROUP BY runs, SQL performs three steps automatically:
-- 1. SPLIT   — rows are divided into groups by the grouping column
-- 2. APPLY   — aggregate functions run independently on each group
-- 3. COMBINE — group results are assembled into one summary table
--
-- Understanding this helps when debugging unexpected results
-- or optimising GROUP BY queries in PostgreSQL.
