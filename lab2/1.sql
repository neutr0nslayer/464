DROP TABLE Employees;
CREATE TABLE employees (
    employee_id NUMBER(5),
    name VARCHAR2(30),
    salary NUMBER(10,2),
    designation VARCHAR2(30),
    dept_name VARCHAR2(30)
);

-- Insert sample data
INSERT INTO employees VALUES (1001, 'John Smith', 50000, 'Developer', 'IT');
INSERT INTO employees VALUES (1002, 'Sarah Johnson', 65000, 'Manager', 'HR');
INSERT INTO employees VALUES (1003, 'Mike Wilson', 45000, 'Analyst', 'Finance');
INSERT INTO employees VALUES (1004, 'Emily Brown', 70000, 'Manager', 'IT');
INSERT INTO employees VALUES (1005, 'James Davis', 80000, 'Manager', 'Finance');
INSERT INTO employees VALUES (1006, 'Emma Miller', 60000, 'Developer', 'IT');
INSERT INTO employees VALUES (1007, 'Olivia Garcia', 55000, 'Developer', 'IT');
COMMIT;


SELECT * FROM employees;