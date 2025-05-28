
-- Trigger to audit changes on halltable
-- This trigger captures all changes (INSERT, UPDATE, DELETE) on the halltable
CREATE OR REPLACE TRIGGER trg_halltable_audit
AFTER INSERT OR UPDATE OR DELETE ON halltable
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

    INSERT INTO halltable_audit (
        audit_id,
        hallid,
        operation_type,
        old_hallname, new_hallname,
        old_location, new_location,
        old_rating, new_rating,
        old_type, new_type,
        old_capsity, new_capsity,
        performed_by,
        operation_time,
        user_ip_address,
        session_user,
        host_name
    ) VALUES (
        halltable_audit_seq.NEXTVAL,
        NVL(:OLD.hallid, :NEW.hallid),
        v_operation_type,
        :OLD.hallname, :NEW.hallname,
        :OLD.location, :NEW.location,
        :OLD.rating, :NEW.rating,
        :OLD.type, :NEW.type,
        :OLD.capasity, :NEW.capasity,
        USER,
        SYSTIMESTAMP,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYS_CONTEXT('USERENV', 'HOST')
    );
END;
/