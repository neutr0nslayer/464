-- Reverse a Number Using WHILE Loop: Write a PL/SQL block that reads a number from the user
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