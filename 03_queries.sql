-- =====================================================================
-- File    : 03_queries.sql
-- Purpose : The 17 required queries. Each block starts with a header line:
--           -- @Q<number> | <topic> | <task from the brief>
--           (the Python runner uses these headers to build the PDF report)
-- Dialect : SQLite 3.39+
-- =====================================================================

-- @Q1 | INNER JOIN | Retrieve all orders and customer details where orders exist.
SELECT o.OrderID, o.OrderDate, o.TotalAmount,
       c.CustomerID, c.FirstName, c.LastName
FROM   Orders o
INNER JOIN Customers c ON c.CustomerID = o.CustomerID
ORDER BY o.OrderID;

-- @Q2 | LEFT JOIN | Retrieve all customers and their corresponding orders (if any).
SELECT c.CustomerID, c.FirstName, c.LastName,
       o.OrderID, o.OrderDate, o.TotalAmount
FROM   Customers c
LEFT JOIN Orders o ON o.CustomerID = c.CustomerID
ORDER BY c.CustomerID, o.OrderID;

-- @Q3 | RIGHT JOIN | Retrieve all orders and their corresponding customers (if any).
SELECT o.OrderID, o.OrderDate, o.TotalAmount,
       c.CustomerID, c.FirstName, c.LastName
FROM   Customers c
RIGHT JOIN Orders o ON o.CustomerID = c.CustomerID
ORDER BY o.OrderID;

-- @Q4 | FULL OUTER JOIN | Retrieve all customers and all orders, regardless of matching.
SELECT c.CustomerID, c.FirstName, c.LastName,
       o.OrderID, o.OrderDate, o.TotalAmount
FROM   Customers c
FULL OUTER JOIN Orders o ON o.CustomerID = c.CustomerID
ORDER BY c.CustomerID, o.OrderID;

-- @Q5 | Subquery (customers) | Find customers who have placed orders worth more than the average amount.
SELECT CustomerID, FirstName, LastName, Email
FROM   Customers
WHERE  CustomerID IN (
           SELECT CustomerID
           FROM   Orders
           WHERE  TotalAmount > (SELECT AVG(TotalAmount) FROM Orders)
       )
ORDER BY CustomerID;

-- @Q6 | Subquery (employees) | Find employees with salaries above the average salary.
SELECT EmployeeID, FirstName, LastName, Department, Salary
FROM   Employees
WHERE  Salary > (SELECT AVG(Salary) FROM Employees)
ORDER BY Salary DESC;

-- @Q7 | Date extraction | Extract the year and month from the OrderDate.
SELECT OrderID, OrderDate,
       CAST(strftime('%Y', OrderDate) AS INTEGER) AS OrderYear,
       CAST(strftime('%m', OrderDate) AS INTEGER) AS OrderMonth
FROM   Orders
ORDER BY OrderID;

-- @Q8 | Date difference | Calculate the difference in days between two dates (order date and current date).
SELECT OrderID, OrderDate, date('now') AS CurrentDate,
       CAST(julianday(date('now')) - julianday(OrderDate) AS INTEGER) AS DaysSinceOrder
FROM   Orders
ORDER BY OrderID;

-- @Q9 | Date formatting | Format the OrderDate to a more readable format (e.g., 'DD-MMM-YYYY').
SELECT OrderID, OrderDate,
       strftime('%d', OrderDate) || '-' ||
       substr('JanFebMarAprMayJunJulAugSepOctNovDec',
              (CAST(strftime('%m', OrderDate) AS INTEGER) - 1) * 3 + 1, 3)
       || '-' || strftime('%Y', OrderDate) AS FormattedOrderDate
FROM   Orders
ORDER BY OrderID;

-- @Q10 | String concatenation | Concatenate FirstName and LastName to form a full name.
SELECT CustomerID, FirstName, LastName,
       FirstName || ' ' || LastName AS FullName
FROM   Customers
ORDER BY CustomerID;

-- @Q11 | REPLACE | Replace part of a string (e.g., replace 'John' with 'Jonathan').
SELECT CustomerID,
       FirstName || ' ' || LastName AS FullName,
       REPLACE(FirstName || ' ' || LastName, 'John', 'Jonathan') AS ReplacedName
FROM   Customers
ORDER BY CustomerID;

-- @Q12 | UPPER / LOWER | Convert FirstName to uppercase and LastName to lowercase.
SELECT CustomerID, FirstName, LastName,
       UPPER(FirstName) AS FirstNameUpper,
       LOWER(LastName)  AS LastNameLower
FROM   Customers
ORDER BY CustomerID;

-- @Q13 | TRIM | Trim extra spaces from the Email field.
SELECT CustomerID,
       '[' || Email || ']'       AS EmailBefore,
       '[' || TRIM(Email) || ']' AS EmailAfter,
       LENGTH(Email) - LENGTH(TRIM(Email)) AS SpacesRemoved
FROM   Customers
ORDER BY CustomerID;

-- @Q14 | Window: running total | Calculate the running total of TotalAmount for each order.
SELECT OrderID, OrderDate, TotalAmount,
       SUM(TotalAmount) OVER (ORDER BY OrderDate, OrderID
                              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM   Orders
ORDER BY OrderDate, OrderID;

-- @Q15 | Window: RANK() | Rank orders based on TotalAmount using the RANK() function.
SELECT OrderID, OrderDate, TotalAmount,
       RANK() OVER (ORDER BY TotalAmount DESC) AS AmountRank
FROM   Orders
ORDER BY AmountRank, OrderID;

-- @Q16 | CASE: discount | Assign a discount based on TotalAmount (>1000: 10% off, >500: 5% off).
SELECT OrderID, TotalAmount,
       CASE WHEN TotalAmount > 1000 THEN 10
            WHEN TotalAmount > 500  THEN 5
            ELSE 0 END AS DiscountPct,
       ROUND(TotalAmount *
             CASE WHEN TotalAmount > 1000 THEN 0.10
                  WHEN TotalAmount > 500  THEN 0.05
                  ELSE 0 END, 2) AS DiscountAmount,
       ROUND(TotalAmount *
             (1 - CASE WHEN TotalAmount > 1000 THEN 0.10
                       WHEN TotalAmount > 500  THEN 0.05
                       ELSE 0 END), 2) AS FinalAmount
FROM   Orders
ORDER BY OrderID;

-- @Q17 | CASE: salary bands | Categorize employees' salaries as low, medium, or high (Low < 45,000 | Medium 45,000-89,999 | High >= 90,000).
SELECT EmployeeID, FirstName, LastName, Department, Salary,
       CASE WHEN Salary < 45000 THEN 'Low'
            WHEN Salary < 90000 THEN 'Medium'
            ELSE 'High' END AS SalaryCategory
FROM   Employees
ORDER BY Salary;
