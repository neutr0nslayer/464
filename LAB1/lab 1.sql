-- 1. Sum of First N Natural Numbers: Write a PL/SQL block that reads a number N from the user and
-- calculates the sum of the first N natural numbers using a LOOP.

ACCEPT v_number NUMBER PROMPT 'Enter a number: ';
declare
   v_number number;
   v_result number := 0;
begin
   v_number := &v_number;
   for i in 1..v_number loop
      v_result := v_result + i;
   end loop;
   dbms_output.put_line('the sum of the first '
                        || v_number
                        || ' natural numbers: '
                        || v_result);
end;
/


-- 2. Factorial Calculation: Write a PL/SQL block to read a number N from the user and calculate the
-- factorial of N using a FOR loop.

SET SERVEROUTPUT ON
ACCEPT factorial_v NUMBER PROMPT 'ENTER A NUMBER: ';
DECLARE 
    factorial_v NUMBER;
    result NUMBER := 1;
BEGIN
    factorial_v := &factorial_v;
    FOR i in 1..factorial_v loop
        result := result * i;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('FACTORIAL OF ' || factorial_v || ' IS ' || result);
END;
/


-- 3. Even or Odd Number Check: Write a PL/SQL block that takes a number as input and checks whether
-- it is even or odd using an IF-THEN-ELSE statement.

SET SERVEROUTPUT ON
ACCEPT v_number NUMBER PROMPT 'Enter a number: ';
DECLARE
    v_number NUMBER;
    v_result NUMBER:= 1;
BEGIN
    v_number := &v_number;
    IF MOD(v_number, 2) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('The number ' || v_number || ' is even.');
    ELSE 
        DBMS_OUTPUT.PUT_LINE('The number ' || v_number || ' is odd.');
    END IF;
END;
/

-- 4. Student Grade Calculation: Write a PL/SQL block that accepts a student's score and assigns a grade
-- based on the following conditions:
-- o 90 and above: Grade A
-- o 80-89: Grade B
-- o 70-79: Grade C
-- o Below 70: Fail Use a CASE statement to implement this logic.

SET SERVEROUTPUT ON
ACCEPT v_number NUMBER PROMPT 'Enter a number: ';
DECLARE
    v_number NUMBER;
    v_result NUMBER:= 1;
BEGIN
    v_number := &v_number;
    CASE
        WHEN v_number >= 90 THEN
            DBMS_OUTPUT.PUT_LINE('Grade A');
        WHEN v_number >= 80 AND v_number <= 89 THEN
            DBMS_OUTPUT.PUT_LINE('Grade B');
        WHEN v_number >= 70 AND v_number <= 79 THEN
            DBMS_OUTPUT.PUT_LINE('Grade C');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Fail');
    END CASE;
END;
/


-- 5. Reverse a Number Using WHILE Loop: Write a PL/SQL block that reads a number from the user
-- and reverses its digits using a WHILE loop.

SET SERVEROUTPUT ON
ACCEPT v_number NUMBER PROMPT 'Enter a number: ';
DECLARE
    v_number VARCHAR(100);
    DUP VARCHAR(100):='';
    reversed_number VARCHAR(100);
BEGIN
    v_number := &v_number;
    DUP := v_number;
    reversed_number := '';
    WHILE LENGTH(v_number) > 0 LOOP
        reversed_number := reversed_number || SUBSTR(v_number, -1);
        v_number := SUBSTR(v_number, 1 , LENGTH(v_number) - 1);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Number ' ||DUP||' reversed: '|| reversed_number);
END;
/

-- 6. Identify Employees with High Salaries: Write a PL/SQL block that iterates through the employees
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

-- 7. Find the Largest of Three Numbers: Write a PL/SQL block that reads three numbers and determines
-- the largest using an IF-THEN-ELSE statement.

ACCEPT NUM1 NUMBER PROMPT 'Enter First Number: ';
ACCEPT NUM2 NUMBER PROMPT 'Enter Second Number: ';
ACCEPT NUM3 NUMBER PROMPT 'Enter Third Number: ';
DECLARE
    v_num1 NUMBER;
    v_num2 NUMBER;
    v_num3 NUMBER;
    v_largest NUMBER;
BEGIN
    v_num1 := &NUM1;
    v_num2 := &NUM2;
    v_num3 := &NUM3;
    IF v_num1 > v_num2 AND v_num1 > v_num3 THEN
        v_largest := v_num1;
    ELSIF v_num2 > v_num1 AND v_num2 > v_num3 THEN
        v_largest := v_num2;
    ELSE
        v_largest := v_num3;
    END IF;
    DBMS_OUTPUT.PUT_LINE('Largest Number: ' || v_largest);
END;
/

-- 8. Count Digits in a Number: Write a PL/SQL block that takes a number as input and counts the total
-- number of digits using a WHILE loop.

ACCEPT V_INPUT PROMPT 'Enter a number: '
DECLARE
    V_INPUT VARCHAR2(100);
    V_COUNT NUMBER := 0;
BEGIN
    V_INPUT := &V_INPUT;
    WHILE V_INPUT > 0 LOOP
        V_COUNT := V_COUNT + 1;
        V_INPUT := V_INPUT / 10;
        DBMS_OUTPUT.PUT_LINE('V_INPUT: ' || V_INPUT);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Total number of digits: ' || V_COUNT);
END;


-- 9. Generate Fibonacci Series: Write a PL/SQL block that generates the Fibonacci series up to N terms
-- using a LOOP.

ACCEPT N PROMPT 'Enter the number of terms: ';
DECLARE
    N NUMBER;
    F1 NUMBER := 0;
    F2 NUMBER := 1;
    F3 NUMBER;
BEGIN
    N := &N;
    DBMS_OUTPUT.PUT_LINE('Fibonacci Series: ');
    

    IF N >= 1 THEN
        DBMS_OUTPUT.PUT_LINE(F1);
    ELSIF N >= 2 THEN
        DBMS_OUTPUT.PUT_LINE(F1);
        DBMS_OUTPUT.PUT_LINE(F2);
    ELSE
        DBMS_OUTPUT.PUT_LINE(F1);
        DBMS_OUTPUT.PUT_LINE(F2);
        FOR I IN 3..N LOOP
            F3 := F1 + F2;
            DBMS_OUTPUT.PUT_LINE(F3);
            F1 := F2;
            F2 := F3;
            END LOOP;
    END IF;
    
END;
/

-- 10. Simple Interest Calculation: Write a PL/SQL block that calculates the simple interest based on user
-- input values for principal, rate, and time.

DECLARE
    principal NUMBER := &principal;
    rate NUMBER := &rate;
    time NUMBER := &time;
    interest NUMBER;
BEGIN
    interest := (principal * rate * time) / 100;
    DBMS_OUTPUT.PUT_LINE('Simple Interest: ' || interest);
END;

