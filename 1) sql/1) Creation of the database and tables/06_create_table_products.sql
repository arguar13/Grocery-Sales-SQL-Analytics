CREATE TABLE Products (
    ProductID SERIAL PRIMARY KEY,
    ProductName VARCHAR(150) NOT NULL,
    Price NUMERIC(10,4) NOT NULL,
    CategoryID INT NOT NULL,
    Class VARCHAR(20) NOT NULL,
    ModifyDate TIMESTAMP NOT NULL,
    Resistant VARCHAR(20) NOT NULL,
    -- The source CSV uses 'True' / 'False' / 'Unknown', so a BOOLEAN column would reject the load
    IsAllergic VARCHAR(10) NOT NULL,
    -- The source CSV stores decimals such as '76.0', which an INT column would reject
    VitalityDays NUMERIC(6,1) NOT NULL,
    CONSTRAINT fk_category FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
