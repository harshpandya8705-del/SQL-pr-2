-- =====================================================================
-- File    : 02_sample_data.sql
-- Purpose : Loads sample data. Rows 1-2 of each table come from the brief;
--           the remaining rows were added so every query has something
--           interesting to show (unmatched rows, messy e-mails, etc.).
-- =====================================================================

INSERT INTO Customers (CustomerID, FirstName, LastName, Email, RegistrationDate) VALUES
 (1,  'John',   'Doe',       'john.doe@email.com',        '2022-03-15'),
 (2,  'Jane',   'Smith',     'jane.smith@email.com',      '2021-11-02'),
 (3,  'Johnny', 'Appleseed', '  johnny.a@email.com  ',    '2022-06-20'),  -- extra spaces
 (4,  'Priya',  'Patel',     'priya.patel@email.com',     '2023-01-10'),
 (5,  'Rahul',  'Mehta',     '  rahul.mehta@email.com',   '2022-09-05'),  -- leading spaces
 (6,  'Emily',  'Johnson',   'emily.j@email.com',         '2023-02-14'),
 (7,  'Carlos', 'Gomez',     'carlos.g@email.com',        '2021-05-30'),  -- no orders
 (8,  'Aisha',  'Khan',      'aisha.khan@email.com   ',   '2023-04-01'),  -- trailing spaces
 (9,  'John',   'Carter',    ' john.carter@email.com ',   '2022-12-12'),
 (10, 'Mei',    'Lin',       'mei.lin@email.com',         '2023-05-18');  -- no orders

INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount) VALUES
 (101, 1,    '2023-07-01',  150.50),
 (102, 2,    '2023-07-03',  200.75),
 (103, 3,    '2023-07-15', 1250.00),
 (104, 4,    '2023-08-02',  620.40),
 (105, 1,    '2023-08-10',   75.25),
 (106, 5,    '2023-08-21',  980.00),
 (107, 6,    '2023-09-05',  310.00),
 (108, 2,    '2023-09-18', 1520.90),
 (109, 4,    '2023-10-01',   45.99),
 (110, 8,    '2023-10-12',  500.00),
 (111, NULL, '2023-10-20',   89.99),   -- guest order (no customer)
 (112, 9,    '2023-11-03',  275.00);

INSERT INTO Employees (EmployeeID, FirstName, LastName, Department, HireDate, Salary) VALUES
 (1, 'Mark',   'Johnson', 'Sales',     '2020-01-15',  50000.00),
 (2, 'Susan',  'Lee',     'HR',        '2021-03-20',  55000.00),
 (3, 'Anil',   'Sharma',  'IT',        '2019-07-01',  92000.00),
 (4, 'Laura',  'Chen',    'Finance',   '2022-05-16',  78000.00),
 (5, 'David',  'Brown',   'Sales',     '2018-11-12',  35000.00),
 (6, 'Neha',   'Verma',   'Marketing', '2023-02-01',  42000.00),
 (7, 'Robert', 'King',    'IT',        '2017-09-25', 115000.00),
 (8, 'Fatima', 'Noor',    'HR',        '2022-10-10',  38000.00);
