-- Find the Largest of Three Numbers: Write a PL/SQL block that reads three numbers and determines
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