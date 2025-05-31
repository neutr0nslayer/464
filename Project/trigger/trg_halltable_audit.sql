
-- Trigger to audit changes on halltable
-- This trigger captures all changes (INSERT, UPDATE, DELETE) on the halltable
CREATE OR REPLACE TRIGGER trg_halltable_audit
  AFTER INSERT OR UPDATE OR DELETE
  ON halltable
  FOR EACH ROW
DECLARE
    v_operation_type VARCHAR2(10);  -- Holds the DML operation type
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
    INSERT INTO halltable_audit (
        audit_id,         -- surrogate PK from sequence
        hallid,           -- affected row’s primary key
        operation_type,   -- INSERT/UPDATE/DELETE
        old_hallname,     -- previous hall name (NULL if INSERT)
        new_hallname,     -- new hall name      (NULL if DELETE)
        old_location,     -- previous location
        new_location,     -- new location
        old_rating,       -- previous rating
        new_rating,       -- new rating
        old_type,         -- previous type
        new_type,         -- new type
        old_capsity,      -- previous capacity
        new_capsity,      -- new capacity
        performed_by,     -- DB user performing the DML
        operation_time,   -- timestamp of the operation
        user_ip_address,  -- client IP address
        session_user,     -- Oracle session user
        host_name         -- client host name
    ) VALUES (
        halltable_audit_seq.NEXTVAL,
        NVL(:OLD.hallid, :NEW.hallid),
        v_operation_type,
        :OLD.hallname, :NEW.hallname,
        :OLD.location, :NEW.location,
        :OLD.rating,   :NEW.rating,
        :OLD.type,     :NEW.type,
        :OLD.capasity, :NEW.capasity,
        USER,
        SYSTIMESTAMP,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYS_CONTEXT('USERENV', 'HOST')
    );
END;
/