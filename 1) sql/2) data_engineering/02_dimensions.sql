-- DIM_DATE
-- A fixed 2010-2030 calendar: covers the source period with room for future loads.
-- generate_series() over dates returns TIMESTAMP, so it is cast back to DATE to match fact_sales.date
CREATE TABLE IF NOT EXISTS analytics.dim_date AS
SELECT
    d.date::date AS date,
    EXTRACT(YEAR FROM d.date)::int AS year,
    EXTRACT(MONTH FROM d.date)::int AS month,
    TO_CHAR(d.date, 'YYYY-MM') AS year_month,
    EXTRACT(DAY FROM d.date)::int AS day,
    EXTRACT(QUARTER FROM d.date)::int AS quarter,
    -- FM removes the blank padding that 'Day' adds (e.g. 'Monday   ')
    TO_CHAR(d.date, 'FMDay') AS weekday,
    EXTRACT(ISODOW FROM d.date) IN (6, 7) AS is_weekend
FROM (
    SELECT generate_series(
        '2010-01-01'::date,
        '2030-12-31'::date,
        '1 day'
    ) AS date
) d;


-- DIM_CATEGORY
CREATE TABLE IF NOT EXISTS analytics.dim_category AS
SELECT
    CategoryID,
    CategoryName
FROM public.categories;


-- DIM_PRODUCT
CREATE TABLE IF NOT EXISTS analytics.dim_product AS
SELECT
    p.ProductID,
    p.ProductName,
    p.Price,
    p.CategoryID,
    c.CategoryName,
    p.Class,
    p.Resistant,
    p.IsAllergic,
    p.VitalityDays
FROM public.products p
LEFT JOIN public.categories c
    ON p.CategoryID = c.CategoryID;


-- DIM_COUNTRY
CREATE TABLE IF NOT EXISTS analytics.dim_country AS
SELECT
    CountryID,
    CountryName,
    CountryCode
FROM public.countries;


-- DIM_CITY
CREATE TABLE IF NOT EXISTS analytics.dim_city AS
SELECT
    c.CityID,
    c.CityName,
    c.Zipcode,
    c.CountryID,
    co.CountryName,
    co.CountryCode
FROM public.cities c
LEFT JOIN public.countries co
    ON c.CountryID = co.CountryID;


-- DIM_CUSTOMER
CREATE TABLE IF NOT EXISTS analytics.dim_customer AS
SELECT
    cu.CustomerID,
    cu.FirstName,
    cu.MiddleInitial,
    cu.LastName,
    cu.Address,
    cu.CityID,
    ci.CityName,
    co.CountryName
FROM public.customers cu
LEFT JOIN public.cities ci
    ON cu.CityID = ci.CityID
LEFT JOIN public.countries co
    ON ci.CountryID = co.CountryID;


-- DIM_EMPLOYEE
CREATE TABLE IF NOT EXISTS analytics.dim_employee AS
SELECT
    e.EmployeeID,
    e.FirstName,
    e.MiddleInitial,
    e.LastName,
    e.Gender,
    e.BirthDate,
    e.HireDate,
    e.CityID,
    ci.CityName,
    co.CountryName
FROM public.employees e
LEFT JOIN public.cities ci
    ON e.CityID = ci.CityID
LEFT JOIN public.countries co
    ON ci.CountryID = co.CountryID;