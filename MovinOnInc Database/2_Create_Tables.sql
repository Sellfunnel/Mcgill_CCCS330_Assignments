-- Setting up a session to ignore foreign key checks to prevent errors during table creation
SET foreign_key_checks = 0;

USE MovinOnInc;

CREATE TABLE Warehouses (
    WarehouseID VARCHAR(10) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(2) NOT NULL,
    Zip VARCHAR(10) NOT NULL,
    Phone VARCHAR(15) NOT NULL,
    ClimateControlled BOOLEAN NOT NULL,
    SecurityGate BOOLEAN NOT NULL,
    PRIMARY KEY (WarehouseID)
);

CREATE TABLE Employees (
    EmployeeID INT NOT NULL AUTO_INCREMENT,
    FullName VARCHAR(100) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(2) NOT NULL,
    ZIP VARCHAR(10) NOT NULL,
    Phone VARCHAR(15) NOT NULL,
    SSN VARCHAR(11) NOT NULL,
    DateOfBirth DATE NOT NULL,
    HireDate DATE NOT NULL,
    TerminationDate DATE,
    Position VARCHAR(100),
    AnnualSalary DECIMAL(10, 2),
    WarehouseID VARCHAR(10),
    PRIMARY KEY (EmployeeID),
    FOREIGN KEY (WarehouseID) REFERENCES Warehouses(WarehouseID)
);

CREATE TABLE Drivers (
    DriverID INT NOT NULL AUTO_INCREMENT,
    EmployeeID INT NOT NULL,
    RatePerMile DECIMAL(10, 2) NOT NULL,
    MilesDriven INT NOT NULL,
    SafetyRating CHAR(1) NOT NULL,
    PRIMARY KEY (DriverID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE Vehicles (
    VehicleID VARCHAR(10) NOT NULL,
    LicensePlateNumber VARCHAR(15) NOT NULL,
    NumberOfAxles INT NOT NULL,
    Color VARCHAR(50) NOT NULL,
    PRIMARY KEY (VehicleID)
);

CREATE TABLE StorageUnits (
    UnitID INT NOT NULL AUTO_INCREMENT,
    WarehouseID VARCHAR(10) NOT NULL,
    UnitSize VARCHAR(10) NOT NULL,
    Rent DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (UnitID),
    FOREIGN KEY (WarehouseID) REFERENCES Warehouses(WarehouseID)
);

CREATE TABLE Customers (
    CustomerID INT NOT NULL AUTO_INCREMENT,
    CompanyName VARCHAR(255),
    JobContactName VARCHAR(100) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(2) NOT NULL,
    ZipCode VARCHAR(10) NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL,
    Balance DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (CustomerID)
);

CREATE TABLE UnitRentals (
    RentalID INT NOT NULL AUTO_INCREMENT,
    UnitID INT NOT NULL,
    CustomerID INT NOT NULL,
    LeaseStartDate DATE NOT NULL,
    LeaseEndDate DATE,
    PRIMARY KEY (RentalID),
    FOREIGN KEY (UnitID) REFERENCES StorageUnits(UnitID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE JobOrders (
    JobOrderID INT NOT NULL AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    MoveDate DATE NOT NULL,
    FromAddress VARCHAR(255) NOT NULL,
    ToAddress VARCHAR(255) NOT NULL,
    EstimatedMileage INT NOT NULL,
    EstimatedWeight INT NOT NULL,
    PackingServiceRequired BOOLEAN NOT NULL,
    HeavyItems BOOLEAN NOT NULL,
    StorageRequired BOOLEAN NOT NULL,
    PRIMARY KEY (JobOrderID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE JobDetails (
    JobDetailID INT NOT NULL AUTO_INCREMENT,
    JobOrderID INT NOT NULL,
    VehicleID VARCHAR(10) NOT NULL,
    DriverID INT NOT NULL,
    ActualMileage INT NOT NULL,
    ActualWeight INT NOT NULL,
    CompletionDate DATE NOT NULL,
    PRIMARY KEY (JobDetailID),
    FOREIGN KEY (JobOrderID) REFERENCES JobOrders(JobOrderID),
    FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID),
    FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID)
);

-- Re-enable foreign key checks after table creation
SET foreign_key_checks = 1;