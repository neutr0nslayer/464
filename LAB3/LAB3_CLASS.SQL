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
BEGIN
    UPDATE MEMBER 
    SET NO_OF_BORROWED_BOOKS = NO_OF_BORROWED_BOOKS + 1 
    WHERE MEMBER_ID = :NEW.MEMBER_ID;
   
    UPDATE BOOK
    SET NO_OF_AVAILABLE_COPIES = NO_OF_AVAILABLE_COPIES - 1
    WHERE BOOK_ID = :NEW.BOOK_ID;
END;
/

-- Insert sample data to trigger the borrow update trigger
INSERT INTO Borrow VALUES (1, 1, 'B-001', SYSDATE);
INSERT INTO Borrow VALUES (2, 2, 'B-002', SYSDATE);
INSERT INTO Borrow VALUES (3, 3, 'B-003', SYSDATE);
INSERT INTO BORROW VALUES (4, 1, 'B-002', SYSDATE);
COMMIT;

-- Cleanup
DROP TRIGGER UPDATE_BORROWED_BOOKS;
DROP TABLE Borrow;
DROP TABLE Book;
DROP TABLE Member;
DROP TRIGGER ANNOUNCE_NEW_SALARY;
DROP TRIGGER ANNOUNCE_NEW_EMPLOYEE;
DROP TABLE Employees;