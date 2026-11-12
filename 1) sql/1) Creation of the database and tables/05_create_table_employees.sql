CREATE TABLE Employees (
    EmployeeID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    MiddleInitial CHAR(1),
    LastName VARCHAR(50) NOT NULL,
    BirthDate DATE NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M','F')),
    CityID INT NOT NULL,
    HireDate DATE NOT NULL,
    CONSTRAINT fk_city FOREIGN KEY (CityID) REFERENCES Cities(CityID)
);
