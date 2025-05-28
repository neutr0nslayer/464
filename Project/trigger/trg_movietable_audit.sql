
-- Trigger to audit changes on movietable
-- This trigger captures all changes (INSERT, UPDATE, DELETE) on the movietable
CREATE OR REPLACE TRIGGER trg_movietable_audit
AFTER INSERT OR UPDATE OR DELETE ON movietable
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
    INSERT INTO movietable_audit (
        audit_id,
        OPERATION_TYPE,
        movieid,
        old_moviename, new_moviename,
        old_releasedate, new_releasedate,
        old_genre, new_genre,
        old_movierating, new_movierating,
        old_rating, new_rating,
        poster,
        performed_by,
        operation_time,
        user_ip_address,
        session_user,
        host_name
    ) VALUES (
        movietable_audit_seq.NEXTVAL,
        v_operation_type,
        NVL(:OLD.movieid, :NEW.movieid),
        :OLD.moviename, :NEW.moviename,
        :OLD.releasedate, :NEW.releasedate,
        :OLD.genre, :NEW.genre,
        :OLD.movierating, :NEW.movierating,
        :OLD.rating, :NEW.rating,
        NVL(:NEW.poster, :OLD.poster),
        USER,
        SYSTIMESTAMP,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYS_CONTEXT('USERENV', 'HOST')
    );
END;
/


