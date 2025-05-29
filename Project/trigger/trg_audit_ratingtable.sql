-- Trigger to audit changes on ratingtable
-- This trigger captures all changes (INSERT, UPDATE, DELETE) on the ratingtable
CREATE OR REPLACE TRIGGER trg_audit_ratingtable
AFTER INSERT OR UPDATE OR DELETE ON ratingtable
FOR EACH ROW
DECLARE
    v_operation_type VARCHAR2(10);
BEGIN
    IF INSERTING THEN
        v_operation_type := 'INSERT';
    ELSIF UPDATING THEN
        v_operation_type := 'UPDATE';
    ELSIF DELETING THEN
        v_operation_type := 'DELETE';
    END IF;

    INSERT INTO audit_ratingtable (
        audit_id,
        rating_id,
        old_movie_rating, new_movie_rating,
        old_hall_ratting, new_hall_ratting,
        operation_type,
        performed_by,
        operation_time,
        user_ip_address,
        session_user,
        host_name
    ) VALUES (
        audit_rating_seq.NEXTVAL,
        NVL(:OLD.rating_id, :NEW.rating_id),
        :OLD.movie_rating, :NEW.movie_rating,
        :OLD.hall_ratting, :NEW.hall_ratting,
        v_operation_type,
        USER,
        SYSTIMESTAMP,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYS_CONTEXT('USERENV', 'HOST')
    );
END;
/
