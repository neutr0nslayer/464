-- Count Digits in a Number: Write a PL/SQL block that takes a number as input and counts the total
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
