-- Drop all created objects
DROP TABLE instructors;
DROP TABLE departments;
DROP INDEX idx_dept_id;
DROP INDEX idx_salary;
DROP INDEX idx_dept_id_salary;

-- Create Departments Table
CREATE TABLE departments (
  dept_id NUMBER PRIMARY KEY,
  dept_name VARCHAR2(20),
  location VARCHAR2(20)
);

-- Insert 1000 random departments
BEGIN
    FOR I IN 1..1000 LOOP 
        INSERT INTO departments VALUES (
            I,
            'Dept ' || CHR(TRUNC(DBMS_RANDOM.VALUE(65, 91))),  -- Random letter (A-Z)
            'Building ' || CHR(TRUNC(DBMS_RANDOM.VALUE(65, 91)))  -- Random letter (A-Z)
        );
    END LOOP;
    COMMIT;
END;
/



-- Create Instructors Table
DROP TABLE instructors;
CREATE TABLE instructors (
  instructor_id NUMBER PRIMARY KEY,
  name VARCHAR2(20),
  dept_id NUMBER,
  salary NUMBER(10,2),
  CONSTRAINT fk_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

BEGIN
    FOR I IN 1..1000000 LOOP 
        INSERT INTO instructors VALUES (
            I,
            'Instructor ' || CHR(TRUNC(DBMS_RANDOM.VALUE(65, 91))),  -- Random letter (A-Z)
            ROUND(DBMS_RANDOM.VALUE(1,1000)), -- Random department
            ROUND(DBMS_RANDOM.VALUE(40000, 120000), 2)  -- Random salary between 40,000 and 120,000
        );
    END LOOP;
    COMMIT;
END;
/

SELECT COUNT(*) FROM departments;
SELECT COUNT(*) FROM instructors;


-- SELECT OPERATION
EXPLAIN PLAN FOR
SELECT  NAME FROM instructors WHERE dept_id = 10;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

set timing on;
SELECT  NAME FROM instructors WHERE dept_id = 10;
set timing off;

DROP INDEX idx_dept_id;
CREATE INDEX idx_dept_id ON instructors(dept_id);

-- CONJECUTIVE SELECT OPERATION
EXPLAIN PLAN FOR
SELECT  *  
FROM instructors i 
WHERE dept_id = 10 AND salary > 50000;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

set timing on;
SELECT  *  
FROM instructors i 
WHERE dept_id = 10 AND salary > 50000;
set timing off;

DROP INDEX idx_dept_id;
CREATE INDEX idx_dept_id ON instructors(dept_id);

DROP INDEX idx_salary;
CREATE INDEX idx_salary ON instructors(salary);

DROP INDEX idx_dept_id_salary;
CREATE INDEX idx_dept_id_salary ON instructors(dept_id, salary);

-- JOIN OPERATION
EXPLAIN PLAN FOR
SELECT /*+ INDEX(i idx_dept_id) */ i.instructor_id, i.name, d.dept_name, d.location
FROM instructors  i
JOIN departments d  ON i.dept_id = d.dept_id
WHERE i.DEPT_ID = 50;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

set timing on;
SELECT /*+ INDEX(i idx_dept_id) */ i.instructor_id, i.name, d.dept_name, d.location
FROM instructors  i
JOIN departments d  ON i.dept_id = d.dept_id
WHERE i.DEPT_ID = 50;
set timing off;

DROP INDEX idx_dept_id;
CREATE INDEX idx_dept_id ON instructors(dept_id);

