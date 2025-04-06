-- grant create materialized view to c##cse464;

DROP TABLE PRODUCTS CASCADE CONSTRAINTS;
DROP TABLE SALES CASCADE CONSTRAINTS;

CREATE TABLE PRODUCTS (
    PRODUCT_ID NUMBER(10) NOT NULL,
    CATAGORY NUMBER NOT NULL,
    PRODUCT_PRICE NUMBER(10,2) NOT NULL,
    PRIMARY KEY (PRODUCT_ID)
);

CREATE TABLE SALES (
    ORDER_ID NUMBER(10) NOT NULL,
    CUSTOMER_ID NUMBER(10) NOT NULL,
    PRODUCT_ID NUMBER(10) NOT NULL,
    ORDER_DATE DATE NOT NULL,
    QUNATITY NUMBER NOT NULL,
    PRIMARY KEY (ORDER_ID),
    FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCTS(PRODUCT_ID)
);

BEGIN   
    FOR I IN 1..500 LOOP
        INSERT INTO PRODUCTS (PRODUCT_ID, CATAGORY, PRODUCT_PRICE) 
        VALUES (
            I, 
            ROUND(DBMS_RANDOM.VALUE(0, 49)+1),
            ROUND(DBMS_RANDOM.VALUE(0, 499), 2));
    END LOOP;
    COMMIT;
END;
/

SELECT COUNT(*) FROM PRODUCTS;

BEGIN   
    FOR I IN 1..50000 LOOP
        INSERT INTO SALES (ORDER_ID, CUSTOMER_ID, PRODUCT_ID, ORDER_DATE, QUNATITY) 
        VALUES (
            I, 
            ROUND(DBMS_RANDOM.VALUE(0, 999), 0) + 1,
            ROUND(DBMS_RANDOM.VALUE(0, 499), 0) + 1,
            TO_DATE('2020-01-01', 'YYYY-MM-DD') + ROUND(DBMS_RANDOM.VALUE(0, 1460), 0),
            ROUND(DBMS_RANDOM.VALUE(0, 99), 0)+1);
    END LOOP;
    COMMIT;
END;
/

SELECT COUNT(*) FROM SALES;

CREATE MATERIALIZED VIEW mv_seles_summary
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
SELECT 
    P.CATAGORY, 
    TRUNC(S.ORDER_DATE, 'MM') AS SELES_MONTH,
    SUM(S.QUNATITY * P.PRODUCT_PRICE) AS TOTAL_SALES
FROM
    SALES S JOIN 
    PRODUCTS P 
    ON S.PRODUCT_ID = P.PRODUCT_ID
GROUP BY
    P.CATAGORY, 
    TRUNC(S.ORDER_DATE, 'MM');

EXEC DBMS_MVIEW.REFRESH('mv_seles_summary', 'C');
SELECT * FROM mv_seles_summary ORDER BY CATAGORY, SELES_MONTH;

--! CLASS WORK
-- In-Lab Exercise:
-- 1. Create a Materialized View named 'mv_sales_products' with a complete refresh that displays the product ID and the number of units sold for each product.
-- 2. Show the output from mv_sales_products.
-- 3. Insert a couple of rows in the sales table.
-- 4. Show the output again from mv_sales_products. Does it change?
-- 5. Refresh the materialized view manually and show the output again. Can you notice the changes?


-- 1
CREATE MATERIALIZED VIEW mv_sales_products
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
SELECT 
    P.PRODUCT_ID,
    SUM(S.QUNATITY) AS TOTAL_QUNATITY
FROM
    SALES S JOIN 
    PRODUCTS P 
    ON S.PRODUCT_ID = P.PRODUCT_ID
GROUP BY
    P.PRODUCT_ID;

-- 2
SELECT * FROM mv_sales_products ORDER BY PRODUCT_ID;

-- 3
INSERT INTO PRODUCTS (PRODUCT_ID, CATAGORY, PRODUCT_PRICE)
VALUES (501, 1, 100.00);
COMMIT;
INSERT INTO SALES (ORDER_ID, CUSTOMER_ID, PRODUCT_ID, ORDER_DATE, QUNATITY)
VALUES (50001, 1, 501, TO_DATE('2020-01-01', 'YYYY-MM-DD') + ROUND(DBMS_RANDOM.VALUE(0, 1460), 0), 10);
COMMIT;

-- 4
SELECT * FROM mv_sales_products WHERE PRODUCT_ID = 1;

-- 5
EXEC DBMS_MVIEW.REFRESH('mv_sales_products', 'C');
SELECT * FROM mv_sales_products WHERE PRODUCT_ID = 1;