-- ============================================
-- DataCamp: Intermediate SQL
-- Lesson 4: Basic Transformations
-- ============================================


-- Data transformation creates NEW columns from existing ones
-- by applying formulas or functions — row by row.
-- The source data is never changed.


-- ============================================
-- 1. BASIC ARITHMETIC TRANSFORMATIONS
-- ============================================

-- Pattern: SELECT *, formula AS new_column_name FROM table;
-- SELECT * keeps all existing columns; formula adds a new one

-- Currency conversion: USD → EUR (rate: 1 USD = 0.92 EUR)
SELECT *,
    ad_spend_usd * 0.92 AS ad_spend_eur
FROM campaign_spend;

-- Multiple transformations in one query — separate with commas
SELECT *,
    ad_spend_usd * 0.92  AS ad_spend_eur,
    ad_spend_usd * 1.09  AS ad_spend_gbp    -- example: USD to GBP
FROM campaign_spend;

-- Arithmetic operators available: + - * /
-- Transformation is a ROW-LEVEL operation —
-- the formula runs independently for each row


-- ============================================
-- 2. PRACTICAL TRANSFORMATION — TRADING DATA
-- ============================================

-- Net sale amount: total revenue from sale minus fees
-- Formula: (sell_price * quantity) - fees
SELECT *,
    (sell_price * quantity) - fees AS net_sale_amount
FROM trades;

-- Example result for NVDA:
-- 80 shares × $450 = $36,000 − $20 fees = $35,980 net


-- ============================================
-- 3. RATIO CALCULATIONS
-- ============================================

-- Ratios divide one value by another to reveal efficiency/performance
-- They expose patterns that raw numbers alone hide

-- Paid Conversion Rate (pCVR): % of visitors who placed an order
-- Formula: 100 * paid_orders / paid_sessions
SELECT *,
    100 * paid_orders / paid_sessions AS pcvr
FROM campaign_performance
ORDER BY campaign_day;

-- Cost per Order (CPO): ad spend required to acquire one order
-- Formula: ad_spend / paid_orders
SELECT *,
    100 * paid_orders / paid_sessions AS pcvr,
    ad_spend / paid_orders            AS cpo
FROM campaign_performance
ORDER BY campaign_day;
-- WARNING: day 7 has 0 orders → division by zero error!


-- ============================================
-- 4. HANDLING DIVISION BY ZERO
-- ============================================

-- Option A: NULLIF — standard SQL (works in PostgreSQL + all databases)
-- NULLIF(expr, value) returns NULL if expr = value, else returns expr
-- Dividing by NULL returns NULL (not an error)

SELECT *,
    100 * paid_orders / NULLIF(paid_sessions, 0) AS pcvr,
    ad_spend          / NULLIF(paid_orders, 0)   AS cpo
FROM campaign_performance
ORDER BY campaign_day;
-- Day 7 now shows NULL for cpo instead of throwing an error


-- Option B: SAFE_DIVIDE — BigQuery-specific (NOT available in PostgreSQL)
-- Cleaner syntax, same result — returns NULL on division by zero
SELECT *,
    SAFE_DIVIDE(100 * paid_orders, paid_sessions) AS pcvr,
    SAFE_DIVIDE(ad_spend, paid_orders)            AS cpo
FROM campaign_performance
ORDER BY campaign_day;

-- PostgreSQL users: always use NULLIF
-- BigQuery users:   prefer SAFE_DIVIDE for readability


-- ============================================
-- 5. TRADING RATIOS — PRACTICE EXAMPLES
-- ============================================

-- Return Multiple: how many times over you got your money back
-- Formula: sell_price / avg_buy_price
-- e.g. 1.5 = 1.5x return (50% gain), 0.8 = 80% back (20% loss)

-- Price Change Ratio: % change from buy price to sell price
-- Formula: 100 * (sell_price - avg_buy_price) / avg_buy_price

SELECT *,
    sell_price / NULLIF(avg_buy_price, 0)                          AS return_multiple,
    100 * (sell_price - avg_buy_price) / NULLIF(avg_buy_price, 0)  AS price_change_ratio
FROM trades;

-- Example results:
-- TSLA: 2.64x return → +163.64%  (best performer)
-- NVDA: 2.25x return → +125%
-- AMZN: 0.77x return → -23.08%   (loss)
-- KO:   0.97x return → -3.23%    (small loss)


-- ============================================
-- 6. IMPORTANT: SMALL SAMPLE SIZE WARNING
-- ============================================

-- Ratios become unreliable with small denominators.
-- Day 1 pCVR = 50% (1 order from 2 sessions)
-- Day 7 pCVR = 0%  (0 orders from 2 sessions)
-- The 50-point swing is caused by just ONE order difference.
--
-- Rule: always check the denominator size before trusting a ratio.
-- Small samples produce dramatic but potentially misleading results.
-- Aim for denominator sizes of 30+ for reliable ratio metrics.


-- ============================================
-- SUMMARY — KEY PATTERNS
-- ============================================

-- Basic transformation:
--   SELECT *, column * factor AS new_column FROM table;

-- Ratio:
--   SELECT *, numerator / NULLIF(denominator, 0) AS ratio FROM table;

-- Multiple transformations:
--   SELECT *,
--       col_a * 0.92                              AS col_a_eur,
--       col_b / NULLIF(col_c, 0)                  AS efficiency_rate,
--       100 * (col_d - col_e) / NULLIF(col_e, 0)  AS pct_change
--   FROM table;

-- Clause order (unchanged):
-- SELECT → FROM → ORDER BY
