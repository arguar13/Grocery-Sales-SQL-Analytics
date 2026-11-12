-- Run after 02_create_table_countries.sql (Cities references Countries)
CREATE TABLE Cities (
    CityID SERIAL PRIMARY KEY,
    CityName VARCHAR(100) NOT NULL,
    Zipcode VARCHAR(20) NOT NULL,
    CountryID INT NOT NULL,
    CONSTRAINT fk_country FOREIGN KEY (CountryID) REFERENCES Countries(CountryID)
);
