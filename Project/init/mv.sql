-- This materialized view combines ticket, user, slot, movie, and hall information
-- to provide a comprehensive view of ticket purchases, including user details, slot information,
-- movie details, and hall information. It is designed to be refreshed on demand for up-to-date data.

DROP MATERIALIZED VIEW MV_TICKET_VIEW;
CREATE MATERIALIZED VIEW MV_TICKET_VIEW
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    t.ticketid,
    t.price,
    t.buyingdate,
    t.seatno,
    -- u.id AS user_id,
    u.email AS user_email,
    u.name AS user_name,
    -- s.slotid,
    s."date" AS slot_date,
    s.slot,
    s.price AS slot_price,
    -- m.movieid,
    m.moviename,
    m.releasedate,
    m.genre,
    m.movierating,
    h.hallid,
    h.hallname,
    h.location AS hall_location,
    -- h.rating AS hall_rating,
    h.type AS hall_type
    -- h.capasity AS hall_capasity
    
FROM
    (SELECT * FROM ticket JOIN seattable ON ticket.ticketid = seattable.ticket_ticketid) t
JOIN
    usertable u ON t.usertable_id = u.id
JOIN
    slottable s ON t.slottable_slotid = s.slotid
JOIN
    movietable m ON s.movietable_movieid = m.movieid
JOIN
    halltable h ON s.halltable_hallid = h.hallid
ORDER BY
    t.buyingdate, m.releasedate;







-- This materialized view combines movie, slot, and hall information
-- to provide a comprehensive view of movies, their slots, and the halls where they are shown.
-- It is designed to be refreshed on demand for up-to-date data.

CREATE MATERIALIZED VIEW MV_movie_slot_hall_view 
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    m.movieid,
    m.moviename,
    m.releasedate,
    m.genre,
    m.movierating,
    s.slotid,
    s."date" AS slot_date,
    s.slot,
    s.price AS slot_price,
    H.hallid,
    H.hallname,
    H.location AS hall_location,
    H.rating AS hall_rating,
    H.type AS hall_type,
    H.capasity AS hall_capasity

FROM 
    movietable m
JOIN 
    slottable s ON m.movieid = s.movietable_movieid
JOIN 
    HALLTABLE H ON H.HALLID = S.halltable_hallid
ORDER BY S."date", m.RELEASEDATE;
