CONNECT sys/password AS SYSDBA;
CREATE USER CSE464 IDENTIFIED BY CSE464;
GRANT CONNECT, CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE TRIGGER, UNLIMITED TABLESPACE TO c##CSE464;

CONNECT / AS SYSDBA 



GRANT PLUSTRACE TO C##CSE464;
GRANT SELECT ON v_$session TO C##CSE464;
GRANT SELECT ON v_$sql_plan TO C##CSE464;
GRANT SELECT ON v_$sql_plan_statistics TO C##CSE464;
SELECT * FROM dba_roles WHERE role = 'PLUSTRACE';

CONNECT CSE464/CSE464

drop table employees;
drop table departments;
CREATE TABLE employees(
    employee_id NUMBER PRIMARY KEY,
    name VARCHAR2(20),
    salary NUMBER,
    dept_id NUMBER
);

INSERT INTO employees VALUES (1, 'Alice', 75000, 1);
INSERT INTO employees VALUES (2, 'Bob', 50000, 2);
INSERT INTO employees VALUES (3, 'Charlie', 12000, 1);
INSERT INTO employees VALUES (4, 'Danny', 100000, 2);
INSERT INTO employees VALUES (5, 'Elton', 90000, 1);

CREATE TABLE departments(
    dept_id NUMBER PRIMARY KEY,
    dept_name VARCHAR2(20),
    location VARCHAR2(50)
);

INSERT INTO departments VALUES (1, 'HR', 'Building A');
INSERT INTO departments VALUES (2, 'IT', 'Building B');
INSERT INTO departments VALUES (3, 'Finance', 'Building C');
commit;
SET SERVEROUTPUT ON;
SET AUTOTRACE ON;

EXPLAIN PLAN FOR
SELECT * FROM Employees WHERE salary >= 50000;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);



CREATE INDEX IDX_EMP_SALARY ON EMPLOYEES(SALARY);

SELECT * FROM employees WHERE salary >= 50000;

select * from table(dbms_xplan.display_cursor(sql_id=>'0s30hftabthyy', format=>'ALLSTATS LAST'));


SELECT /*+ INDEX(EMPLOYEES IDX_EMP_SALARY) */ * FROM EMPLOYEES WHERE SALARY >=50000;

select * from table(dbms_xplan.display_cursor(sql_id=>'3hr19a3hbyd3z', format=>'ALLSTATS LAST'));


SELECT /*+ INDEX(employees idx_employee_name) */ * FROM employees WHERE name = 'Alice';

SELECT /*+ FULL(employees) */ * FROM employees WHERE salary > 10000;

select * from EMPLOYEES;
SELECT /*+ ordered */ e.name, d.dept_name
FROM employees e
JOIN departments d 
ON e.dept_id = d.dept_id;
DESC employees;


SELECT /*+ USE_NL(employees departments) */ e.name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

SELECT /*+ USE_HASH(employees departments) */ e.name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

SELECT /*+ USE_MERGE(employees departments) */ e.name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

SELECT /*+ PARALLEL(employees, 4) */ * FROM employees WHERE salary > 60000;

select * from table(dbms_xplan.display_cursor(sql_id=>'50c2qyv78bvgq', format=>'ALLSTATS LAST'));


SELECT /*+ NO_PARALLEL(employees) */ * FROM employees WHERE salary > 60000;

SELECT /*+ NO_UNNEST */ * 
FROM employees 
WHERE dept_id IN (SELECT dept_id FROM departments WHERE location = 'Building A');

SELECT /*+ MATERIALIZE */ * 
FROM (SELECT dept_id, COUNT(*) FROM employees GROUP BY dept_id);

DROP TRIGGER t1;
CREATE OR REPLACE TRIGGER t1 
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
	DBMS_OUTPUT.PUT_LINE('Old salary: ' || :OLD.salary || ' New Salary: ' || :NEW.salary);
END;
/

BEGIN
    UPDATE employees SET salary = salary + 1000 WHERE name = 'Alice';
    ROLLBACK;  -- Undo changes
    COMMIT;  -- Finalize changes
END;
/

SELECT * FROM EMPLOYEES;

BEGIN
    UPDATE employees SET salary = salary + 500 WHERE name = 'Alice';
    SAVEPOINT sp1;
    UPDATE employees SET salary = salary + 700 WHERE name = 'Bob';
    ROLLBACK; 
    COMMIT;
END;
/

BEGIN
    UPDATE employees SET salary = salary + 500 WHERE name = 'Alice';
    SAVEPOINT sp1;
    UPDATE employees SET salary = salary + 700 WHERE name = 'Bob';
    ROLLBACK TO sp1;  -- Undo second update but keep first
    COMMIT;
END;
/

GRANT EXECUTE ON DBMS_LOCK TO CSE464;

-- Transaction 1
BEGIN
    UPDATE employees SET salary = salary + 500 WHERE name = 'Alice';
    DBMS_LOCK.SLEEP(5);
    UPDATE employees SET salary = salary + 500 WHERE name = 'Bob';
    COMMIT;
END;
/

-- Transaction 2 (Executed simultaneously in another session)
BEGIN
    UPDATE employees SET salary = salary + 1000 WHERE name = 'Bob';
    DBMS_LOCK.SLEEP(5);
    UPDATE employees SET salary = salary + 1000 WHERE name = 'Alice';
    COMMIT;
END;
/

