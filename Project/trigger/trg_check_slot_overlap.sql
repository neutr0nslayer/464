CREATE OR REPLACE TRIGGER trg_check_slot_overlap
FOR UPDATE OR INSERT ON slottable
COMPOUND TRIGGER

  TYPE slot_info_t IS RECORD (
    hallid    slottable.halltable_hallid%TYPE,
    slot_date slottable."date"%TYPE,
    slot_time slottable.slot%TYPE,
    slotid    slottable.slotid%TYPE
  );

  TYPE slot_info_table_t IS TABLE OF slot_info_t;

  affected_slots slot_info_table_t := slot_info_table_t();

  BEFORE EACH ROW IS
  BEGIN
    -- Collect each new/updated slot’s hall, date, time, and ID
    affected_slots.EXTEND;
    affected_slots(affected_slots.COUNT).hallid := :NEW.halltable_hallid;
    affected_slots(affected_slots.COUNT).slot_date := :NEW."date";
    affected_slots(affected_slots.COUNT).slot_time := :NEW.slot;
    affected_slots(affected_slots.COUNT).slotid := NVL(:NEW.slotid, -1);
  END BEFORE EACH ROW;

  AFTER STATEMENT IS
    v_new_start      TIMESTAMP;
    v_new_end        TIMESTAMP;
    v_conflict_count INTEGER;
  BEGIN
    -- For each collected slot, check for overlapping slots in the same hall/date
    FOR i IN 1 .. affected_slots.COUNT LOOP
      v_new_start := TO_TIMESTAMP(affected_slots(i).slot_date || ' ' || affected_slots(i).slot_time, 'YYYY-MM-DD HH24:MI');
      v_new_end := v_new_start + INTERVAL '2' HOUR;

      SELECT 
      COUNT(*) INTO v_conflict_count
      FROM slottable s
      WHERE s.halltable_hallid = affected_slots(i).hallid
        -- same show date
        AND s."date" = affected_slots(i).slot_date
        -- exclude the slot being inserted/updated
        AND s.slotid != affected_slots(i).slotid
        -- existing slot start before new slot end
        AND TO_TIMESTAMP(s."date" || ' ' || s.slot, 'YYYY-MM-DD HH24:MI') < v_new_end
        -- existing slot end (start+2h) after new slot start
        AND ( TO_TIMESTAMP(s."date" || ' ' || s.slot, 'YYYY-MM-DD HH24:MI') + INTERVAL '2' HOUR) > v_new_start;

      IF v_conflict_count > 0 THEN
        RAISE_APPLICATION_ERROR(
          -20001,
          'Slot overlaps with an existing slot in this hall on the same date.'
        );
      END IF;
    END LOOP;
  END AFTER STATEMENT;

END trg_check_slot_overlap;
/