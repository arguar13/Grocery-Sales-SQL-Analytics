-- KPI 1: Total Revenue
SELECT 
    SUM(revenue) AS total_revenue
FROM analytics.fact_sales;


-- KPI 2: Average Ticket per Visit
-- Every TransactionNumber holds a single product line, so a visit is defined as a customer-day:
-- all the lines a customer bought on the same date. The same definition is used by RFM and the market basket.
SELECT
    ROUND(AVG(visit_total), 2) AS average_ticket,
    ROUND(AVG(visit_lines), 2) AS average_lines_per_visit
FROM (
    SELECT
        CustomerID,
        date,
        SUM(revenue) AS visit_total,
        COUNT(*) AS visit_lines
    FROM analytics.fact_sales
    WHERE date IS NOT NULL
    GROUP BY CustomerID, date
) v;


-- KPI 3: Monthly Revenue
-- The data ends on 2018-05-09, so May is a partial month: the average revenue per day with sales
-- is the fair way to compare months of different length.
SELECT
    year_month,
    SUM(revenue) AS monthly_revenue,
    COUNT(DISTINCT date) AS days_with_sales,
    ROUND(SUM(revenue) / COUNT(DISTINCT date), 2) AS avg_daily_revenue
FROM (
    SELECT
        TO_CHAR(date,'YYYY-MM') AS year_month,
        date,
        revenue
    FROM analytics.fact_sales
    WHERE date IS NOT NULL
) t
GROUP BY year_month
ORDER BY year_month;


-- KPI 4: Total Units Sold
SELECT 
    SUM(Quantity) AS total_units_sold
FROM analytics.fact_sales;


-- KPI 5: Total Customers
SELECT 
    COUNT(DISTINCT CustomerID) AS total_customers
FROM analytics.fact_sales;


-- KPI 6: Revenue per Product Category
SELECT 
    p.CategoryName,
    SUM(f.revenue) AS category_revenue
FROM analytics.fact_sales f
JOIN analytics.dim_product p
     ON f.ProductID = p.ProductID
GROUP BY p.CategoryName
ORDER BY category_revenue DESC;


-- KPI 7: Revenue per Employee
SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    SUM(f.revenue) AS employee_revenue
FROM analytics.fact_sales f
JOIN analytics.dim_employee e
     ON f.EmployeeID = e.EmployeeID
GROUP BY 
    e.EmployeeID,
    e.FirstName,
    e.LastName
ORDER BY employee_revenue DESC;