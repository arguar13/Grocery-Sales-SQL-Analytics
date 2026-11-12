-- LOAD THE RAW CSV FILES INTO THE TRANSACTIONAL TABLES
-- Run with psql from the repository root, e.g.:
--   psql -U postgres -d groceries_db -f "1) sql/1) Creation of the database and tables/08_load_data.sql"
-- \copy reads the files on the client side, so no superuser file access is needed.
-- (In pgAdmin: right click on each table > Import/Export Data, format CSV, Header ON,
--  and for customers set "NULL Strings" = NULL.)

-- Parent tables first so the foreign keys are satisfied
\copy categories FROM 'data/categories.csv' WITH (FORMAT csv, HEADER true)
\copy countries  FROM 'data/countries.csv'  WITH (FORMAT csv, HEADER true)
\copy cities     FROM 'data/cities.csv'     WITH (FORMAT csv, HEADER true)
-- customers.csv stores missing middle initials as the literal text 'NULL'
\copy customers  FROM 'data/customers.csv'  WITH (FORMAT csv, HEADER true, NULL 'NULL')
\copy employees  FROM 'data/employees.csv'  WITH (FORMAT csv, HEADER true)
\copy products   FROM 'data/products.csv'   WITH (FORMAT csv, HEADER true)
-- sales.csv (~6.7M rows) stores missing dates as empty fields, which CSV format loads as NULL
\copy sales      FROM 'data/sales.csv'      WITH (FORMAT csv, HEADER true)

-- SERIAL sequences are not advanced by COPY with explicit IDs: sync them so future inserts don't collide
SELECT setval(pg_get_serial_sequence('countries', 'countryid'), MAX(CountryID)) FROM countries;
SELECT setval(pg_get_serial_sequence('cities', 'cityid'), MAX(CityID)) FROM cities;
SELECT setval(pg_get_serial_sequence('customers', 'customerid'), MAX(CustomerID)) FROM customers;
SELECT setval(pg_get_serial_sequence('employees', 'employeeid'), MAX(EmployeeID)) FROM employees;
SELECT setval(pg_get_serial_sequence('products', 'productid'), MAX(ProductID)) FROM products;
SELECT setval(pg_get_serial_sequence('sales', 'salesid'), MAX(SalesID)) FROM sales;
