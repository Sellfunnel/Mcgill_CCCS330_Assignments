-- Inserting into Warehouses Table
INSERT INTO Warehouses (WarehouseID, Address, City, State, Zip, Phone, ClimateControlled, SecurityGate) VALUES
('WA-1', '789 Warehouse Rd', 'Seattle', 'WA', '98121', '206-555-0123', 1, 1),
('OR-1', '456 Depot St', 'Portland', 'OR', '97212', '503-555-0145', 0, 1);

-- Inserting into Employees Table
INSERT INTO Employees (FullName, Address, City, State, ZIP, Phone, SSN, DateOfBirth, HireDate, Position, AnnualSalary, WarehouseID) VALUES
('John Doe', '101 Main St', 'Seattle', 'WA', '98101', '206-555-0100', '123-45-6789', '1980-01-01', '2020-05-10', 'Manager', 55000, 'WA-1'),
('Jane Smith', '202 Oak St', 'Tacoma', 'WA', '98401', '206-555-0200', '987-65-4321', '1985-07-15', '2021-06-15', 'Supervisor', 47000, 'WA-1');

-- Inserting into Vehicles Table
INSERT INTO Vehicles (VehicleID, LicensePlateNumber, NumberOfAxles, Color) VALUES
('TRK-001', 'XYZ123', 2, 'Blue'),
('VAN-009', 'ABC987', 2, 'White');

-- Inserting into Customers Table
INSERT INTO Customers (CompanyName, JobContactName, Address, City, State, ZipCode, PhoneNumber, Balance) VALUES
('Real Estate Solutions', 'Alice Johnson', '300 Pine St', 'Seattle', 'WA', '98101', '206-555-0111', 1000.00),
('Tech Innovators', 'Bob Roberts', '500 Tech Ave', 'Redmond', 'WA', '98052', '425-555-0112', 500.00);

-- Inserting into Storage Units Table
INSERT INTO StorageUnits (UnitID, WarehouseID, UnitSize, Rent) VALUES
('1', 'WA-1', '8x8', 200.00),
('2', 'WA-1', '12x12', 350.00);

-- Inserting into Drivers Table
INSERT INTO Drivers (EmployeeID, RatePerMile, MilesDriven, SafetyRating) VALUES
(1, 0.50, 12000, 'A'),
(2, 0.45, 15000, 'B');

-- Inserting into Unit Rentals Table
INSERT INTO UnitRentals (UnitID, CustomerID, LeaseStartDate, LeaseEndDate) VALUES
('1', 1, '2023-01-01', '2023-12-31'),
('2', 2, '2023-02-01', NULL);  -- Current tenant

-- Inserting into Job Orders Table
INSERT INTO JobOrders (CustomerID, MoveDate, FromAddress, ToAddress, EstimatedMileage, EstimatedWeight, PackingServiceRequired, HeavyItems, StorageRequired) VALUES
(1, '2023-06-15', '101 Main St', '202 Oak St', 15, 2000, 1, 0, 1),
(2, '2023-07-22', '202 Oak St', '101 Main St', 15, 1500, 0, 1, 0);

-- Inserting into Job Details Table
INSERT INTO JobDetails (JobOrderID, VehicleID, DriverID, ActualMileage, ActualWeight, CompletionDate) VALUES
(1, 'TRK-001', 1, 18, 2100, '2023-06-15'),
(2, 'VAN-009', 2, 16, 1550, '2023-07-22');
