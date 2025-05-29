CREATE OR REPLACE TRIGGER trg_check_slot_overlap
BEFORE INSERT OR UPDATE ON slottable
FOR EACH ROW
DECLARE
    v_existing_count NUMBER;
    v_new_start TIMESTAMP;
    v_new_end TIMESTAMP;
    v_existing_start TIMESTAMP;
    v_existing_end TIMESTAMP;
BEGIN
    v_new_start := TO_TIMESTAMP(:NEW."date" || ' ' || :NEW.slot, 'YYYY-MM-DD HH24:MI');
    v_new_end := v_new_start + INTERVAL '2' HOUR;

    SELECT COUNT(*)
    INTO v_existing_count
    FROM slottable
    WHERE halltable_hallid = :NEW.halltable_hallid
      AND "date" = :NEW."date"
      AND slotid != NVL(:NEW.slotid, -1)  
      AND (
          TO_TIMESTAMP("date" || ' ' || slot, 'YYYY-MM-DD HH24:MI') < v_new_end
          AND
          (TO_TIMESTAMP("date" || ' ' || slot, 'YYYY-MM-DD HH24:MI') + INTERVAL '2' HOUR) > v_new_start
      );

    IF v_existing_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Slot overlaps with an existing slot in this hall on the same date.');
    END IF;
END;
/
