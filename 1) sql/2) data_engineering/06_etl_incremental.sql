-- INCREMENTAL LOAD FOR FACT_SALES
-- Inserts only the sales that are not in the fact table yet (safe to re-run).
-- Rows already loaded are never updated: corrections need 05_etl_full_load.sql.
INSERT INTO analytics.fact_sales
(
    SalesID,
    date,
    CustomerID,
    ProductID,
    EmployeeID,
    Quantity,
    Discount,
    TotalPrice,
    revenue,
    TransactionNumber
)

SELECT
    s.SalesID,
    DATE(s.SalesDate) AS date,
    s.CustomerID,
    s.ProductID,
    s.SalesPersonID AS EmployeeID,
    s.Quantity,
    COALESCE(s.Discount, 0) AS Discount,
    s.TotalPrice,

    -- Same revenue rule as the full load
    ROUND(s.Quantity * p.Price * (1 - COALESCE(s.Discount, 0)), 2) AS revenue,

    s.TransactionNumber

FROM public.sales s
JOIN public.products p
     ON s.ProductID = p.ProductID

WHERE NOT EXISTS (
    SELECT 1
    FROM analytics.fact_sales fs
    WHERE fs.SalesID = s.SalesID
);

-- After an incremental load, refresh the materialized views of the analytics layer:
-- REFRESH MATERIALIZED VIEW analytics.mv_sales_monthly_category;
-- REFRESH MATERIALIZED VIEW analytics.mv_kpi_daily;
-- REFRESH MATERIALIZED VIEW analytics.mv_top_products;
-- REFRESH MATERIALIZED VIEW analytics.mv_sales_by_employee;
-- REFRESH MATERIALIZED VIEW analytics.mv_sales_by_country;
-- REFRESH MATERIALIZED VIEW analytics.mv_product_pairs;
