-- ============================================
-- DataCamp: Introduction to SQL
-- Lesson 2: Write Your First SQL Queries
-- ============================================


-- 1. SELECT ALL COLUMNS FROM A TABLE
-- The * wildcard retrieves every column in the table
SELECT *
FROM products;


-- 2. SELECT A SINGLE COLUMN
-- Specify the column name after SELECT
SELECT name
FROM products;


-- 3. SELECT MULTIPLE COLUMNS
-- Separate column names with commas
SELECT id, name, rating
FROM products;


-- 4. SORTING WITH ORDER BY
-- Default sort is ascending (lowest to highest)
SELECT id, name, rating
FROM products
ORDER BY rating;


-- 5. SORTING IN DESCENDING ORDER
-- Use DESC to sort from highest to lowest
SELECT id, name, rating
FROM products
ORDER BY rating DESC;


-- 6. LIMITING RESULTS WITH LIMIT
-- Combine ORDER BY DESC + LIMIT to get top N rows
-- Example: Top 10 highest-rated products
SELECT id, name, rating
FROM products
ORDER BY rating DESC
LIMIT 10;


-- ============================================
-- PRACTICE QUERIES (Orders Table)
-- ============================================

-- Select all columns from orders
SELECT *
FROM orders;

-- Select specific columns from orders
SELECT order_id, total_amount, status
FROM orders;

-- Sort orders by total_amount ascending (lowest to highest)
SELECT *
FROM orders
ORDER BY total_amount;

-- Sort orders by total_amount descending (highest to lowest)
SELECT *
FROM orders
ORDER BY total_amount DESC;

-- Top 5 highest value orders
SELECT *
FROM orders
ORDER BY total_amount DESC
LIMIT 5;

-- 5 lowest value orders
SELECT *
FROM orders
ORDER BY total_amount
LIMIT 5;
