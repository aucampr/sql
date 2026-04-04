-- ============================================
-- DataCamp: Intermediate SQL
-- Lesson 5: Complex Transformations
-- ============================================


-- This lesson covers four key techniques:
-- 1. Multi-step calculations using the WITH clause (CTEs)
-- 2. Scalar subqueries for aggregate values in row-level calculations
-- 3. Percent of total
-- 4. ROUND() and transformation functions


-- ============================================
-- 1. ORDER OF OPERATIONS & PARENTHESES
-- ============================================

-- SQL follows standard arithmetic precedence:
-- * and / execute BEFORE + and -
-- When in doubt, add parentheses — they cost nothing and prevent bugs

-- WITHOUT parentheses (wrong result — only ad_spend is divided)
SELECT *,
    revenue - ad_spend / paid_orders AS gross_profit_per_order  -- BUG!
FROM campaign_performance;

-- WITH parentheses (correct — revenue minus ad_spend first, then divide)
SELECT *,
    (revenue - ad_spend) / NULLIF(paid_orders, 0) AS gross_profit_per_order
FROM campaign_performance;

-- Complex formula — parentheses make intent clear even when not required
SELECT *,
    revenue - ad_spend - (paid_orders * avg_fulfillment_cost) AS ad_contribution
FROM campaign_performance;


-- ============================================
-- 2. THE ALIAS-IN-SAME-SELECT LIMITATION
-- ============================================

-- SQL CANNOT reference a column alias in the same SELECT where it's defined
-- This causes an error: "Unrecognized name: ad_contribution"

-- WRONG — trying to use ad_contribution in the same SELECT that creates it:
-- SELECT *,
--     revenue - ad_spend - (paid_orders * avg_fulfillment_cost) AS ad_contribution,
--     SAFE_DIVIDE(100 * ad_contribution, revenue) AS contribution_rate  -- ERROR
-- FROM campaign_performance;

-- Workaround 1: repeat the formula (works but messy and error-prone)
SELECT *,
    revenue - ad_spend - (paid_orders * avg_fulfillment_cost) AS ad_contribution,
    SAFE_DIVIDE(
        100 * (revenue - ad_spend - (paid_orders * avg_fulfillment_cost)),
        revenue
    ) AS contribution_rate
FROM campaign_performance;


-- ============================================
-- 3. WITH CLAUSE (CTE — Common Table Expression)
-- ============================================

-- The WITH clause creates a named temporary result from a query.
-- The final SELECT queries FROM that temporary table, not the original.
-- Aliases created in the WITH step can be referenced directly in the final SELECT.
-- This pattern is also called a CTE (Common Table Expression).

-- Structure:
-- WITH cte_name AS (
--     SELECT *, formula AS intermediate_column
--     FROM original_table
-- )
-- SELECT *, formula_using_intermediate AS final_column
-- FROM cte_name;

-- Marketing example: ad_contribution → contribution_rate
WITH campaign_performance_extended AS (
    SELECT *,
        revenue - ad_spend - (paid_orders * avg_fulfillment_cost) AS ad_contribution
    FROM campaign_performance
)
SELECT *,
    SAFE_DIVIDE(100 * ad_contribution, revenue) AS contribution_rate
FROM campaign_performance_extended;

-- PostgreSQL equivalent (NULLIF instead of SAFE_DIVIDE):
WITH campaign_performance_extended AS (
    SELECT *,
        revenue - ad_spend - (paid_orders * avg_fulfillment_cost) AS ad_contribution
    FROM campaign_performance
)
SELECT *,
    100 * ad_contribution / NULLIF(revenue, 0) AS contribution_rate
FROM campaign_performance_extended;


-- Trading example: margin → margin_ratio
WITH trade_margins AS (
    SELECT *,
        (sell_price * quantity) - fees - (quantity * avg_buy_price) AS margin
    FROM trades
)
SELECT *,
    100 * margin / NULLIF(quantity * avg_buy_price, 0) AS margin_ratio
FROM trade_margins;

-- Results:
-- TSLA: margin_ratio = +163.64%  (best performer)
-- NVDA: margin_ratio = +124.9%
-- AMZN: margin_ratio = -23.4%   (loss)


-- ============================================
-- 4. SCALAR SUBQUERIES FOR PERCENT OF TOTAL
-- ============================================

-- Aggregate functions (SUM, AVG, COUNT) collapse rows into one value.
-- You cannot use them directly alongside non-aggregated columns in SELECT
-- without GROUP BY — SQL doesn't know whether to collapse or preserve rows.

-- A SCALAR SUBQUERY is a query nested inside another query
-- that returns a single value. It runs independently and makes
-- that value available to every row in the outer query.

-- Percent of Total formula:
-- pot = 100 * value / SUM(all values)

-- Revenue and Margin percent of total:
SELECT *,
    ROUND(SAFE_DIVIDE(100 * revenue, (SELECT SUM(revenue) FROM category_sales)), 2) AS revenue_pot,
    ROUND(SAFE_DIVIDE(100 * margin,  (SELECT SUM(margin)  FROM category_sales)), 2) AS margin_pot
FROM category_sales;

-- PostgreSQL equivalent:
SELECT *,
    ROUND(100 * revenue / NULLIF((SELECT SUM(revenue) FROM category_sales), 0), 2) AS revenue_pot,
    ROUND(100 * margin  / NULLIF((SELECT SUM(margin)  FROM category_sales), 0), 2) AS margin_pot
FROM category_sales;

-- Portfolio value percent of total:
SELECT *,
    ROUND(SAFE_DIVIDE(100 * value, (SELECT SUM(value) FROM portfolio)), 2) AS value_pot
FROM portfolio;


-- ============================================
-- 5. ROUND() FUNCTION
-- ============================================

-- ROUND(expression, decimal_places)
-- Controls precision and reduces visual noise in results

-- Round to nearest integer (loses precision)
SELECT *, ROUND(revenue_pot, 0) AS revenue_pot_rounded FROM category_sales;

-- Round to 2 decimal places (recommended — readable yet precise)
SELECT *, ROUND(revenue_pot, 2) AS revenue_pot_rounded FROM category_sales;

-- Inline with calculation:
SELECT *,
    ROUND(100 * revenue / NULLIF((SELECT SUM(revenue) FROM category_sales), 0), 2) AS revenue_pot
FROM category_sales;


-- ============================================
-- 6. IMPORTANT: PERCENTAGES CAN EXCEED 100%
-- ============================================

-- When negative values exist in the data, the denominator (total) shrinks.
-- Positive values then represent a LARGER share of that smaller total,
-- causing individual percentages to exceed 100%.

-- Example: Total margin = 45k + 28k + 55k - 20k - 30k = $78k (not $198k)
-- Shoes margin_pot = 100 * 55k / 78k = 70.51% (not ~28%)
-- Sportswear margin_pot = 100 * 45k / 78k = 57.69%
-- Both together = 128.2% — more than 100% because losses reduce the denominator

-- Rule: always check for negative values before interpreting percentage metrics.


-- ============================================
-- COMPLETE TEMPLATE — MULTI-STEP WITH CTE
-- ============================================

-- Generic pattern for any two-step transformation:
WITH step_1 AS (
    SELECT *,
        (col_a * col_b) - col_c AS intermediate
    FROM table_name
)
SELECT *,
    100 * intermediate / NULLIF(col_a * col_b, 0) AS ratio
FROM step_1;

-- Generic pattern for percent of total:
SELECT *,
    ROUND(
        100 * col_a / NULLIF((SELECT SUM(col_a) FROM table_name), 0),
        2
    ) AS col_a_pot
FROM table_name;


-- ============================================
-- NOTE ON BIGQUERY vs POSTGRESQL
-- ============================================
-- SAFE_DIVIDE(numerator, denominator) → BigQuery only
-- NULLIF(denominator, 0)              → Standard SQL, works in PostgreSQL
-- Both return NULL on division by zero — functionally equivalent
-- PostgreSQL users: always use NULLIF approach
