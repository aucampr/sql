-- ============================================
-- DataCamp: Intermediate SQL
-- Lesson 3: Multiple Grouping Columns
-- ============================================


-- FRAMEWORK: Three questions before writing any grouped query:
-- 1. By which column(s) do we group?      ← now can be multiple
-- 2. Which column(s) do we summarise?
-- 3. Which summary operation(s) do we apply?


-- ============================================
-- 1. CHECK UNIQUE COMBINATIONS BEFORE GROUPING
-- ============================================

-- Best practice: always inspect distinct combinations first
-- This tells you how many rows to expect in your summary
-- and catches missing or unexpected combinations early

-- E-commerce: unique combinations of location and category
SELECT DISTINCT location,
               category
FROM orders;
-- Result: 8 rows (2 locations × 4 categories)

-- Ride-hailing: unique combinations of city and ride_type
SELECT DISTINCT city,
               ride_type
FROM trips;
-- Result: 12 rows (3 cities × 4 ride types)


-- ============================================
-- 2. SINGLE-COLUMN GROUP BY (recap from Lesson 2)
-- ============================================

-- Summary by category only
SELECT
    category,
    COUNT(order_id)         AS order_count,
    COUNT(DISTINCT user_id) AS user_count,
    SUM(amount)             AS revenue,
    AVG(amount)             AS avg_order_value
FROM orders
GROUP BY category;


-- ============================================
-- 3. MULTI-COLUMN GROUP BY
-- ============================================

-- KEY RULE: All non-aggregated columns in SELECT
-- must appear in the GROUP BY clause

-- E-commerce: summary by location AND category
SELECT
    location,
    category,
    COUNT(order_id)         AS order_count,
    COUNT(DISTINCT user_id) AS user_count,
    SUM(amount)             AS revenue,
    AVG(amount)             AS avg_order_value
FROM orders
GROUP BY location, category;
-- Result: 8 rows — one per location-category combination


-- Ride-hailing: summary by city AND ride_type
SELECT
    city,
    ride_type,
    AVG(fare)      AS avg_fare,
    COUNT(trip_id) AS trip_count
FROM trips
GROUP BY city, ride_type;
-- Result: 12 rows — one per city-ride_type combination


-- ============================================
-- 4. MULTI-COLUMN SORTING
-- ============================================

-- Sort by location first (ASC), then revenue within each location (DESC)
-- This groups all UK rows together, sorted by highest revenue first,
-- then all US rows together sorted the same way
SELECT
    location,
    category,
    COUNT(order_id)         AS order_count,
    COUNT(DISTINCT user_id) AS user_count,
    SUM(amount)             AS revenue,
    AVG(amount)             AS avg_order_value
FROM orders
GROUP BY location, category
ORDER BY location, revenue DESC;

-- Reversed sort order — revenue first, then location
-- Since each location-category has a unique revenue, location has no visible effect
SELECT
    location,
    category,
    COUNT(order_id)         AS order_count,
    COUNT(DISTINCT user_id) AS user_count,
    SUM(amount)             AS revenue,
    AVG(amount)             AS avg_order_value
FROM orders
GROUP BY location, category
ORDER BY revenue DESC, location;

-- Ride-hailing: sort by avg_fare descending across all combinations
SELECT
    city,
    ride_type,
    AVG(fare)      AS avg_fare,
    COUNT(trip_id) AS trip_count
FROM trips
GROUP BY city, ride_type
ORDER BY avg_fare DESC;

-- Ride-hailing: sort by city first, then avg_fare descending within each city
SELECT
    city,
    ride_type,
    AVG(fare)      AS avg_fare,
    COUNT(trip_id) AS trip_count
FROM trips
GROUP BY city, ride_type
ORDER BY city, avg_fare DESC;


-- ============================================
-- 5. GROUPING BY MANY COLUMNS
-- ============================================

-- You can group by as many columns as needed
-- But: each additional column multiplies the number of groups
-- and shrinks group sizes — reducing metric reliability
-- 2 locations × 4 categories × 3 months × 2 segments × 2 payment methods = 96 groups

SELECT
    location,
    category,
    order_month,
    customer_segment,
    payment_method,
    COUNT(order_id)         AS order_count,
    COUNT(DISTINCT user_id) AS user_count,
    SUM(amount)             AS revenue,
    AVG(amount)             AS avg_order_value
FROM orders
GROUP BY location, category, order_month, customer_segment, payment_method;


-- ============================================
-- 6. WHAT NOT TO DO
-- ============================================

-- BAD: Column in SELECT but NOT in GROUP BY (causes error)
-- "SELECT list expression references column category
--  which is neither grouped nor aggregated"
--
-- SELECT location, category, COUNT(order_id) AS order_count
-- FROM orders
-- GROUP BY location;   ← missing category → ERROR

-- BAD: Grouping by columns without selecting them (runs but misleading)
-- Results look like they're grouped by location only,
-- but are actually grouped by location + category
SELECT
    location,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY location, category;
-- Avoid this — always include all grouping columns in SELECT


-- BAD: Using column positions instead of names (works but fragile)
-- If you reorder SELECT columns, GROUP BY 1, 2 silently groups by wrong columns
SELECT
    location,
    category,
    SUM(amount) AS revenue
FROM orders
GROUP BY 1, 2;   -- works, but prefer column names for clarity and safety


-- ============================================
-- 7. METRIC RELIABILITY — ALWAYS CHECK GROUP SIZE
-- ============================================

-- Small groups produce unreliable metrics
-- A high average based on 10 orders is far less trustworthy
-- than the same average based on 320 orders

-- Always include a COUNT in your summary so readers can judge reliability
-- General guideline: aim for group sizes of 30+ for reliable summaries

SELECT
    location,
    category,
    COUNT(order_id)         AS order_count,    -- ← reliability indicator
    COUNT(DISTINCT user_id) AS user_count,
    SUM(amount)             AS revenue,
    AVG(amount)             AS avg_order_value
FROM orders
GROUP BY location, category
ORDER BY location, revenue DESC;
-- Check order_count before trusting avg_order_value for any group


-- ============================================
-- 8. MISSING GROUPS
-- ============================================

-- Groups with no data simply won't appear in results
-- SQL cannot create a row with zero data
-- When a group is missing, ask:
--   1. Data loss or query bug?
--   2. No activity occurred (valid — just zero)?
--   3. Impossible combination by definition?


-- ============================================
-- REQUIRED CLAUSE ORDER (reminder)
-- ============================================
-- SELECT → FROM → GROUP BY → ORDER BY
-- Violating this order causes a syntax error
