-- Identify Employees with High Salaries: Write a PL/SQL block that iterates through the employees
-- table and prints the names of employees earning more than 60000 using a LOOP and IF condition.
-- Employees table has three attributes: employee_id (primary key), name and salary. Make sure that
-- you have created the table and inserted some tuples.

drop table employees;
CREATE TABLE employees (
    employee_id NUMBER primary key,
    name VARCHAR2(20),
    salary NUMBER
);

INSERT INTO employees VALUES (1, 'John', 50000);
INSERT INTO employees VALUES (2, 'Jane', 70000);
INSERT INTO employees VALUES (3, 'Doe', 80000);
INSERT INTO employees VALUES (4, 'Smith', 60000);
INSERT INTO employees VALUES (5, 'Doe', 900000);
ALTER TABLE employees ADD dept_name VARCHAR2(20);

UPDATE employees SET dept_name = 'HR' WHERE employee_id in (1, 3, 5);
UPDATE employees SET dept_name = 'IT' WHERE employee_id in (2, 4);
COMMIT;
SELECT * FROM employees;

-- PL/SQL block 
DECLARE
    v_id employees.EMPLOYEE_ID%TYPE;
    v_name employees.NAME%TYPE;
    v_salary employees.SALARY%TYPE;
    CURSOR EMP_CURSOR IS
        SELECT * FROM EMPLOYEES;
BEGIN
    OPEN EMP_CURSOR;
    LOOP
        FETCH EMP_CURSOR INTO v_id, v_name, v_salary;
        EXIT WHEN EMP_CURSOR%NOTFOUND;
        IF v_salary > 60000 THEN
            DBMS_OUTPUT.PUT_LINE('Employee Name: ' || v_id ||'-'|| v_name || ' Salary: ' || v_salary);
        END IF;
    END LOOP;
    CLOSE EMP_CURSOR;
END;
/