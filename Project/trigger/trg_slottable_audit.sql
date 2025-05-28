CREATE OR REPLACE TRIGGER trg_slottable_audit
AFTER INSERT OR UPDATE OR DELETE ON slottable
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
    INSERT INTO slottable_audit (
        audit_id,
        operation_type,
        slotid,
        old_date, new_date,
        old_movieid, new_movieid,
        old_hallid, new_hallid,
        old_slot, new_slot,
        old_price, new_price,
        performed_by,
        operation_time,
        user_ip_address,
        session_user,
        host_name
    ) VALUES (
        slottable_audit_seq.NEXTVAL,
        v_operation_type,
        NVL(:OLD.slotid, :NEW.slotid),
        :OLD."date", :NEW."date",
        :OLD.movietable_movieid, :NEW.movietable_movieid,
        :OLD.halltable_hallid, :NEW.halltable_hallid,
        :OLD.slot, :NEW.slot,
        :OLD.price, :NEW.price,
        USER,
        SYSTIMESTAMP,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYS_CONTEXT('USERENV', 'HOST')
    );
END;
/
