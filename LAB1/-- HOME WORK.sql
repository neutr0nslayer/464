-- HOME WORK
-- LAB 1 MAN
-- CREATE A TABLE STUDENTS WITH THE FOLLOWING ATTRIBUTES (STUDENT_ID PK, STUDENT_NAME, DEPT_NAME)
-- CREATE ANOTHER TABLE GRADES WITH THE FOLLOWING ATTRIBUTES (STUDENT_ID PK, COURSE_ID PK, CREDIT, GRADE)
-- 
DROP TABLE STUDENTS;
CREATE TABLE STUDENTS(
    STUDENT_ID VARCHAR2(50) PRIMARY KEY,
    STUDENT_NAME VARCHAR2(50),
    DEPT_NAME VARCHAR2(50)
);

DROP TABLE GRADES;
CREATE TABLE GRADES(
    STUDENT_ID VARCHAR2(50),
    COURSE_ID VARCHAR2(50),
    CREDIT NUMBER,
    GRADE NUMBER,
    PRIMARY KEY(STUDENT_ID, COURSE_ID)
);

-- (STUDENT_ID PK, STUDENT_NAME, DEPT_NAME)
INSERT INTO STUDENTS VALUES('2021-2-60-008', 'FARDIN', 'CSE');
INSERT INTO STUDENTS VALUES('2021-2-60-009', 'RAHIM', 'CSE');
INSERT INTO STUDENTS VALUES('2021-2-60-010', 'KARIM', 'CSE');
INSERT INTO STUDENTS VALUES('2021-2-60-011', 'JAMAL', 'CSE');

-- Grades for FARDIN (STUDENT_ID PK, COURSE_ID PK, CREDIT, GRADE)
INSERT INTO GRADES VALUES('2021-2-60-008', 'CSE101', '3', 3.50);  -- A-
INSERT INTO GRADES VALUES('2021-2-60-008', 'CSE102', '3', 3.00);  -- B
INSERT INTO GRADES VALUES('2021-2-60-008', 'CSE103', '3', 3.50);  -- A-
INSERT INTO GRADES VALUES('2021-2-60-008', 'CSE104', '3', 3.00);  -- B
INSERT INTO GRADES VALUES('2021-2-60-008', 'CSE105', '3', 3.50);  -- A-
INSERT INTO GRADES VALUES('2021-2-60-008', 'CSE106', '3', 3.00);  -- B

-- Grades for RAHIM (STUDENT_ID PK, COURSE_ID PK, CREDIT, GRADE)
INSERT INTO GRADES VALUES('2021-2-60-009', 'CSE101', '3', 3.75);  -- A
INSERT INTO GRADES VALUES('2021-2-60-009', 'CSE102', '3', 3.25);  -- B+
INSERT INTO GRADES VALUES('2021-2-60-009', 'CSE103', '3', 2.75);  -- B-
INSERT INTO GRADES VALUES('2021-2-60-009', 'CSE104', '3', 3.25);  -- B+
INSERT INTO GRADES VALUES('2021-2-60-009', 'CSE105', '3', 4.00);  -- A+
INSERT INTO GRADES VALUES('2021-2-60-009', 'CSE106', '3', 3.00);  -- B

-- Grades for KARIM (STUDENT_ID PK, COURSE_ID PK, CREDIT, GRADE)
INSERT INTO GRADES VALUES('2021-2-60-010', 'CSE101', '3', 2.75);  -- B-
INSERT INTO GRADES VALUES('2021-2-60-010', 'CSE102', '3', 3.00);  -- B
INSERT INTO GRADES VALUES('2021-2-60-010', 'CSE103', '3', 3.25);  -- B+
INSERT INTO GRADES VALUES('2021-2-60-010', 'CSE104', '3', 3.75);  -- A
INSERT INTO GRADES VALUES('2021-2-60-010', 'CSE105', '3', 2.25);  -- C
INSERT INTO GRADES VALUES('2021-2-60-010', 'CSE106', '3', 3.00);  -- B

-- Grades for JAMAL (STUDENT_ID PK, COURSE_ID PK, CREDIT, GRADE)
INSERT INTO GRADES VALUES('2021-2-60-011', 'CSE101', '3', 3.25);  -- B+
INSERT INTO GRADES VALUES('2021-2-60-011', 'CSE102', '3', 3.75);  -- A
INSERT INTO GRADES VALUES('2021-2-60-011', 'CSE103', '3', 4.00);  -- A+
INSERT INTO GRADES VALUES('2021-2-60-011', 'CSE104', '3', 3.00);  -- B
INSERT INTO GRADES VALUES('2021-2-60-011', 'CSE105', '3', 3.25);  -- B+
INSERT INTO GRADES VALUES('2021-2-60-011', 'CSE106', '3', 3.75);  -- A
COMMIT;

-- WRITE PLSQL BLOCK THAT CALCULTES THE STUDENTS CGPA, TOTAL CREDITS COMPETED AND SHOWS THE REPORT LIKE THE FOLLOWING
-- STUDENT ID STUDENT NAME TOTAL CREDITS CGPA
-- 2021-2-60-008 FARDIN 12 3.5
-- FOR CGPA CALCULATAION FOLLOW THE UNIVERSITY GRADEING SYSTEM

DECLARE
    CURSOR C IS 
        SELECT * FROM STUDENTS;
    V_STUDENT_ID STUDENTS.STUDENT_ID%TYPE;
    V_STUDENT_NAME STUDENTS.STUDENT_NAME%TYPE;
    V_DEPT_NAME STUDENTS.DEPT_NAME%TYPE;
    GPA_CR NUMBER := 0;
    GP NUMBER := 0;
    CGPA NUMBER;
    V_GRADE NUMBER;
    V_CREDIT NUMBER;
    V_COUNT NUMBER := 0;
BEGIN
    OPEN C;
    DBMS_OUTPUT.PUT_LINE(
        RPAD('STUDENT ID', 20) || 
        RPAD('STD NAME', 10) || 
        RPAD('TOTCREDITS', 11) || 
        RPAD('CGPA', 11)
    );
    DBMS_OUTPUT.PUT_LINE(
        RPAD('-------------------', 20) || 
        RPAD('---------', 10) || 
        RPAD('----------', 11) || 
        RPAD('-----', 11)
    );
    LOOP 
        FETCH C INTO V_STUDENT_ID, V_STUDENT_NAME, V_DEPT_NAME;
        EXIT WHEN C%NOTFOUND;
        GPA_CR := 0;
        GP := 0;
        V_COUNT := 0;
        FOR I IN (SELECT * FROM GRADES WHERE STUDENT_ID = V_STUDENT_ID) LOOP
            V_GRADE := I.GRADE;
            V_CREDIT := I.CREDIT;
            GPA_CR := GPA_CR + V_CREDIT;
            GP := GP + (V_GRADE * V_CREDIT);
            V_COUNT := V_COUNT + 1;
        END LOOP;
        CGPA := GP / GPA_CR;
        
        DBMS_OUTPUT.PUT_LINE(
            RPAD(V_STUDENT_ID, 20) || 
            RPAD(V_STUDENT_NAME, 10) || 
            RPAD(TO_CHAR(GPA_CR), 11) || 
            RPAD(TO_CHAR(CGPA, '9.99'), 11)
        );
    END LOOP;
    CLOSE C;

END;
/