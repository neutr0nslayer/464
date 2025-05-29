CREATE OR REPLACE TRIGGER trg_update_avg_rating
FOR INSERT OR UPDATE ON ratingtable
COMPOUND TRIGGER

  -- Define record and collection type
  TYPE rating_rec_type IS RECORD (
    movie_id movietable.movieid%TYPE,
    hall_id  halltable.hallid%TYPE
  );

  TYPE rating_tab_type IS TABLE OF rating_rec_type INDEX BY PLS_INTEGER;
  v_ratings rating_tab_type;
  idx PLS_INTEGER := 0;

AFTER EACH ROW IS
  v_slotid  slottable.slotid%TYPE;
  v_movieid movietable.movieid%TYPE;
  v_hallid  halltable.hallid%TYPE;
  v_msg     VARCHAR2(1000);
BEGIN
  BEGIN
    SELECT t.slottable_slotid
    INTO v_slotid
    FROM ticket t
    WHERE t.ticketid = :NEW.ticket_ticketid;

    SELECT s.movietable_movieid, s.halltable_hallid
    INTO v_movieid, v_hallid
    FROM slottable s
    WHERE s.slotid = v_slotid;

    idx := idx + 1;
    v_ratings(idx).movie_id := v_movieid;
    v_ratings(idx).hall_id := v_hallid;
  EXCEPTION
    WHEN OTHERS THEN
      v_msg := 'AFTER EACH ROW error for ticketid: ' || TO_CHAR(:NEW.ticket_ticketid) || ' - ' || SQLERRM;
      INSERT INTO trigger_log (message) VALUES (v_msg);
  END;
END AFTER EACH ROW;

AFTER STATEMENT IS
  temp_movieid movietable.movieid%TYPE;
  temp_hallid  halltable.hallid%TYPE;
  v_msg        VARCHAR2(1000);
BEGIN
  FOR i IN 1 .. v_ratings.COUNT LOOP
    temp_movieid := v_ratings(i).movie_id;
    temp_hallid := v_ratings(i).hall_id;

    BEGIN
      -- Update movie rating
      UPDATE movietable
      SET movierating = (
        SELECT ROUND(AVG(r.movie_rating), 1)
        FROM ratingtable r
        JOIN ticket t ON r.ticket_ticketid = t.ticketid
        JOIN slottable s ON t.slottable_slotid = s.slotid
        WHERE s.movietable_movieid = temp_movieid
      )
      WHERE movieid = temp_movieid;

      -- Update hall rating
      UPDATE halltable
      SET rating = (
        SELECT ROUND(AVG(r.hall_ratting), 1)
        FROM ratingtable r
        JOIN ticket t ON r.ticket_ticketid = t.ticketid
        JOIN slottable s ON t.slottable_slotid = s.slotid
        WHERE s.halltable_hallid = temp_hallid
      )
      WHERE hallid = temp_hallid;

    EXCEPTION
      WHEN OTHERS THEN
        v_msg := 'AFTER STATEMENT error for movieid: ' || TO_CHAR(temp_movieid) ||
                 ', hallid: ' || TO_CHAR(temp_hallid) || ' - ' || SQLERRM;
        INSERT INTO trigger_log (message) VALUES (v_msg);
    END;
  END LOOP;
END AFTER STATEMENT;

END trg_update_avg_rating;
/
