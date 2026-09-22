-- =====================================================================
-- Sample business-question queries against the star schema.
-- Written in standard SQL; tested against both PostgreSQL and SQLite
-- (see accompanying iphone_sales_analytics.db for a working demo).
-- =====================================================================

-- 1. Total proxy revenue and order count by country
SELECT c.country,
       COUNT(*)                         AS orders,
       SUM(fs.revenue_proxy_usd)        AS revenue_proxy_usd,
       ROUND(AVG(fs.discount_percentage),1) AS avg_discount_pct
FROM fact_sales fs
JOIN dim_customer c ON c.customer_id = fs.customer_id
GROUP BY c.country
ORDER BY revenue_proxy_usd DESC;

-- 2. Revenue proxy by iPhone Series (Standard / Pro / Pro Max)
SELECT p.series,
       COUNT(*)                    AS orders,
       SUM(fs.revenue_proxy_usd)   AS revenue_proxy_usd,
       ROUND(100.0 * SUM(fs.revenue_proxy_usd) / SUM(SUM(fs.revenue_proxy_usd)) OVER (), 1) AS pct_of_revenue
FROM fact_sales fs
JOIN dim_product p ON p.product_id = fs.product_id
GROUP BY p.series
ORDER BY revenue_proxy_usd DESC;

-- 3. Marketing funnel efficiency by channel
SELECT campaign_channel,
       SUM(marketing_spend_usd) AS spend,
       SUM(conversions)         AS conversions,
       ROUND(SUM(marketing_spend_usd) / NULLIF(SUM(conversions),0), 2) AS blended_cac_usd
FROM fact_marketing
GROUP BY campaign_channel
ORDER BY blended_cac_usd ASC;

-- 4. Existing vs new Apple customers — order count and average discount
SELECT c.existing_apple_customer,
       COUNT(*) AS orders,
       ROUND(AVG(fs.discount_percentage),1) AS avg_discount_pct,
       ROUND(AVG(fs.effective_price_usd),2) AS avg_effective_price_usd
FROM fact_sales fs
JOIN dim_customer c ON c.customer_id = fs.customer_id
GROUP BY c.existing_apple_customer;

-- 5. Trade-in participation rate (orders with a trade-in / total orders)
SELECT
    COUNT(DISTINCT ft.order_id) AS orders_with_tradein,
    (SELECT COUNT(*) FROM fact_sales) AS total_orders,
    ROUND(100.0 * COUNT(DISTINCT ft.order_id) / (SELECT COUNT(*) FROM fact_sales), 1) AS tradein_participation_pct
FROM fact_tradein ft;

-- 6. Apple market share trend by country (latest month available)
SELECT country, month, apple_market_share_pct, samsung_market_share_pct
FROM dim_market
WHERE month = (SELECT MAX(month) FROM dim_market)
ORDER BY apple_market_share_pct DESC;

-- 7. Inventory: closing stock and coverage by store (top 10 by closing stock)
SELECT store_id, product_id, month, closing_stock, stock_days, stock_status
FROM fact_inventory
ORDER BY closing_stock DESC
LIMIT 10;

-- 8. Data-quality style query: orphan-key check (should always return 0 rows)
SELECT fs.order_id
FROM fact_sales fs
LEFT JOIN dim_customer c ON c.customer_id = fs.customer_id
WHERE c.customer_id IS NULL;
