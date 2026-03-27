-- ============================================
-- DataCamp: Intermediate SQL
-- Lesson 1: Summary Values (Aggregation)
-- ============================================


-- FRAMEWORK: Before writing any aggregation query, ask:
-- 1. Which column do I want to summarize?
-- 2. Which summary operation do I want to apply?


-- ============================================
-- 1. PREVIEWING DATA
-- ============================================

-- Always preview before querying — understand structure first
SELECT *
FROM orders_int
LIMIT 10;

-- Select only the columns you need (better for performance)
SELECT order_id, user_id, amount
FROM orders_int
LIMIT 10;


-- ============================================
-- 2. SUM() — Total of all values
-- ============================================

-- Total revenue from all orders_int
SELECT SUM(amount) AS total_revenue
FROM orders_int;

-- Total distance traveled from all trips
SELECT SUM(distance) AS total_distance
FROM trips;

-- Total fare from all trips
SELECT SUM(fare) AS total_fare
FROM trips;


-- ============================================
-- 3. MIN() and MAX() — Smallest and largest values
-- ============================================

-- Smallest order amount
SELECT MIN(amount) AS min_order_amount
FROM orders_int;

-- Largest order amount
SELECT MAX(amount) AS max_order_amount
FROM orders_int;


-- ============================================
-- 4. AVG() — Average (mean) of all values
-- ============================================

-- Average order amount
SELECT AVG(amount) AS avg_order_amount
FROM orders_int;

-- Average fare per trip
SELECT AVG(fare) AS avg_fare
FROM trips;


-- ============================================
-- 5. COUNT() — Count rows or values
-- ============================================

-- Total number of orders_int
SELECT COUNT(order_id) AS order_count
FROM orders_int;

-- Total number of trips
SELECT COUNT(trip_id) AS trip_count
FROM trips;


-- ============================================
-- 6. COUNT(DISTINCT) — Count unique values only
-- ============================================

-- NOTE: Use COUNT(DISTINCT column) when one entity can appear
-- multiple times — e.g. one user can place many orders_int

-- Number of unique users who placed orders_int
SELECT COUNT(DISTINCT user_id) AS unique_user_count
FROM orders_int;

-- Number of unique riders who took trips
SELECT COUNT(DISTINCT rider_id) AS unique_rider_count
FROM trips;

-- Number of unique drivers
SELECT COUNT(DISTINCT driver_id) AS unique_driver_count
FROM trips;


-- ============================================
-- 7. MULTIPLE AGGREGATIONS IN ONE QUERY
-- ============================================

-- More efficient than running separate queries — one pass, one result
-- E-commerce: full order summary
SELECT
    COUNT(order_id)         AS order_count,
    COUNT(DISTINCT user_id) AS unique_user_count,
    SUM(amount)             AS total_revenue,
    AVG(amount)             AS avg_order_amount,
    MIN(amount)             AS min_order_amount,
    MAX(amount)             AS max_order_amount
FROM orders_int;

-- Ride-hailing: full trips summary
SELECT
    COUNT(trip_id)            AS trip_count,
    COUNT(DISTINCT rider_id)  AS unique_rider_count,
    COUNT(DISTINCT driver_id) AS unique_driver_count,
    SUM(fare)                 AS total_fare,
    AVG(fare)                 AS avg_fare
FROM trips;


-- ============================================
-- ALIAS BEST PRACTICES (snake_case convention)
-- ============================================

-- Good aliases:
--   total_revenue, avg_query_time, unique_rider_count
-- Avoid:
--   TotalRevenue, tr, TOTAL_REV

-- ============================================
-- NOTE ON SQL FLAVORS
-- ============================================
-- This lesson uses BigQuery SQL syntax.
-- Core aggregation functions (SUM, AVG, MIN, MAX, COUNT)
-- are identical in PostgreSQL — 100% transferable.
-- Main difference: table references
--   BigQuery:    project.dataset.table
--   PostgreSQL:  schema.table (or just table if default schema)
