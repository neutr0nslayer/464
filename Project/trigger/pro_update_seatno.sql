CREATE OR REPLACE PROCEDURE update_seatno (p_ticket_id seattable.ticket_ticketid%TYPE,p_current_seatno seattable.seatno%TYPE, p_new_seatno seattable.seatno%TYPE) AS
BEGIN
    UPDATE seattable 
    SET seatno = p_new_seatno 
    WHERE ticket_ticketid = p_ticket_id AND seatno = p_current_seatno;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'No matching seat found for ticket '||p_ticket_id);
    END IF;

    COMMIT;
END update_seatno;
/


-- EXEC update_seatno(28,13, 60);