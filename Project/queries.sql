
SELECT 
    s.slotid,
    m.moviename,
    s.slot,
    s."date" AS slot_date,
    h.hallname,
    h.type AS hall_type,
    s.price,
    COUNT(t.ticketid) AS tickets_sold
FROM 
    C##CSE464.slottable s
JOIN 
    C##CSE464.movietable m ON s.movietable_movieid = m.movieid
JOIN 
    C##CSE464.ticket t ON t.slottable_slotid = s.slotid
JOIN
    C##CSE464.halltable h ON s.halltable_hallid = h.hallid
WHERE 
    m.moviename = 'The Dark Knight'
GROUP BY 
    s.slotid, s.slot, s."date", m.moviename, s.price, h.type, h.hallname
ORDER BY 
    s."date", s.slot
