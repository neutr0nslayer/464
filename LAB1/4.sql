-- Student Grade Calculation: Write a PL/SQL block that accepts a student's score and assigns a grade
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