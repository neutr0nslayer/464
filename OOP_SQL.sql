-- Clean up existing objects
DROP MATERIALIZED VIEW EMP_MV1;
DROP MATERIALIZED VIEW LOG ON employee_details;
DROP TABLE employee_details;
DROP TABLE info_employee;
DROP TYPE name_type;
DROP TYPE address_type;

-- Create object types
CREATE TYPE name_type AS OBJECT (
    first_name VARCHAR2(50),
    last_name VARCHAR2(50)
);
/

CREATE TYPE address_type AS OBJECT (
    state VARCHAR2(50),
    zip VARCHAR2(10)
);
/

-- Create base tables
CREATE TABLE info_employee (
    emp_id NUMBER(10),
    emp_name name_type,
    emp_address address_type,
    CONSTRAINT emp_id_pk PRIMARY KEY (emp_id)
);

CREATE TABLE employee_details (
    empd_id NUMBER(10),
    emp_id NUMBER(10),
    emp_dsgn VARCHAR2(50),
    emp_salary NUMBER(10,2),
    CONSTRAINT empd_id_pk PRIMARY KEY (empd_id),
    FOREIGN KEY (emp_id) REFERENCES info_employee(emp_id)
);

-- Insert sample data
INSERT INTO info_employee VALUES (1, name_type('John', 'Doe'), address_type('California', '90001'));
INSERT INTO info_employee VALUES (2, name_type('Jane', 'Smith'), address_type('New York', '10001'));
INSERT INTO info_employee VALUES (3, name_type('Alice', 'Johnson'), address_type('Texas', '73301'));
INSERT INTO info_employee VALUES (4, name_type('Bob', 'Brown'), address_type('Florida', '33101'));
INSERT INTO info_employee VALUES (5, name_type('Charlie', 'Davis'), address_type('Illinois', '60601'));
INSERT INTO info_employee VALUES (6, name_type('Eve', 'Wilson'), address_type('Ohio', '44101'));
INSERT INTO info_employee VALUES (7, name_type('David', 'Miller'), address_type('Washington', '98001'));
INSERT INTO info_employee VALUES (8, name_type('Grace', 'Lee'), address_type('Oregon', '97201'));

INSERT INTO employee_details VALUES (1, 1, 'Manager', 80000);
INSERT INTO employee_details VALUES (2, 2, 'Developer', 70000);
INSERT INTO employee_details VALUES (3, 3, 'Designer', 60000);
INSERT INTO employee_details VALUES (4, 4, 'Analyst', 50000);
INSERT INTO employee_details VALUES (5, 5, 'Tester', 40000);
INSERT INTO employee_details VALUES (6, 6, 'HR', 55000);
INSERT INTO employee_details VALUES (7, 1, 'Manager', 85000);
INSERT INTO employee_details VALUES (8, 2, 'Developer', 72000);
COMMIT;

-- Create materialized view log including all needed columns
CREATE MATERIALIZED VIEW LOG ON employee_details
WITH PRIMARY KEY, ROWID, SEQUENCE (emp_id, emp_dsgn, emp_salary)
INCLUDING NEW VALUES;

-- ✅ FIXED: include full primary key (empd_id) in materialized view
CREATE MATERIALIZED VIEW EMP_MV1
BUILD IMMEDIATE
REFRESH FAST ON COMMIT
AS
SELECT 
    empd_id,  -- include the full primary key of the base table
    emp_id,
    emp_dsgn AS dsg,
    emp_salary AS salary
FROM 
    employee_details;

-- ✅ Test: update the source table
UPDATE employee_details SET emp_salary = 95000 WHERE emp_id = 1;
COMMIT;

-- ✅ Query the materialized view to verify update
SELECT * FROM EMP_MV1;
