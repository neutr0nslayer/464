-- Trigger to audit changes on ratingtable
-- This trigger captures all changes (INSERT, UPDATE, DELETE) on the ratingtable
CREATE OR REPLACE TRIGGER trg_audit_ratingtable
  AFTER INSERT OR UPDATE OR DELETE
  ON ratingtable
  FOR EACH ROW
DECLARE
    v_operation_type VARCHAR2(10);  -- Holds the DML operation type
BEGIN
    -- Determine which DML operation fired this trigger
    IF INSERTING THEN
        v_operation_type := 'INSERT';
    ELSIF UPDATING THEN
        v_operation_type := 'UPDATE';
    ELSIF DELETING THEN
        v_operation_type := 'DELETE';
    END IF;

    -- Insert a new audit record with old/new values and context info
    INSERT INTO audit_ratingtable (
        audit_id,           -- surrogate PK from sequence
        rating_id,          -- affected row’s primary key
        old_movie_rating,   -- previous movie rating  (NULL if INSERT)
        new_movie_rating,   -- new movie rating       (NULL if DELETE)
        old_hall_ratting,   -- previous hall rating
        new_hall_ratting,   -- new hall rating
        operation_type,     -- INSERT/UPDATE/DELETE
        performed_by,       -- DB user performing the DML
        operation_time,     -- timestamp of the operation
        user_ip_address,    -- client IP address
        session_user,       -- Oracle session user
        host_name           -- client host name
    ) VALUES (
        audit_rating_seq.NEXTVAL,
        NVL(:OLD.rating_id, :NEW.rating_id),
        :OLD.movie_rating, :NEW.movie_rating,
        :OLD.hall_ratting, :NEW.hall_ratting,
        v_operation_type,
        USER,
        SYSTIMESTAMP,
        SYS_CONTEXT('USERENV','IP_ADDRESS'),
        SYS_CONTEXT('USERENV','SESSION_USER'),
        SYS_CONTEXT('USERENV','HOST')
    );
END;
/