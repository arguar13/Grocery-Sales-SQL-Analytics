-- FULL LOAD ETL FOR FACT_SALES
-- Rebuilds the fact table from the transactional tables. 06_etl_incremental.sql only
-- appends new sales, so corrections to sales already loaded need this full load.
TRUNCATE TABLE analytics.fact_sales;

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

    -- The source TotalPrice is always 0, so revenue is derived: quantity * unit price * (1 - discount)
    ROUND(s.Quantity * p.Price * (1 - COALESCE(s.Discount, 0)), 2) AS revenue,

    s.TransactionNumber

FROM public.sales s
JOIN public.products p
     ON s.ProductID = p.ProductID;

-- Refresh planner statistics after a bulk load
ANALYZE analytics.fact_sales;
