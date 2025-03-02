--Factorial Calculation: Write a PL/SQL block to read a number N from the user and calculate the
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


