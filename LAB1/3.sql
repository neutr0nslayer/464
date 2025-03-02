-- Even or Odd Number Check: Write a PL/SQL block that takes a number as input and checks whether
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