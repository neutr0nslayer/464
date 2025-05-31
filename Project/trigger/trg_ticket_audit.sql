
-- Trigger to audit changes on ticket
-- This trigger captures all changes (INSERT, UPDATE, DELETE) on the ticket table
CREATE OR REPLACE TRIGGER trg_ticket_audit
AFTER INSERT OR UPDATE OR DELETE
ON ticket
FOR EACH ROW
DECLARE
    v_operation_type VARCHAR2(10);  -- Type of DML operation
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
    INSERT INTO ticket_audit (
        audit_id,         -- surrogate PK from sequence
        ticketid,         -- affected row’s primary key
        operation_type,   -- INSERT/UPDATE/DELETE
        old_price,        -- previous price (NULL if INSERT)
        new_price,        -- new price      (NULL if DELETE)
        old_buyingdate,   -- previous buyingdate
        new_buyingdate,   -- new buyingdate
        old_id,           -- previous usertable_id
        new_id,           -- new usertable_id
        old_slotid,       -- previous slottable_slotid
        new_slotid,       -- new slottable_slotid
        performed_by,     -- DB user performing the DML
        operation_time,   -- timestamp of this audit entry
        user_ip_address,  -- client IP address
        session_user,     -- Oracle session user
        host_name         -- client host name
    ) VALUES (
        ticket_audit_seq.NEXTVAL,
        NVL(:OLD.ticketid, :NEW.ticketid),
        v_operation_type,
        :OLD.price, :NEW.price,
        :OLD.buyingdate, :NEW.buyingdate,
        :OLD.usertable_id, :NEW.usertable_id,
        :OLD.slottable_slotid, :NEW.slottable_slotid,
        USER,
        SYSTIMESTAMP,
        SYS_CONTEXT('USERENV','IP_ADDRESS'),
        SYS_CONTEXT('USERENV','SESSION_USER'),
        SYS_CONTEXT('USERENV','HOST')
    );
END;
/