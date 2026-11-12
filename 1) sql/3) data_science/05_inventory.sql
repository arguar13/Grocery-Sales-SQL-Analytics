-- PRODUCT SALES SUMMARY
SELECT
    p.ProductID,
    p.ProductName,
    SUM(fs.Quantity) AS total_units_sold
FROM analytics.fact_sales fs
JOIN analytics.dim_product p
     ON fs.ProductID = p.ProductID
GROUP BY
    p.ProductID,
    p.ProductName
ORDER BY total_units_sold DESC;


-- LOW DEMAND PRODUCTS
-- Products in the bottom 10% of units sold.
-- A relative threshold is used because a fixed one (e.g. < 10 units) depends on the data volume:
-- here every product sells tens of thousands of units, so a fixed threshold returns nothing.
WITH product_units AS (
    SELECT
        p.ProductID,
        p.ProductName,
        SUM(fs.Quantity) AS total_units_sold
    FROM analytics.fact_sales fs
    JOIN analytics.dim_product p
         ON fs.ProductID = p.ProductID
    GROUP BY
        p.ProductID,
        p.ProductName
)
SELECT
    ProductID,
    ProductName,
    total_units_sold
FROM product_units
WHERE total_units_sold <= (
    SELECT PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY total_units_sold)
    FROM product_units
)
ORDER BY total_units_sold;


-- SALES LAST 90 DAYS
-- The window is anchored to the last date in the data instead of CURRENT_DATE,
-- because the dataset is historical (2018) and CURRENT_DATE would return no rows.
SELECT
    fs.ProductID,
    p.ProductName,
    SUM(fs.Quantity) AS total_sold_90d
FROM analytics.fact_sales fs
JOIN analytics.dim_product p
     ON fs.ProductID = p.ProductID
WHERE fs.date > (SELECT MAX(date) FROM analytics.fact_sales) - INTERVAL '90 days'
GROUP BY
    fs.ProductID,
    p.ProductName
ORDER BY total_sold_90d DESC;


-- PRODUCT SALES BY CATEGORY
SELECT
    p.CategoryName,
    SUM(fs.Quantity) AS total_units_sold
FROM analytics.fact_sales fs
JOIN analytics.dim_product p
     ON fs.ProductID = p.ProductID
GROUP BY p.CategoryName
ORDER BY total_units_sold DESC;


-- PRODUCT SALES TREND (MONTHLY)
SELECT
    p.ProductName,
    TO_CHAR(fs.date,'YYYY-MM') AS year_month,
    SUM(fs.Quantity) AS monthly_units_sold
FROM analytics.fact_sales fs
JOIN analytics.dim_product p
     ON fs.ProductID = p.ProductID
WHERE fs.date IS NOT NULL
GROUP BY
    p.ProductName,
    year_month
ORDER BY
    p.ProductName,
    year_month;