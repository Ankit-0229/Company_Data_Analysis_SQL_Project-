
-- Create the database
CREATE DATABASE Company;

-- use Database 
USE Company;

-- Table: Departments (Stores department details)
CREATE TABLE Departments (
    Dept_ID SMALLINT PRIMARY KEY AUTO_INCREMENT,  -- Auto-incremented primary key
    Dept_Name VARCHAR(50) NOT NULL UNIQUE  -- Department name must be unique
);

-- Table: Branches (Stores branch details)
CREATE TABLE Branches (
    BID SMALLINT PRIMARY KEY AUTO_INCREMENT,  -- Auto-incremented primary key
    Branch_Name VARCHAR(50) NOT NULL UNIQUE  -- Branch name must be unique
);

-- Table: Employees (Stores employee details with foreign keys to department & branch)
CREATE TABLE Employees (
    EmpID SMALLINT PRIMARY KEY AUTO_INCREMENT,  -- Unique Employee ID
    Emp_FirstName VARCHAR(50),
    Emp_LastName VARCHAR(50),
    Emp_City VARCHAR(50),
    DOJ DATE,  -- Date of Joining
    Salary DECIMAL(10,2) CHECK (Salary > 0),  -- Salary must be greater than 0
    DID SMALLINT,  -- Department ID (Foreign Key)
    BID SMALLINT,  -- Branch ID (Foreign Key)
    FOREIGN KEY (DID) REFERENCES Departments(Dept_ID) ON DELETE SET NULL,
    FOREIGN KEY (BID) REFERENCES Branches(BID) ON DELETE SET NULL
);

-- Table: Salaries (Tracks salary changes over time)
CREATE TABLE Salaries (
    SalaryID INT PRIMARY KEY AUTO_INCREMENT,
    EmpID SMALLINT,
    Old_Salary DECIMAL(10,2),  -- Previous salary amount
    New_Salary DECIMAL(10,2),  -- Updated salary amount
    Change_Date  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Date of salary change
    FOREIGN KEY (EmpID) REFERENCES Employees(EmpID)
);

-- Table: Projects (Tracks company projects and their assigned department)
CREATE TABLE Projects (
    ProjectID SMALLINT PRIMARY KEY AUTO_INCREMENT,
    Project_Name VARCHAR(100) NOT NULL UNIQUE,  -- Unique project name
    Dept_ID SMALLINT,
    FOREIGN KEY (Dept_ID) REFERENCES Departments(Dept_ID) ON DELETE SET NULL
);

-- Table: Employee_Project (Many-to-Many relationship between employees and projects)
CREATE TABLE Employee_Project (
    EmpID SMALLINT,
    ProjectID SMALLINT,
    PRIMARY KEY (EmpID, ProjectID),
    FOREIGN KEY (EmpID) REFERENCES Employees(EmpID),
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID)
);

-- Insert Data in  Departments
INSERT INTO Departments (Dept_Name) VALUES
('HR'), ('Software'), ('Admin'), ('Finance'), ('Security');

-- Insert Data in Branches
INSERT INTO Branches (Branch_Name) VALUES
('Mumbai'), ('Delhi'), ('Chennai'), ('Kolkata');

-- Insert  Data in Employees with different departments and branches
INSERT INTO Employees (Emp_FirstName, Emp_LastName, Emp_City, DOJ, Salary, DID, BID) VALUES
('Jyoti', 'Saini', 'Narnaul', '2015-07-01', 50000, 2, 3),
('Suman', 'Saini', 'Delhi', '2015-12-06', 40000, 4, 3),
('Jaisal', 'Bansal', 'GangaNagar', '2021-09-01', 60000, 2, 4),
('Amit', 'Sharma', 'Jaipur', '2018-05-12', 55000, 1, 2),  
('Neha', 'Verma', 'Pune', '2019-11-23', 48000, 3, 1),  
('Rohan', 'Mehta', 'Mumbai', '2017-08-15', 67000, 2, 3),  
('Pooja', 'Singh', 'Bangalore', '2020-04-18', 73000, 2, 2),  
('Suresh', 'Patel', 'Ahmedabad', '2016-06-30', 51000, 4, 4),  
('Ananya', 'Kapoor', 'Chennai', '2021-01-10', 60000, 5, 2),  
('Vikas', 'Jain', 'Delhi', '2019-07-05', 45000, 3, 1),  
('Kiran', 'Reddy', 'Hyderabad', '2018-09-09', 59000, 4, 3),  
('Rahul', 'Garg', 'Kolkata', '2015-03-25', 72000, 1, 4),  
('Simran', 'Chopra', 'Indore', '2022-02-14', 63000, 2, 3); 

-- Method for Updating Employee Salary and Logging the Change
UPDATE Employees 
SET Salary = 55000 
WHERE EmpID = 1;

INSERT INTO Salaries (EmpID, Old_Salary, New_Salary)
SELECT EmpID, 50000, 55000 FROM Employees WHERE EmpID = 1;

-- View: Create a view- → Department-wise Total Salary Report
CREATE VIEW DeptSalaryReport AS 
SELECT Dept_Name AS Department, SUM(Salary) AS TotalSalary 
FROM Employees 
INNER JOIN Departments ON Employees.DID = Departments.Dept_ID 
GROUP BY Dept_Name;

--  Problem 1:  Get Full Name of Employees Who Joined in 2021
SELECT EmpID, CONCAT(Emp_FirstName, ' ', Emp_LastName) AS FullName, Emp_City, DOJ, Salary, DID, BID  
FROM Employees 
WHERE YEAR(DOJ) = 2021;

--  Problem 2:  Get Full Name of Employees with salary >=50000 & <=200000
SELECT  CONCAT(Emp_FirstName, ' ', Emp_LastName) AS FullName
FROM Employees
WHERE salary BETWEEN 50000 AND 200000;

--  Problem 3:  Find Employees in the Software Department Who Joined Before 2021
SELECT Employees.* 
FROM Employees  
INNER JOIN Departments ON Departments.Dept_ID = Employees.DID 
WHERE YEAR(DOJ) < 2021 AND Departments.Dept_Name = 'Software';

--  Problem 4:  Find Employees Working in Mumbai Branch
SELECT Employees.* 
FROM Employees  
INNER JOIN Branches ON Branches.BID = Employees.BID 
WHERE Branches.Branch_Name = 'Mumbai';

--  Problem 5:  Branch-wise and Department-wise Salary Distribution Report
SELECT Branch_Name AS `Branch Name`, Dept_Name AS `Department`, SUM(Salary) AS `Total Salary` 
FROM Employees 
INNER JOIN Departments ON Departments.Dept_ID = Employees.DID 
INNER JOIN Branches ON Branches.BID = Employees.BID 
GROUP BY Dept_Name, Branch_Name;

--  Problem 6:  Find the Highest-Paid Employee in Each Department
SELECT Dept_Name AS `Department`, CONCAT(Emp_FirstName, ' ', Emp_LastName) AS `Employee`, MAX(Salary) AS `Highest Salary` 
FROM Employees 
INNER JOIN Departments ON Departments.Dept_ID = Employees.DID 
GROUP BY Dept_Name, Emp_FirstName, Emp_LastName;

--  Problem 7:  Find Employees Who Have Not Been Assigned to Any Project
-- If Emp_FirstName or Emp_LastName contains NULL, CONCAT() will return NULL.
-- CONCAT_WS(' ', ...) ignores NULLs and prevents issues.

SELECT Employees.EmpID, CONCAT_WS(' ', Employees.Emp_FirstName, Employees.Emp_LastName) AS FullName  
FROM Employees 
LEFT JOIN Employee_Project ON Employees.EmpID = Employee_Project.EmpID 
WHERE Employee_Project.ProjectID IS NULL;

--  Problem 8:  Count of Employees in Each Department
SELECT Dept_Name AS `Department`, COUNT(EmpID) AS `Total Employees` 
FROM Employees 
INNER JOIN Departments ON Employees.DID = Departments.Dept_ID 
GROUP BY Dept_Name;

--  Problem 9:  Fetch 5 Records Randomly from the Employees Table using a Subquery
SELECT * FROM Employees 
ORDER BY RAND() 
LIMIT 5; 

--  Problem 10:  Fetch  highest salary 5 Records from the Employees Table using a Subquery
SELECT * FROM Employees 
ORDER BY salary DESC
LIMIT 5; 

--  Problem 11:  Fetch  lowest salary 5 Records from the Employees Table using a Subquery
SELECT * FROM Employees 
ORDER BY salary ASC
LIMIT 5; 

--  Problem 12:  To clone a New table from Employees table
-- using  LIKE Operator 
CREATE TABLE Employees_clone LIKE Employees; -- by this only schema copied 
INSERT INTO Employees_clone
SELECT * FROM Employees;

--  Problem 13:  To Show Only ODD Record from Employees table
SELECT * FROM Employees 
WHERE MOD( EmpID,2) != 0;
