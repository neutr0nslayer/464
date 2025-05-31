
-- Trigger to audit changes on slottable
-- This trigger captures all changes (INSERT, UPDATE, DELETE) on the slottable
CREATE OR REPLACE TRIGGER trg_slottable_audit
  AFTER INSERT OR UPDATE OR DELETE
  ON slottable
  FOR EACH ROW
DECLARE
    v_operation_type VARCHAR2(10);  -- Holds the DML operation type
BEGIN
    -- Identify which DML event fired the trigger
    IF INSERTING THEN
        v_operation_type := 'INSERT';
    ELSIF UPDATING THEN
        v_operation_type := 'UPDATE';
    ELSIF DELETING THEN
        v_operation_type := 'DELETE';
    END IF;

    -- Insert a corresponding audit record
    INSERT INTO slottable_audit (
        audit_id,         -- surrogate PK from sequence
        operation_type,   -- INSERT/UPDATE/DELETE
        slotid,           -- affected row’s primary key
        old_date,         -- previous show date  (NULL if INSERT)
        new_date,         -- new show date       (NULL if DELETE)
        old_movieid,      -- previous movietable_movieid
        new_movieid,      -- new movietable_movieid
        old_hallid,       -- previous halltable_hallid
        new_hallid,       -- new halltable_hallid
        old_slot,         -- previous time slot
        new_slot,         -- new time slot
        old_price,        -- previous ticket price
        new_price,        -- new ticket price
        performed_by,     -- DB user performing the DML
        operation_time,   -- timestamp of the operation
        user_ip_address,  -- client IP address
        session_user,     -- Oracle session user
        host_name         -- client host name
    ) VALUES (
        slottable_audit_seq.NEXTVAL,
        v_operation_type,
        NVL(:OLD.slotid, :NEW.slotid),
        :OLD."date", :NEW."date",
        :OLD.movietable_movieid, :NEW.movietable_movieid,
        :OLD.halltable_hallid,   :NEW.halltable_hallid,
        :OLD.slot,               :NEW.slot,
        :OLD.price,              :NEW.price,
        USER,
        SYSTIMESTAMP,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYS_CONTEXT('USERENV', 'HOST')
    );
END;
/
