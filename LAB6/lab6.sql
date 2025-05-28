CREATE TABLE products (
    product_id NUMBER PRIMARY KEY,
    product_name VARCHAR2(100),
    price NUMBER(10,2)
);

CREATE TABLE products_audit (
    audit_id NUMBER PRIMARY KEY,
    product_id NUMBER,
    operation_type VARCHAR2(10), -- INSERT, UPDATE, DELETE
    old_product_name VARCHAR2(20),
    new_product_name VARCHAR2(20),
    old_price NUMBER(10,2),
    new_price NUMBER(10,2),
    performed_by VARCHAR2(20),
    operation_time TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE SEQUENCE seq_products_audit START WITH 10001 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_products_audit
AFTER INSERT OR UPDATE OR DELETE ON products
FOR EACH ROW
BEGIN
IF INSERTING THEN
    INSERT INTO products_audit (audit_id, product_id, operation_type, new_product_name, new_price, performed_by) VALUES (seq_products_audit.NEXTVAL, :NEW.product_id, 'INSERT', :NEW.product_name, :NEW.price, USER);
ELSIF UPDATING THEN
    INSERT INTO products_audit (audit_id, product_id, operation_type, old_product_name, new_product_name, old_price, new_price, performed_by) VALUES (seq_products_audit.NEXTVAL, :OLD.product_id, 'UPDATE', :OLD.product_name, :NEW.product_name, :OLD.price, :NEW.price, USER);
ELSIF DELETING THEN
    INSERT INTO products_audit (audit_id, product_id, operation_type, old_product_name, old_price, performed_by) VALUES (seq_products_audit.NEXTVAL, :OLD.product_id, 'DELETE', :OLD.product_name, :OLD.price, USER);
END IF;
END;
/

INSERT INTO products (product_id, product_name, price) VALUES (1, 'Laptop', 1000);
INSERT INTO products (product_id, product_name, price) VALUES (2, 'Tablet', 500);
INSERT INTO products (product_id, product_name, price) VALUES (3, 'Smartphone', 800);
INSERT INTO products (product_id, product_name, price) VALUES (4, 'Monitor', 300);

UPDATE products SET price = 1200 WHERE product_id = 2;
UPDATE products SET product_name = 'Gaming Laptop' WHERE product_id = 1;
UPDATE products SET price = 600 WHERE product_id = 3;
UPDATE products SET product_name = '4K Monitor' WHERE product_id = 4;
UPDATE products SET price = 1100 WHERE product_id = 1;


DELETE FROM products WHERE product_id = 3;
DELETE FROM products WHERE product_id = 2;

INSERT INTO products (product_id, product_name, price) VALUES (5, 'Smartwatch', 200);
COMMIT;



CREATE OR REPLACE VIEW v_products_with_last_action AS
SELECT 
  p.product_id,
  p.product_name,
  p.price,
  b.latest_action,
  b.latest_time
FROM products p
join (SELECT PRODUCT_ID, MAX(a.operation_type) as latest_action, max(a.operation_time) as latest_time
     FROM products_audit a
     GROUP BY product_id
     ) b on b.product_id = p.product_id;

select * from v_products_with_last_action;


-- create a view find all the modification equal to 1
CREATE OR REPLACE VIEW v_products_modification_1 AS
SELECT 
    p.product_id,
    p.product_name,
    p.price AS NEW_PRICE,
    B.old_price AS OLD_PRICE,
    b.action,
    b.time
FROM products p
JOIN (SELECT PRODUCT_ID, OLD_PRICE, operation_type as action, operation_time as time
     FROM products_audit a
     ) b ON b.product_id = p.product_id
WHERE 
    P.PRODUCT_ID = 1
ORDER BY b.time ASC;

SELECT * FROM v_products_modification_1;





-- ! cleanup
DROP TABLE products_audit;
DROP TABLE products;
DROP SEQUENCE seq_products_audit;
DROP TRIGGER trg_products_audit;
DROP VIEW v_products_with_last_action;

