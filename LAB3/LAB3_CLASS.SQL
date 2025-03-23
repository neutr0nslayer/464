SET SERVEROUTPUT ON;

-- ! TABLE WILL BE DROPPED;
DROP TABLE Employees;
-- ! TABLE WILL BE DROPPED;

CREATE TABLE employees (
    employee_id NUMBER(5),
    name VARCHAR2(30),
    salary NUMBER(10,2),
    designation VARCHAR2(30),
    dept_name VARCHAR2(30)
);

DROP TRIGGER ANNOUNCE_NEW_EMPLOYEE;
CREATE OR REPLACE TRIGGER ANNOUNCE_NEW_EMPLOYEE
AFTER INSERT ON EMPLOYEES
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('New employee added: ' || :NEW.NAME);
END;
/


-- Insert sample data
INSERT INTO employees VALUES (1001, 'John Smith', 50000, 'prof', 'IT');
INSERT INTO employees VALUES (1002, 'Sarah Johnson', 65000, 'lect', 'HR');
INSERT INTO employees VALUES (1003, 'Mike Wilson', 45000, 'prof', 'Finance');
INSERT INTO employees VALUES (1004, 'Emily Brown', 70000, 'lect', 'IT');
INSERT INTO employees VALUES (1005, 'James Davis', 80000, 'prof', 'Finance');
INSERT INTO employees VALUES (1006, 'Emma Miller', 60000, 'lect', 'IT');
INSERT INTO employees VALUES (1007, 'Olivia Garcia', 55000, 'lect', 'IT');
COMMIT;


DROP TRIGGER ANNOUNCE_NEW_SALARY;
CREATE OR REPLACE TRIGGER ANNOUNCE_NEW_SALARY
AFTER UPDATE ON EMPLOYEES
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('FOR EMPLOYEE: ' || :OLD.NAME || ' SALARY CHANGED FROM ' || :OLD.SALARY || ' TO ' || :NEW.SALARY);
END;
/

-- Update sample data to trigger the salary update trigger
UPDATE employees SET salary = 52000 WHERE employee_id = 1001;
UPDATE employees SET salary = 68000 WHERE employee_id = 1002;
UPDATE employees SET salary = 47000 WHERE employee_id = 1003;
UPDATE employees SET salary = 72000 WHERE employee_id = 1004;
UPDATE employees SET salary = 82000 WHERE employee_id = 1005;
UPDATE employees SET salary = 63000 WHERE employee_id = 1006;
UPDATE employees SET salary = 58000 WHERE employee_id = 1007;
COMMIT;



-- EXERCISE 2
DROP TABLE Member;
CREATE TABLE Member (
	member_id INT PRIMARY KEY,
	member_name VARCHAR2(10),
	no_of_borrowed_books INT
);

INSERT INTO Member VALUES (1,'Alice',0);
INSERT INTO Member VALUES (2,'Bob',0);
INSERT INTO Member VALUES (3,'Charlie',0);

DROP TABLE Book;
CREATE TABLE Book (
	book_id VARCHAR2(10) PRIMARY KEY,
	title VARCHAR2(10),
	total_copies INT,
	no_of_available_copies INT
);

INSERT INTO Book VALUES ('B-001','DB Book', 10, 10);
INSERT INTO Book VALUES ('B-002','Graphics', 5, 5);
INSERT INTO Book VALUES ('B-003','C++', 20, 20);
INSERT INTO BOOK VALUES ('B-004', 'JAVA', 1, 1);

CREATE TABLE Borrow (
	borrow_id INT PRIMARY KEY,
	member_id INT,
	book_id VARCHAR2(10),
	borrow_date DATE,
	FOREIGN KEY (member_id) REFERENCES Member,
	FOREIGN KEY (book_id) REFERENCES Book
);


DROP TRIGGER FOR_INSERT_BORROWED_BOOKS;
CREATE OR REPLACE TRIGGER FOR_INSERT_BORROWED_BOOKS
AFTER INSERT ON BORROW
FOR EACH ROW
DECLARE
    available_copies number;
BEGIN
    SELECT no_of_available_copies INTO available_copies FROM BOOK WHERE BOOK_ID = :NEW.BOOK_ID;

    IF(available_copies > 0) THEN
        UPDATE MEMBER 
        SET NO_OF_BORROWED_BOOKS = NO_OF_BORROWED_BOOKS + 1 
        WHERE MEMBER_ID = :NEW.MEMBER_ID;
    
        UPDATE BOOK
        SET NO_OF_AVAILABLE_COPIES = NO_OF_AVAILABLE_COPIES - 1
        WHERE BOOK_ID = :NEW.BOOK_ID;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'NOT ENOUGH BOOKS');
    END IF;
END;
/

-- Insert sample data to trigger the borrow update trigger
INSERT INTO Borrow VALUES (1, 1, 'B-001', SYSDATE);
INSERT INTO Borrow VALUES (2, 2, 'B-002', SYSDATE);
INSERT INTO Borrow VALUES (3, 3, 'B-003', SYSDATE);
INSERT INTO BORROW VALUES (4, 1, 'B-002', SYSDATE);
INSERT INTO BORROW VALUES (6, 1, 'B-002', SYSDATE);
INSERT INTO BORROW VALUES (7, 1, 'B-002', SYSDATE);
INSERT INTO BORROW VALUES (8, 1, 'B-002', SYSDATE);
INSERT INTO BORROW VALUES (9, 1, 'B-002', SYSDATE);
INSERT INTO BORROW VALUES (5, 1, 'B-004', SYSDATE);
INSERT INTO BORROW VALUES (6, 1, 'B-004', SYSDATE);
COMMIT;
SELECT * FROM BORROW WHERE BORROW_ID>=5;
SELECT * FROM BOOK WHERE BOOK_ID ='B-004';

SELECT /*+ ORDERED*/ * FROM 
MEMBER NATURAL JOIN 
BORROW NATURAL JOIN 
BOOK 
WHERE BOOK_ID = 'B-002';

CREATE OR REPLACE PROCEDURE SHOW_INFO(ID BOOK.BOOK_ID%TYPE) AS
    -- Define the cursor to fetch the required data
    CURSOR C IS
        SELECT /*+ ORDERED*/ b.BOOK_ID, b.TITLE, b.TOTAL_COPIES, b.NO_OF_AVAILABLE_COPIES, 
               m.MEMBER_ID, m.MEMBER_NAME, m.NO_OF_BORROWED_BOOKS, br.BORROW_ID, br.BORROW_DATE
        FROM BOOK b
        JOIN BORROW br ON b.BOOK_ID = br.BOOK_ID
        JOIN MEMBER m ON br.MEMBER_ID = m.MEMBER_ID
        WHERE b.BOOK_ID = ID;
    
    -- Declare variables to hold the fetched values
    v_BOOK_ID BOOK.BOOK_ID%TYPE;
    v_TITLE BOOK.TITLE%TYPE;
    v_TOTAL_COPIES BOOK.TOTAL_COPIES%TYPE;
    v_NO_OF_AVAILABLE_COPIES BOOK.NO_OF_AVAILABLE_COPIES%TYPE;
    v_MEMBER_ID MEMBER.MEMBER_ID%TYPE;
    v_MEMBER_NAME MEMBER.MEMBER_NAME%TYPE;
    v_NO_OF_BORROWED_BOOKS MEMBER.NO_OF_BORROWED_BOOKS%TYPE;
    v_BORROW_ID BORROW.BORROW_ID%TYPE;
    v_BORROW_DATE BORROW.BORROW_DATE%TYPE;
BEGIN
    -- Open the cursor
    OPEN C;
    
    -- Loop through the cursor and fetch data
    LOOP
        FETCH C INTO v_BOOK_ID, v_TITLE, v_TOTAL_COPIES, v_NO_OF_AVAILABLE_COPIES, 
                     v_MEMBER_ID, v_MEMBER_NAME, v_NO_OF_BORROWED_BOOKS, v_BORROW_ID, v_BORROW_DATE;
        EXIT WHEN C%NOTFOUND;  -- Exit the loop if no more rows are fetched

        -- Print the fetched values using DBMS_OUTPUT
        DBMS_OUTPUT.PUT_LINE('Book ID: ' || v_BOOK_ID);
        DBMS_OUTPUT.PUT_LINE('Title: ' || v_TITLE);
        DBMS_OUTPUT.PUT_LINE('Total Copies: ' || v_TOTAL_COPIES);
        DBMS_OUTPUT.PUT_LINE('Available Copies: ' || v_NO_OF_AVAILABLE_COPIES);
        DBMS_OUTPUT.PUT_LINE('Member ID: ' || v_MEMBER_ID);
        DBMS_OUTPUT.PUT_LINE('Member Name: ' || v_MEMBER_NAME);
        DBMS_OUTPUT.PUT_LINE('No of Borrowed Books: ' || v_NO_OF_BORROWED_BOOKS);
        DBMS_OUTPUT.PUT_LINE('Borrow ID: ' || v_BORROW_ID);
        DBMS_OUTPUT.PUT_LINE('Borrow Date: ' || v_BORROW_DATE);
        DBMS_OUTPUT.PUT_LINE('----------------------------');
    END LOOP;
    
    -- Close the cursor after the loop finishes
    CLOSE C;
END;
/

BEGIN 
    SHOW_INFO('B-002');
END;
/


DROP TRIGGER trigger_insert_borrow;
create or REPLACE trigger trigger_insert_borrow 
BEFORE INSERT ON BORROW 
FOR EACH ROW
DECLARE 
    AVL_COPIES NUMBER;
BEGIN
    SELECT no_of_available_copies INTO AVL_COPIES FROM BOOK WHERE book_id = :NEW.book_id;
    IF(AVL_COPIES > 0)THEN
        UPDATE BOOK SET no_of_available_copies = no_of_available_copies-1 WHERE book_id= :NEW.book_id;
        UPDATE Member SET no_of_borrowed_books = no_of_borrowed_books +1 WHERE MEMBER_ID = :NEW.MEMBER_ID;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'NO BOOK AVL');
    END IF;
END;
/

-- Cleanup
DROP TRIGGER UPDATE_BORROWED_BOOKS;
DROP TABLE Borrow;
DROP TABLE Book;
DROP TABLE Member;
DROP TRIGGER ANNOUNCE_NEW_SALARY;
DROP TRIGGER ANNOUNCE_NEW_EMPLOYEE;
DROP TABLE Employees;