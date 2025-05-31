
-- Trigger to audit changes on seattable
-- This trigger captures all changes (INSERT, UPDATE, DELETE) on the seattable
CREATE OR REPLACE TRIGGER trg_seattable_audit
AFTER INSERT OR UPDATE OR DELETE
ON seattable
FOR EACH ROW
DECLARE
    v_operation_type VARCHAR2(10);  -- Holds the type of DML operation
BEGIN
    -- Determine which DML operation fired the trigger
    IF INSERTING THEN
        v_operation_type := 'INSERT';
    ELSIF UPDATING THEN
        v_operation_type := 'UPDATE';
    ELSIF DELETING THEN
        v_operation_type := 'DELETE';
    END IF;

    -- Insert a new audit record with OLD/NEW values and context info
    INSERT INTO seattable_audit (
        audit_id,            -- surrogate PK from sequence
        operation_type,      -- INSERT/UPDATE/DELETE
        old_seatno,          -- previous seat number (NULL if INSERT)
        new_seatno,          -- new seat number   (NULL if DELETE)
        old_ticketid,        -- previous ticket FK
        new_ticketid,        -- new ticket FK
        performed_by,        -- DB user performing the DML
        operation_time,      -- timestamp of the operation
        user_ip_address,     -- DB session IP address
        session_user,        -- DB session user
        host_name            -- DB session host name
    ) VALUES (
        seattable_audit_seq.NEXTVAL,
        v_operation_type,
        :OLD.seatno, 
        :NEW.seatno,
        :OLD.ticket_ticketid, 
        :NEW.ticket_ticketid,
        USER,
        SYSTIMESTAMP,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYS_CONTEXT('USERENV', 'HOST')
    );
END;
/
