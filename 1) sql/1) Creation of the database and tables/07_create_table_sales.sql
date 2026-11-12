CREATE TABLE Sales (
    SalesID SERIAL PRIMARY KEY,
    SalesPersonID INT NOT NULL,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    Discount NUMERIC(4,2) DEFAULT 0,
    -- Always 0.0 in the source dataset: revenue is derived in the ETL (Quantity * Price * (1 - Discount))
    TotalPrice NUMERIC(12,2) NOT NULL,
    -- Nullable: ~1% of the source rows have no sales date
    SalesDate TIMESTAMP,
    TransactionNumber VARCHAR(50) UNIQUE NOT NULL,
    CONSTRAINT fk_customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT fk_product FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CONSTRAINT fk_salesperson FOREIGN KEY (SalesPersonID) REFERENCES Employees(EmployeeID)
);
