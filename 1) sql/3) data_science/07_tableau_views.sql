-- Main Sales View for Dashboards: one row per sales line with its calendar and product attributes
CREATE OR REPLACE VIEW analytics.v_tableau_sales AS
SELECT
    fs.date,
    d.year,
    d.month,
    d.day,
    d.year_month,
    d.quarter,

    fs.SalesID,
    fs.CustomerID,

    p.ProductID,
    p.ProductName,
    p.CategoryName,

    fs.Quantity,
    fs.revenue

FROM analytics.fact_sales fs

-- LEFT JOIN keeps the sales without a date, so revenue totals in Tableau match fact_sales
LEFT JOIN analytics.dim_date d
    ON d.date = fs.date

JOIN analytics.dim_product p
    ON fs.ProductID = p.ProductID;

-- Monthly aggregate view for trend charts.
-- The inner join with dim_date drops the ~1% of undated sales, so its total is slightly
-- below fact_sales (the notebook reconciles the difference).
CREATE OR REPLACE VIEW analytics.v_tableau_sales_monthly AS
SELECT
    d.year,
    d.month,
    d.year_month,
    p.CategoryName,

    SUM(fs.Quantity) AS total_quantity,
    SUM(fs.revenue) AS total_revenue

FROM analytics.fact_sales fs

JOIN analytics.dim_date d
    ON d.date = fs.date

JOIN analytics.dim_product p
    ON fs.ProductID = p.ProductID

GROUP BY
    d.year,
    d.month,
    d.year_month,
    p.CategoryName

ORDER BY
    d.year,
    d.month;


-- Top Products View
CREATE OR REPLACE VIEW analytics.v_tableau_top_products AS
SELECT
    p.ProductName,
    p.CategoryName,
    SUM(fs.Quantity) AS total_units_sold,
    SUM(fs.revenue) AS total_revenue
 
FROM analytics.fact_sales fs

JOIN analytics.dim_product p
    ON fs.ProductID = p.ProductID

GROUP BY
    p.ProductName,
    p.CategoryName

ORDER BY
    total_revenue DESC;