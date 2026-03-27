-- ============================================
-- DataCamp: Introduction to SQL
-- Lesson 3: DISTINCT, Aliases & PostgreSQL
-- ============================================


-- 1. SELECTING ALL VALUES (includes duplicates)
-- This returns every category for every product row
SELECT category
FROM products;


-- 2. REMOVING DUPLICATES WITH DISTINCT
-- DISTINCT filters out repeated values, returning only unique entries
SELECT DISTINCT category
FROM products;


-- 3. DISTINCT ON MULTIPLE COLUMNS
-- Returns unique combinations of both columns
SELECT DISTINCT category, brand
FROM products;


-- 4. RENAMING COLUMNS WITH AS (ALIASES)
-- AS assigns a descriptive display name to the output column
-- Note: the alias only affects the output, not the actual column in the database
SELECT DISTINCT category AS unique_categories
FROM products;


-- 5. ALIAS BEST PRACTICES
-- Use snake_case: lowercase letters with underscores between words
-- Good:  unique_categories, customer_cities, total_orders
-- Avoid: UniqueCategories, uc, UNIQUE_CATEGORIES


-- ============================================
-- PRACTICE QUERIES (Customers Table)
-- ============================================

-- Find all unique cities where customers live
SELECT DISTINCT city
FROM customers;

-- Find unique cities with a descriptive alias
SELECT DISTINCT city AS customer_cities
FROM customers;


-- ============================================
-- COMBINING CONCEPTS FROM ALL THREE LESSONS
-- ============================================

-- SELECT + DISTINCT + ORDER BY
-- Unique categories sorted alphabetically
SELECT DISTINCT category AS unique_categories
FROM products
ORDER BY category;

-- SELECT specific columns + ORDER BY + LIMIT
-- Top 5 highest rated products with name and category
SELECT name, category, rating
FROM products
ORDER BY rating DESC
LIMIT 5;

-- Full example combining all concepts:
-- Top 10 most expensive products, showing unique brands
SELECT DISTINCT brand AS top_brands
FROM products
ORDER BY brand
LIMIT 10;


-- ============================================
-- POSTGRESQL-SPECIFIC NOTES
-- ============================================

-- PostgreSQL uses LIMIT (same as learned in this course)
-- Some other databases differ, e.g.:
--   SQL Server uses: SELECT TOP(10) ...
--   Oracle uses:     FETCH FIRST 10 ROWS ONLY

-- PostgreSQL is NOT case-sensitive for keywords, table names, and column names
-- All of these are equivalent in PostgreSQL:
--   SELECT DISTINCT category FROM products;
--   select distinct category from products;
--   Select Distinct Category From Products;

-- Convention: always write SQL keywords in UPPERCASE for readability
