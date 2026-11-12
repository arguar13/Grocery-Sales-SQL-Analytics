-- FACT_SALES
-- Only the structure is created here; the data is loaded by 05_etl_full_load.sql
-- and kept up to date by 06_etl_incremental.sql.
CREATE TABLE IF NOT EXISTS analytics.fact_sales (
    -- Grain: one row per sales line (SalesID)
    SalesID INT PRIMARY KEY,

    -- Dimension keys
    date DATE,                    -- NULL for the ~1% of source rows without SalesDate
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    EmployeeID INT NOT NULL,

    -- Measures
    Quantity INT NOT NULL,
    Discount NUMERIC(4,2) NOT NULL DEFAULT 0,
    TotalPrice NUMERIC(12,2),     -- Kept for lineage: it is always 0 in the source
    revenue NUMERIC(14,2) NOT NULL,

    TransactionNumber VARCHAR(50) NOT NULL
);
