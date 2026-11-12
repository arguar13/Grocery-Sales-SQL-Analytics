-- INDEXES FOR FACT TABLE
-- (SalesID is already indexed by its PRIMARY KEY)
CREATE INDEX IF NOT EXISTS idx_fact_sales_date ON analytics.fact_sales(date);
CREATE INDEX IF NOT EXISTS idx_fact_sales_customer ON analytics.fact_sales(CustomerID);
CREATE INDEX IF NOT EXISTS idx_fact_sales_product ON analytics.fact_sales(ProductID);
CREATE INDEX IF NOT EXISTS idx_fact_sales_employee ON analytics.fact_sales(EmployeeID);


-- UNIQUE INDEXES FOR DIMENSIONS
-- CREATE TABLE AS does not copy primary keys, so uniqueness of each dimension key is enforced here
CREATE UNIQUE INDEX IF NOT EXISTS idx_dim_customer_id ON analytics.dim_customer(CustomerID);
CREATE UNIQUE INDEX IF NOT EXISTS idx_dim_product_id ON analytics.dim_product(ProductID);
CREATE UNIQUE INDEX IF NOT EXISTS idx_dim_employee_id ON analytics.dim_employee(EmployeeID);
CREATE UNIQUE INDEX IF NOT EXISTS idx_dim_category_id ON analytics.dim_category(CategoryID);
CREATE UNIQUE INDEX IF NOT EXISTS idx_dim_city_id ON analytics.dim_city(CityID);
CREATE UNIQUE INDEX IF NOT EXISTS idx_dim_country_id ON analytics.dim_country(CountryID);
CREATE UNIQUE INDEX IF NOT EXISTS idx_dim_date_date ON analytics.dim_date(date);
