DROP TABLE Employees;
CREATE TABLE employees (
    employee_id NUMBER(5),
    name VARCHAR2(30),
    salary NUMBER(10,2),
    designation VARCHAR2(30),
    dept_name VARCHAR2(30)
);

-- Insert sample data
INSERT INTO employees VALUES (1001, 'John Smith', 50000, 'prof', 'IT');
INSERT INTO employees VALUES (1002, 'Sarah Johnson', 65000, 'lect', 'HR');
INSERT INTO employees VALUES (1003, 'Mike Wilson', 45000, 'prof', 'Finance');
INSERT INTO employees VALUES (1004, 'Emily Brown', 70000, 'lect', 'IT');
INSERT INTO employees VALUES (1005, 'James Davis', 80000, 'prof', 'Finance');
INSERT INTO employees VALUES (1006, 'Emma Miller', 60000, 'lect', 'IT');
INSERT INTO employees VALUES (1007, 'Olivia Garcia', 55000, 'lect', 'IT');
COMMIT;



-- PL/SQL block: write and exicute a stored procedure that gives 10% salary increase to prof
DROP PROCEDURE INCREASE_SALARY;
CREATE OR REPLACE PROCEDURE INCREASE_SALARY(p_emp_id in employees.employee_id%TYPE, P_emp_salary_percent IN NUMBER) AS

BEGIN
    UPDATE EMPLOYEES
    SET SALARY = SALARY + (SALARY * P_emp_salary_percent / 100)
    WHERE EMPLOYEE_ID = p_emp_id;
END;
/

-- Exicute the procedure
DECLARE 
    CURSOR C IS 
        SELECT EMPLOYEE_ID, DESIGNATION FROM EMPLOYEES;
    V_EMP_ID EMPLOYEES.EMPLOYEE_ID%TYPE;
    V_EMP_DESG EMPLOYEES.DESIGNATION%TYPE;
    V_EMP_INC NUMBER ;
BEGIN
    V_EMP_INC := 10;
    OPEN C;
    LOOP
        FETCH C INTO V_EMP_ID, V_EMP_DESG;
        EXIT WHEN C%NOTFOUND;
        IF V_EMP_DESG = 'prof' THEN
            INCREASE_SALARY(V_EMP_ID, V_EMP_INC);
        END IF;
    END LOOP;
    CLOSE C;
    COMMIT;
    
END;
/
