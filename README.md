Data Transformer – Advanced SQL Project

A hands-on SQL project that simulates a small Corporate Data Analysis System. It demonstrates JOINs, subqueries, date functions, string functions, window functions and the CASE expression to transform raw business data into report-ready results.

Author: your name | Course / Exam: course name | Date: submission date

1. Objective

Build the practical skills needed to transform and manipulate data for reporting, analysis and complex queries by completing 17 tasks across three business areas:

#	Business area	Table
1	Customer Information Management	Customers
2	Sales Transaction Processing	Orders
3	Employee Performance Data	Employees
2. Project structure
data-transformer-sql/
├── README.md                 <- this file
├── run_project.py            <- builds the DB, runs all queries, generates the PDF
├── sql/
│   ├── 01_schema.sql         <- CREATE TABLE statements
│   ├── 02_sample_data.sql    <- INSERT statements (sample data)
│   └── 03_queries.sql        <- the 17 required queries
└── output/
    └── query_results.pdf     <- every query + its result table
3. Database design
Customers (1) ────< Orders (many)          Employees (standalone)
 CustomerID  PK      OrderID     PK         EmployeeID  PK
 FirstName           CustomerID  FK (null)  FirstName
 LastName            OrderDate              LastName
 Email               TotalAmount            Department
 RegistrationDate                           HireDate
                                            Salary

Sample data: 10 customers, 12 orders, 8 employees. The first two rows of each table are taken from the project brief; the rest were added so that every query has something meaningful to show (customers with no orders, an order with no customer, e-mails with stray spaces, salaries across all bands).

4. How to run

Option A – Python (recommended, produces the PDF)

bash
pip install reportlab
python run_project.py

Python 3.8+ is required, with SQLite 3.39+ (bundled with recent Python versions; check with python -c "import sqlite3; print(sqlite3.sqlite_version)"). The report is written to output/query_results.pdf.

Option B – SQLite command line

bash
sqlite3 corporate.db < sql/01_schema.sql
sqlite3 corporate.db < sql/02_sample_data.sql
sqlite3 -header -column corporate.db < sql/03_queries.sql

Option C – DB Browser for SQLite / any SQLite GUI: open the three files in order and execute them.

5. Queries implemented
Q	Topic	Task	Key SQL used
1	INNER JOIN	Orders with customer details, where orders exist	INNER JOIN
2	LEFT JOIN	All customers and their orders (if any)	LEFT JOIN
3	RIGHT JOIN	All orders and their customers (if any)	RIGHT JOIN
4	FULL OUTER JOIN	All customers and all orders, matched or not	FULL OUTER JOIN
5	Subquery	Customers with an order above the average amount	nested IN + AVG()
6	Subquery	Employees earning above the average salary	scalar subquery
7	Date extraction	Year and month of OrderDate	strftime
8	Date difference	Days between order date and today	julianday
9	Date formatting	OrderDate as DD-MMM-YYYY	strftime, substr
10	String concat	Full name	||
11	String replace	John → Jonathan	REPLACE
12	Case conversion	Upper-case first name, lower-case last name	UPPER, LOWER
13	Trim	Clean spaces from e-mails	TRIM
14	Window function	Running total of TotalAmount	SUM() OVER (ORDER BY …)
15	Window function	Rank orders by amount	RANK() OVER (…)
16	CASE	>1000 → 10 % off, >500 → 5 % off	CASE WHEN
17	CASE	Salary → Low / Medium / High	CASE WHEN
6. Assumptions
SQL dialect – SQLite 3.39+. It is free, needs no server, and supports RIGHT JOIN, FULL OUTER JOIN and window functions. Dialect differences are listed in section 7.
Orders.CustomerID is nullable so a “guest” order (Order 111) can exist. Without it, RIGHT JOIN and FULL OUTER JOIN would return the same rows as an INNER/LEFT JOIN.
Extra sample data was added beyond the two rows in the brief (see section 3). The brief’s original rows are unchanged.
Money columns use REAL in SQLite so decimals are preserved; in MySQL / SQL Server use DECIMAL(10,2).
“Average amount” (Q5) means the average of TotalAmount across all orders (≈ 501.57).
Discount boundaries (Q16): the brief uses strict >; so exactly 1000 gets 5 % and exactly 500 gets 0 % (Order 110 = 500.00 gets no discount).
Salary bands (Q17) are not defined in the brief, so: Low < 45,000 · Medium 45,000–89,999 · High ≥ 90,000.
Running total (Q14) is ordered by OrderDate, then OrderID to break ties deterministically.
“Current date” (Q8) is date('now'), so DaysSinceOrder changes every day you run it. The PDF shows the values for the day it was generated.
RANK() (Q15) leaves gaps after ties (e.g. 1, 2, 2, 4); no ties exist in the current data.
7. Notes for other databases
Task	SQLite (used here)	MySQL 8	SQL Server
Concatenate	a || ' ' || b	CONCAT(a,' ',b)	CONCAT(a,' ',b)
Year / month	strftime('%Y', d)	YEAR(d), MONTH(d)	YEAR(d), MONTH(d)
Days between	julianday(x) - julianday(y)	DATEDIFF(CURDATE(), d)	DATEDIFF(day, d, GETDATE())
Format date	strftime + substr	DATE_FORMAT(d,'%d-%b-%Y')	FORMAT(d,'dd-MMM-yyyy')
Current date	date('now')	CURDATE()	GETDATE()
FULL OUTER JOIN	supported (3.39+)	not supported – LEFT JOIN … UNION … RIGHT JOIN	supported
8. Things worth noticing in the results
Q3 / Q4: Order 111 has no customer, and customers 7 and 10 have no orders. These unmatched rows are exactly what separates the join types.
Q11: REPLACE works on substrings, so Johnny becomes Jonathanny and Johnson becomes Jonathanson. In production you would match on whole values (e.g. CASE WHEN FirstName = 'John' …) instead.
Q13: the [ ] brackets in the output make the removed spaces visible.
9. Publishing to GitHub
bash
git init
git add .
git commit -m "Data Transformer SQL project"
git branch -M main
git remote add origin https://github.com/<your-username>/data-transformer-sql.git
git push -u origin main

Then copy the repository URL and submit it as required. Double-check that all files (including output/query_results.pdf) appear in the repository.

10. Originality statement

All SQL, documentation and sample data in this repository were written for this project. If you reuse or adapt any outside code, credit the source here.

If you want the raw markdown text to paste into GitHub, use the README.md file I attached earlier, or ask me for the code-block version again.
