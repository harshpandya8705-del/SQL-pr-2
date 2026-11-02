-- =====================================================================
-- Project : Data Transformer
-- File    : 01_schema.sql
-- Purpose : Creates the three tables of the Corporate Data Analysis System
-- Dialect : SQLite 3.39+ (see README for MySQL / SQL Server notes)
-- Note    : money columns use REAL so SQLite keeps the decimal part; use DECIMAL(10,2) in MySQL/SQL Server.
-- =====================================================================

DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Employees;

-- 1. Customer Information Management
CREATE TABLE Customers (
    CustomerID       INTEGER PRIMARY KEY,
    FirstName        TEXT NOT NULL,
    LastName         TEXT NOT NULL,
    Email            TEXT,
    RegistrationDate DATE NOT NULL
);

-- 2. Sales Transaction Processing
-- CustomerID is nullable on purpose: it allows "guest" orders, which makes
-- the RIGHT JOIN / FULL OUTER JOIN queries meaningful (see README, Assumptions).
CREATE TABLE Orders (
    OrderID     INTEGER PRIMARY KEY,
    CustomerID  INTEGER,
    OrderDate   DATE NOT NULL,
    TotalAmount REAL NOT NULL CHECK (TotalAmount >= 0),
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)
);

-- 3. Employee Performance Data
CREATE TABLE Employees (
    EmployeeID INTEGER PRIMARY KEY,
    FirstName  TEXT NOT NULL,
    LastName   TEXT NOT NULL,
    Department TEXT NOT NULL,
    HireDate   DATE NOT NULL,
    Salary     REAL NOT NULL CHECK (Salary >= 0)
);
