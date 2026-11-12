CREATE TABLE Customers (
    CustomerID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    MiddleInitial CHAR(1),
    LastName VARCHAR(50) NOT NULL,
    CityID INT NOT NULL,
    Address VARCHAR(200) NOT NULL,
    CONSTRAINT fk_city FOREIGN KEY (CityID) REFERENCES Cities(CityID)
);
