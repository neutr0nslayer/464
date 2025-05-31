
-- Trigger to audit changes on movietable
-- This trigger captures all changes (INSERT, UPDATE, DELETE) on the movietable
CREATE OR REPLACE TRIGGER trg_movietable_audit
AFTER INSERT OR UPDATE OR DELETE
ON movietable
FOR EACH ROW
DECLARE
    v_operation_type VARCHAR2(10);  -- Holds the type of DML operation
BEGIN
    -- Determine which DML operation fired this trigger
    IF INSERTING THEN
        v_operation_type := 'INSERT';
    ELSIF UPDATING THEN
        v_operation_type := 'UPDATE';
    ELSIF DELETING THEN
        v_operation_type := 'DELETE';
    END IF;

    -- Insert a new audit record with OLD/NEW values and context info
    INSERT INTO movietable_audit (
        audit_id,          -- surrogate PK from sequence
        OPERATION_TYPE,    -- INSERT/UPDATE/DELETE
        movieid,           -- affected row’s primary key
        old_moviename,     -- previous movie name (NULL if INSERT)
        new_moviename,     -- new movie name      (NULL if DELETE)
        old_releasedate,   -- previous release date
        new_releasedate,   -- new release date
        old_genre,         -- previous genre
        new_genre,         -- new genre
        old_movierating,   -- previous movie rating
        new_movierating,   -- new movie rating
        old_rating,        -- previous internal rating
        new_rating,        -- new internal rating
        poster,            -- poster image (prefer new if provided)
        performed_by,      -- DB user performing the DML
        operation_time,    -- timestamp of the operation
        user_ip_address,   -- client IP address
        session_user,      -- Oracle session user
        host_name          -- client host name
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
        SYS_CONTEXT('USERENV','IP_ADDRESS'),
        SYS_CONTEXT('USERENV','SESSION_USER'),
        SYS_CONTEXT('USERENV','HOST')
    );
END;
/

