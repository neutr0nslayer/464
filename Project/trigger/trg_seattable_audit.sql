CREATE OR REPLACE TRIGGER trg_seattable_audit
AFTER INSERT OR UPDATE OR DELETE ON seattable
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
    INSERT INTO seattable_audit (
        audit_id,
        operation_type,
        old_seatno, new_seatno,
        old_ticketid, new_ticketid,
        performed_by,
        operation_time,
        user_ip_address,
        session_user,
        host_name
    ) VALUES (
        seattable_audit_seq.NEXTVAL,
        v_operation_type,
        :OLD.seatno, :NEW.seatno,
        :OLD.ticket_ticketid, :NEW.ticket_ticketid,
        USER,
        SYSTIMESTAMP,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYS_CONTEXT('USERENV', 'HOST')
    );
END;
/
