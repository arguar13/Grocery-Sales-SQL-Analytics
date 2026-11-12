-- 1. Monthly Sales by Product Category
CREATE MATERIALIZED VIEW IF NOT EXISTS analytics.mv_sales_monthly_category AS
SELECT
    TO_CHAR(f.date, 'YYYY-MM') AS year_month,
    p.CategoryName,
    SUM(f.revenue) AS monthly_revenue
FROM analytics.fact_sales f
JOIN analytics.dim_product p
     ON f.ProductID = p.ProductID
-- Sales without a date cannot be assigned to a month
WHERE f.date IS NOT NULL
GROUP BY 1,2;


-- 2. Daily Business KPI
-- A visit is a customer-day, so the distinct customers of a day are also its number of visits
CREATE MATERIALIZED VIEW IF NOT EXISTS analytics.mv_kpi_daily AS
SELECT
    f.date,
    SUM(f.revenue) AS daily_revenue,
    SUM(f.Quantity) AS units_sold,
    COUNT(DISTINCT f.CustomerID) AS daily_visits,
    COUNT(*) AS sales_lines,
    ROUND(SUM(f.revenue) / COUNT(DISTINCT f.CustomerID), 2) AS avg_ticket
FROM analytics.fact_sales f
WHERE f.date IS NOT NULL
GROUP BY f.date;


-- 3. Top Selling Products
CREATE MATERIALIZED VIEW IF NOT EXISTS analytics.mv_top_products AS
SELECT
    p.ProductID,
    p.ProductName,
    p.CategoryName,
    SUM(f.revenue) AS total_revenue,
    SUM(f.Quantity) AS total_units_sold
FROM analytics.fact_sales f
JOIN analytics.dim_product p
     ON f.ProductID = p.ProductID
GROUP BY
    p.ProductID,
    p.ProductName,
    p.CategoryName
ORDER BY total_revenue DESC;


-- 4. Sales by Employee
CREATE MATERIALIZED VIEW IF NOT EXISTS analytics.mv_sales_by_employee AS
SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    SUM(f.revenue) AS employee_revenue,
    SUM(f.Quantity) AS units_sold
FROM analytics.fact_sales f
JOIN analytics.dim_employee e
     ON f.EmployeeID = e.EmployeeID
GROUP BY
    e.EmployeeID,
    e.FirstName,
    e.LastName
ORDER BY employee_revenue DESC;
 

-- 5. Sales by Country
CREATE MATERIALIZED VIEW IF NOT EXISTS analytics.mv_sales_by_country AS
-- dim_customer already carries the customer's country (resolved through CityID -> CountryID),
-- so there is no need to join dim_country again by name
SELECT
    cu.CountryName,
    SUM(f.revenue) AS total_revenue,
    SUM(f.Quantity) AS units_sold
FROM analytics.fact_sales f
JOIN analytics.dim_customer cu
     ON f.CustomerID = cu.CustomerID
GROUP BY cu.CountryName
ORDER BY total_revenue DESC;