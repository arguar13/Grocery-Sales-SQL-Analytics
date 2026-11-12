-- 1. Columns of fact_sales, to compare against the expected model
SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'analytics'
  AND table_name = 'fact_sales'
ORDER BY column_name;
 


-- 2. Duplicate lines: the same product more than once in the same transaction
SELECT
    TransactionNumber,
    ProductID,
    COUNT(*) AS duplicates
FROM analytics.fact_sales
GROUP BY
    TransactionNumber,
    ProductID
HAVING COUNT(*) > 1;


-- 3. Dates out of range
-- NOT BETWEEN returns NULL (not TRUE) for NULL dates, so missing dates are checked separately in 3b.
SELECT *
FROM analytics.fact_sales
WHERE date NOT BETWEEN '2010-01-01' AND CURRENT_DATE;


-- 3b. Missing dates
-- ~1% of the source sales have no SalesDate: they count in totals but are excluded from time-based analyses.
SELECT
    COUNT(*) AS rows_without_date,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM analytics.fact_sales), 2) AS pct_of_rows
FROM analytics.fact_sales
WHERE date IS NULL;


-- 4. Negative Revenue
SELECT *
FROM analytics.fact_sales
WHERE revenue < 0;


-- 5. Negative or zero quantities
SELECT *
FROM analytics.fact_sales
WHERE Quantity <= 0;


-- 6. Customer keys missing from dim_customer
SELECT fs.*
FROM analytics.fact_sales fs
LEFT JOIN analytics.dim_customer dc
       ON fs.CustomerID = dc.CustomerID
WHERE dc.CustomerID IS NULL;


-- 7. Product keys missing from dim_product
SELECT fs.*
FROM analytics.fact_sales fs
LEFT JOIN analytics.dim_product dp
       ON fs.ProductID = dp.ProductID
WHERE dp.ProductID IS NULL;


-- 8. Invalid discounts (outside 0% - 100%)
SELECT *
FROM analytics.fact_sales
WHERE Discount < 0 OR Discount > 1;


-- 9. Employee keys missing from dim_employee
SELECT fs.*
FROM analytics.fact_sales fs
LEFT JOIN analytics.dim_employee de
       ON fs.EmployeeID = de.EmployeeID
WHERE de.EmployeeID IS NULL;


-- 10. Source TotalPrice vs derived revenue
-- The source TotalPrice column is always 0, which is why revenue is derived in the ETL
-- (Quantity * Price * (1 - Discount)). This check documents that assumption.
SELECT
    COUNT(*) FILTER (WHERE TotalPrice = 0) AS rows_with_zero_totalprice,
    COUNT(*) FILTER (WHERE revenue = 0)    AS rows_with_zero_revenue,
    COUNT(*)                               AS total_rows
FROM analytics.fact_sales;