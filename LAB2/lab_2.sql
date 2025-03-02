

-- ! TABLE WILL BE DROPPED;
DROP TABLE Employees;
-- ! TABLE WILL BE DROPPED;

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


-- * 1. Retrieve Employee Data Using Cursors – Write a PL/SQL block using Explicit Cursors to retrieve
-- * and display employee names and salaries.
DECLARE
    CURSOR EMP_CURSOR IS
        SELECT NAME, SALARY FROM EMPLOYEES;
    V_NAME EMPLOYEES.NAME%TYPE;
    V_SALARY EMPLOYEES.SALARY%TYPE;
BEGIN
    OPEN EMP_CURSOR;
    LOOP
 	FETCH EMP_CURSOR INTO V_NAME, V_SALARY;
	EXIT WHEN EMP_CURSOR%NOTFOUND;
	DBMS_OUTPUT.PUT_LINE('NAME: ' || V_NAME || ' SALARY: ' || V_SALARY );    

    END LOOP;
CLOSE EMP_CURSOR;
END;
/

-- * 2. Calculate Bonus Using Functions – Create a function that takes an employee ID and returns a bonus
-- * amount (10% of salary).

DROP FUNCTION CALCULATE_BONUS;
CREATE OR REPLACE FUNCTION CALCULATE_BONUS (V_EMP_ID EMPLOYEES.EMPLOYEE_ID%TYPE) RETURN EMPLOYEES.SALARY%TYPE AS
	CURSOR C IS 
		SELECT SALARY FROM EMPLOYEES
		WHERE EMPLOYEE_ID = V_EMP_ID; 
	V_SALARY EMPLOYEES.SALARY%TYPE;
	V_BONUS EMPLOYEES.SALARY%TYPE;
	
BEGIN
	OPEN C;
	LOOP
		FETCH C INTO V_SALARY;
		EXIT WHEN C%NOTFOUND;
		V_BONUS :=V_SALARY*.1;
		RETURN V_BONUS;
	END LOOP;
	CLOSE C;
	RETURN 0;
	
END;
/


DECLARE
    CURSOR EMP_CURSOR IS
        SELECT EMPLOYEE_ID, NAME FROM EMPLOYEES;
    V_EMP_ID EMPLOYEES.EMPLOYEE_ID%TYPE;
    V_NAME EMPLOYEES.NAME%TYPE;
    V_BONUS EMPLOYEES.SALARY%TYPE;
BEGIN
    OPEN EMP_CURSOR;
    LOOP
 	FETCH EMP_CURSOR INTO V_EMP_ID, V_NAME;
	EXIT WHEN EMP_CURSOR%NOTFOUND;
	V_BONUS := 0;
	V_BONUS := CALCULATE_BONUS(V_EMP_ID);
	DBMS_OUTPUT.PUT_LINE('NAME: ' || V_NAME || ' SALARY: ' || V_BONUS );    

    END LOOP;
CLOSE EMP_CURSOR;
END;
/
-- * 3. Implement a Procedure for Employee Promotion – Write a stored procedure that increases an
-- * employee’s salary and updates their designation.

DROP PROCEDURE UPDATE_SALARY_DESG;
CREATE OR REPLACE PROCEDURE UPDATE_SALARY_DESG (V_EMP_ID EMPLOYEES.EMPLOYEE_ID%TYPE, NEW_SALARY EMPLOYEES.SALARY%TYPE, NEW_DESG EMPLOYEES.DESIGNATION%TYPE ) AS
	
BEGIN
	UPDATE EMPLOYEES
	SET DESIGNATION = NEW_DESG, SALARY = NEW_SALARY
	WHERE EMPLOYEE_ID = V_EMP_ID;
	COMMIT;
END;
/


DECLARE
	V_EMP_ID EMPLOYEES.EMPLOYEE_ID%TYPE;
    V_DESG EMPLOYEES.DESIGNATION%TYPE;
    V_SALARY EMPLOYEES.SALARY%TYPE;
    
BEGIN
	V_EMP_ID := 1001;
    V_DESG := 'lect';
    V_SALARY := 10000;

	UPDATE_SALARY_DESG(V_EMP_ID, V_SALARY, V_DESG) ;  
END;
/

SELECT * FROM EMPLOYEES WHERE EMPLOYEE_ID = 1001;


-- * 4. Handle Exceptions in Data Retrieval – Implement exception handling for cases where an employee
-- * ID does not exist in the database.

DECLARE
	V_EMP_ID EMPLOYEES.EMPLOYEE_ID%TYPE;
	V_NAME EMPLOYEES.NAME%TYPE;
	V_SALARY EMPLOYEES.SALARY%TYPE;
BEGIN
	V_EMP_ID := 1008;
	SELECT NAME, SALARY INTO V_NAME, V_SALARY FROM EMPLOYEES WHERE EMPLOYEE_ID = V_EMP_ID;
	DBMS_OUTPUT.PUT_LINE('NAME: ' || V_NAME || ' SALARY: ' || V_SALARY );

EXCEPTION
	WHEN NO_DATA_FOUND THEN 
		DBMS_OUTPUT.PUT_LINE('EMPLOYEE ID DOES NOT EXIST');
END;
/
-- * 5. Raise Custom Errors for Business Rules – Write a procedure that checks salary conditions and raises
-- * an error if the salary is below a threshold.

DROP PROCEDURE CHECK_SALARY;
CREATE OR REPLACE PROCEDURE CHECK_SALARY (V_EMP_ID EMPLOYEES.EMPLOYEE_ID%TYPE) AS
    V_SALARY EMPLOYEES.SALARY%TYPE;
BEGIN
    SELECT SALARY INTO V_SALARY FROM EMPLOYEES WHERE EMPLOYEE_ID = V_EMP_ID;
    IF V_SALARY < 30000 THEN
        RAISE_APPLICATION_ERROR(-20001, 'SALARY TOO LOW FOR ID: ' || V_EMP_ID );
    END IF;
END;
/

BEGIN
	CHECK_SALARY(1001);
END;
/

-- CLEANUP
DROP FUNCTION CALCULATE_BONUS;
DROP PROCEDURE UPDATE_SALARY_DESG;
DROP PROCEDURE CHECK_SALARY;
DROP TABLE Employees;
