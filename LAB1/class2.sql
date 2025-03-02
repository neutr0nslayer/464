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

DECLARE
    CURSOR C IS
        SELECT * FROM employees 
        FOR UPDATE OF salary;
    V_ID EMPLOYEES.EMPLOYEE_ID%TYPE;
    V_NAME EMPLOYEES.NAME%TYPE;
    V_SALARY EMPLOYEES.SALARY%TYPE;
    V_DEPT EMPLOYEES.DEPT_NAME%TYPE;
BEGIN
    OPEN C;
    LOOP
        FETCH C INTO V_ID, V_NAME, V_SALARY, V_DEPT;
        EXIT WHEN C%NOTFOUND;
        --DBMS_OUTPUT.PUT_LINE(V_DEPT);
        IF (V_SALARY>= 100000) THEN
            UPDATE EMPLOYEES
            SET SALARY = SALARY + (SALARY*.1)
            WHERE CURRENT OF C;
        ELSIF (V_SALARY<100000) THEN
            
            IF (V_DEPT = 'HR') THEN
                UPDATE EMPLOYEES
                SET SALARY = SALARY + (SALARY*.15)
                WHERE CURRENT OF C;
            ELSIF (V_DEPT = 'IT') THEN
                UPDATE EMPLOYEES
                SET SALARY = SALARY + (SALARY*.20)
                WHERE CURRENT OF C;
            ELSE
                UPDATE EMPLOYEES
                SET SALARY = SALARY + (SALARY*.125)
                WHERE CURRENT OF C;
            END IF;
        END IF;
    END LOOP;
    COMMIT;
    CLOSE C;
END;
/