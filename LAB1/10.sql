-- Simple Interest Calculation: Write a PL/SQL block that calculates the simple interest based on user
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
