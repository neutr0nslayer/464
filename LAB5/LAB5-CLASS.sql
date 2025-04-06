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