CREATE OR REPLACE TRIGGER trg_ticket_audit
AFTER INSERT OR UPDATE OR DELETE ON ticket
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
    INSERT INTO ticket_audit (
        audit_id,
        ticketid,
        operation_type,
        old_price, new_price,
        old_buyingdate, new_buyingdate,
        old_id, new_id,
        old_slotid, new_slotid,
        performed_by,
        operation_time,
        user_ip_address,
        session_user,
        host_name
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
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYS_CONTEXT('USERENV', 'HOST')
    );
END;
/
