-- Generate Fibonacci Series: Write a PL/SQL block that generates the Fibonacci series up to N terms
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
