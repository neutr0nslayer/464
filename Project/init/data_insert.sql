-- Insert into halltable
INSERT INTO halltable (hallid, hallname, location, rating, type, capasity) VALUES (1, 'Grand Regal Hall', 'New York', 0, 'IMAX', 250);
INSERT INTO halltable (hallid, hallname, location, rating, type, capasity) VALUES (2, 'Sunset Cineplex', 'Los Angeles', 0, 'Standard', 180);
INSERT INTO halltable (hallid, hallname, location, rating, type, capasity) VALUES (3, 'Ocean View Hall', 'Miami', 0, '4DX', 120);
INSERT INTO halltable (hallid, hallname, location, rating, type, capasity) VALUES (4, 'Mountain Peak Hall', 'Denver', 0, 'Standard', 150);
INSERT INTO halltable (hallid, hallname, location, rating, type, capasity) VALUES (5, 'City Lights Theater', 'Chicago', 0, 'IMAX', 200);
INSERT INTO halltable (hallid, hallname, location, rating, type, capasity) VALUES (6, 'Skyline Arena', 'Seattle', 0, 'Dolby', 175);
INSERT INTO halltable (hallid, hallname, location, rating, type, capasity) VALUES (7, 'Golden Reel Theater', 'San Francisco', 0, 'Standard', 160);
INSERT INTO halltable (hallid, hallname, location, rating, type, capasity) VALUES (8, 'Riverfront Cinemas', 'Boston', 0, 'IMAX', 190);
INSERT INTO halltable (hallid, hallname, location, rating, type, capasity) VALUES (9, 'Downtown Screens', 'Houston', 0, 'Standard', 140);
INSERT INTO halltable (hallid, hallname, location, rating, type, capasity) VALUES (10, 'Lakeside Multiplex', 'Minneapolis', 0, '4DX', 130);
INSERT INTO halltable (hallid, hallname, location, rating, type, capasity) VALUES (11, 'CineMagic Hall', 'New York', 0, 'Dolby', 165);

-- Insert into movietable
INSERT INTO movietable (movieid, moviename, releasedate, genre, movierating, rating, poster) VALUES (1, 'Inception', TO_DATE('2010-07-16', 'YYYY-MM-DD'), 'Sci-Fi', 0, 'PG-13', 'inception.jpg');
INSERT INTO movietable (movieid, moviename, releasedate, genre, movierating, rating, poster) VALUES (2, 'The Dark Knight', TO_DATE('2008-07-18', 'YYYY-MM-DD'), 'Action', 0, 'PG-13', 'dark_knight.jpg');
INSERT INTO movietable (movieid, moviename, releasedate, genre, movierating, rating, poster) VALUES (3, 'La La Land', TO_DATE('2016-12-09', 'YYYY-MM-DD'), 'Musical', 0, 'PG-13', 'la_la_land.jpg');
INSERT INTO movietable (movieid, moviename, releasedate, genre, movierating, rating, poster) VALUES (4, 'Titanic', TO_DATE('1997-12-19', 'YYYY-MM-DD'), 'Romance', 0, 'PG-13', 'titanic.jpg');
INSERT INTO movietable (movieid, moviename, releasedate, genre, movierating, rating, poster) VALUES (5, 'Avengers: Endgame', TO_DATE('2019-04-26', 'YYYY-MM-DD'), 'Action', 0, 'PG-13', 'endgame.jpg');
INSERT INTO movietable (movieid, moviename, releasedate, genre, movierating, rating, poster) VALUES (6, 'The Godfather', TO_DATE('1972-03-24', 'YYYY-MM-DD'), 'Crime', 0, 'R', 'godfather.jpg');
INSERT INTO movietable (movieid, moviename, releasedate, genre, movierating, rating, poster) VALUES (7, 'Interstellar', TO_DATE('2014-11-07', 'YYYY-MM-DD'), 'Sci-Fi', 0, 'PG-13', 'interstellar.jpg');
INSERT INTO movietable (movieid, moviename, releasedate, genre, movierating, rating, poster) VALUES (8, 'Parasite', TO_DATE('2019-05-30', 'YYYY-MM-DD'), 'Thriller', 0, 'R', 'parasite.jpg');
INSERT INTO movietable (movieid, moviename, releasedate, genre, movierating, rating, poster) VALUES (9, 'Joker', TO_DATE('2019-10-04', 'YYYY-MM-DD'), 'Drama', 0, 'R', 'joker.jpg');
INSERT INTO movietable (movieid, moviename, releasedate, genre, movierating, rating, poster) VALUES (10, 'The Matrix', TO_DATE('1999-03-31', 'YYYY-MM-DD'), 'Sci-Fi', 0, 'R', 'matrix.jpg');

-- Insert into usertable
INSERT INTO usertable (id, email, password, name) VALUES (1, 'user1@example.com', 'pass1', 'User1');
INSERT INTO usertable (id, email, password, name) VALUES (2, 'user2@example.com', 'pass2', 'User2');
INSERT INTO usertable (id, email, password, name) VALUES (3, 'user3@example.com', 'pass3', 'User3');
INSERT INTO usertable (id, email, password, name) VALUES (4, 'user4@example.com', 'pass4', 'User4');
INSERT INTO usertable (id, email, password, name) VALUES (5, 'user5@example.com', 'pass5', 'User5');
INSERT INTO usertable (id, email, password, name) VALUES (6, 'user6@example.com', 'pass6', 'User6');
INSERT INTO usertable (id, email, password, name) VALUES (7, 'user7@example.com', 'pass7', 'User7');
INSERT INTO usertable (id, email, password, name) VALUES (8, 'user8@example.com', 'pass8', 'User8');
INSERT INTO usertable (id, email, password, name) VALUES (9, 'user9@example.com', 'pass9', 'User9');
INSERT INTO usertable (id, email, password, name) VALUES (10, 'user10@example.com', 'pass10', 'User10');
INSERT INTO usertable (id, email, password, name) VALUES (11, 'user11@example.com', 'pass11', 'User11');
INSERT INTO usertable (id, email, password, name) VALUES (12, 'user12@example.com', 'pass12', 'User12');
INSERT INTO usertable (id, email, password, name) VALUES (13, 'user13@example.com', 'pass13', 'User13');
INSERT INTO usertable (id, email, password, name) VALUES (14, 'user14@example.com', 'pass14', 'User14');
INSERT INTO usertable (id, email, password, name) VALUES (15, 'user15@example.com', 'pass15', 'User15');
INSERT INTO usertable (id, email, password, name) VALUES (16, 'user16@example.com', 'pass16', 'User16');
INSERT INTO usertable (id, email, password, name) VALUES (17, 'user17@example.com', 'pass17', 'User17');
INSERT INTO usertable (id, email, password, name) VALUES (18, 'user18@example.com', 'pass18', 'User18');
INSERT INTO usertable (id, email, password, name) VALUES (19, 'user19@example.com', 'pass19', 'User19');
INSERT INTO usertable (id, email, password, name) VALUES (20, 'user20@example.com', 'pass20', 'User20');
INSERT INTO usertable (id, email, password, name) VALUES (21, 'user21@example.com', 'pass21', 'User21');
INSERT INTO usertable (id, email, password, name) VALUES (22, 'user22@example.com', 'pass22', 'User22');
INSERT INTO usertable (id, email, password, name) VALUES (23, 'user23@example.com', 'pass23', 'User23');
INSERT INTO usertable (id, email, password, name) VALUES (24, 'user24@example.com', 'pass24', 'User24');
INSERT INTO usertable (id, email, password, name) VALUES (25, 'user25@example.com', 'pass25', 'User25');
INSERT INTO usertable (id, email, password, name) VALUES (26, 'user26@example.com', 'pass26', 'User26');
INSERT INTO usertable (id, email, password, name) VALUES (27, 'user27@example.com', 'pass27', 'User27');
INSERT INTO usertable (id, email, password, name) VALUES (28, 'user28@example.com', 'pass28', 'User28');
INSERT INTO usertable (id, email, password, name) VALUES (29, 'user29@example.com', 'pass29', 'User29');
INSERT INTO usertable (id, email, password, name) VALUES (30, 'user30@example.com', 'pass30', 'User30');
INSERT INTO usertable (id, email, password, name) VALUES (31, 'user31@example.com', 'pass31', 'User31');
INSERT INTO usertable (id, email, password, name) VALUES (32, 'user32@example.com', 'pass32', 'User32');
INSERT INTO usertable (id, email, password, name) VALUES (33, 'user33@example.com', 'pass33', 'User33');
INSERT INTO usertable (id, email, password, name) VALUES (34, 'user34@example.com', 'pass34', 'User34');
INSERT INTO usertable (id, email, password, name) VALUES (35, 'user35@example.com', 'pass35', 'User35');
INSERT INTO usertable (id, email, password, name) VALUES (36, 'user36@example.com', 'pass36', 'User36');
INSERT INTO usertable (id, email, password, name) VALUES (37, 'user37@example.com', 'pass37', 'User37');
INSERT INTO usertable (id, email, password, name) VALUES (38, 'user38@example.com', 'pass38', 'User38');
INSERT INTO usertable (id, email, password, name) VALUES (39, 'user39@example.com', 'pass39', 'User39');
INSERT INTO usertable (id, email, password, name) VALUES (40, 'user40@example.com', 'pass40', 'User40');
INSERT INTO usertable (id, email, password, name) VALUES (41, 'user41@example.com', 'pass41', 'User41');
INSERT INTO usertable (id, email, password, name) VALUES (42, 'user42@example.com', 'pass42', 'User42');
INSERT INTO usertable (id, email, password, name) VALUES (43, 'user43@example.com', 'pass43', 'User43');
INSERT INTO usertable (id, email, password, name) VALUES (44, 'user44@example.com', 'pass44', 'User44');
INSERT INTO usertable (id, email, password, name) VALUES (45, 'user45@example.com', 'pass45', 'User45');
INSERT INTO usertable (id, email, password, name) VALUES (46, 'user46@example.com', 'pass46', 'User46');
INSERT INTO usertable (id, email, password, name) VALUES (47, 'user47@example.com', 'pass47', 'User47');
INSERT INTO usertable (id, email, password, name) VALUES (48, 'user48@example.com', 'pass48', 'User48');
INSERT INTO usertable (id, email, password, name) VALUES (49, 'user49@example.com', 'pass49', 'User49');
INSERT INTO usertable (id, email, password, name) VALUES (50, 'user50@example.com', 'pass50', 'User50');
commit;



-- Insert into slottable
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (1, TO_DATE('2023-10-01', 'YYYY-MM-DD'), 1, 1, '10:00', 15);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (2, TO_DATE('2023-10-01', 'YYYY-MM-DD'), 1, 2, '12:00', 15);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (3, TO_DATE('2023-10-01', 'YYYY-MM-DD'), 2, 1, '14:00', 20);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (4, TO_DATE('2023-10-01', 'YYYY-MM-DD'), 2, 2, '16:00', 20);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (5, TO_DATE('2023-10-01', 'YYYY-MM-DD'), 3, 1, '18:00', 18);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (6, TO_DATE('2023-10-01', 'YYYY-MM-DD'), 3, 2, '20:00', 18);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (7, TO_DATE('2023-10-02', 'YYYY-MM-DD'), 4, 1, '10:00', 12);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (8, TO_DATE('2023-10-02', 'YYYY-MM-DD'), 4, 2, '12:00', 12);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (9, TO_DATE('2023-10-02', 'YYYY-MM-DD'), 5, 1, '14:00', 22);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (10, TO_DATE('2023-10-02', 'YYYY-MM-DD'), 5, 2, '16:00', 22);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (11, TO_DATE('2023-10-02', 'YYYY-MM-DD'), 6, 1, '18:00', 25);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (12, TO_DATE('2023-10-02', 'YYYY-MM-DD'), 6, 2, '20:00', 25);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (13, TO_DATE('2023-10-03', 'YYYY-MM-DD'), 7, 1, '10:00', 16);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (14, TO_DATE('2023-10-03', 'YYYY-MM-DD'), 7, 2, '12:00', 16);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (15, TO_DATE('2023-10-03', 'YYYY-MM-DD'), 8, 1, '14:00', 19);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (16, TO_DATE('2023-10-03', 'YYYY-MM-DD'), 8, 2, '16:00', 19);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (17, TO_DATE('2023-10-03', 'YYYY-MM-DD'), 9, 1, '18:00', 21);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (18, TO_DATE('2023-10-03', 'YYYY-MM-DD'), 9, 2, '20:00', 21);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (19, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 10, 1, '10:00', 17);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (20, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 10, 2, '12:00', 17);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (21, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 1, 1, '14:00', 15);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (22, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 1, 2, '16:00', 15);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (23, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 2, 1, '18:00', 20);
INSERT INTO slottable (slotid, "date", movietable_movieid, halltable_hallid, slot, price) VALUES (24, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 2, 2, '20:00', 20);
COMMIT;


-- Insert into ticket
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (1, 15, TO_DATE('2023-10-01', 'YYYY-MM-DD'), 1, 1);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (2, 20, TO_DATE('2023-10-01', 'YYYY-MM-DD'), 2, 3);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (3, 18, TO_DATE('2023-10-01', 'YYYY-MM-DD'), 3, 5);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (4, 12, TO_DATE('2023-10-02', 'YYYY-MM-DD'), 4, 7);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (5, 22, TO_DATE('2023-10-02', 'YYYY-MM-DD'), 5, 9);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (6, 25, TO_DATE('2023-10-02', 'YYYY-MM-DD'), 6, 11);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (7, 16, TO_DATE('2023-10-03', 'YYYY-MM-DD'), 7, 13);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (8, 19, TO_DATE('2023-10-03', 'YYYY-MM-DD'), 8, 15);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (9, 21, TO_DATE('2023-10-03', 'YYYY-MM-DD'), 9, 17);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (10, 17, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 10, 19);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (11, 15, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 1, 21);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (12, 20, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 2, 23);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (13, 20, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 2, 24);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (14, 15, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 1, 22);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (15, 20, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 2, 23);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (16, 20, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 2, 24);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (17, 15, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 1, 21);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (18, 20, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 2, 23);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (19, 20, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 2, 24);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (20, 15, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 1, 22);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (21, 20, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 2, 23);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (22, 20, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 2, 24);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (23, 15, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 1, 21);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (24, 20, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 2, 23);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (25, 20, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 2, 24);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (26, 15, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 1, 22);
INSERT INTO ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid) VALUES (27, 20, TO_DATE('2023-10-04', 'YYYY-MM-DD'), 2, 23);
COMMIT;


-- Insert into seattable
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (1, 1);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (5, 1);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (6, 1);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (1, 2);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (2, 2);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (3, 3);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (4, 4);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (5, 5);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (6, 6);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (7, 7);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (8, 8);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (9, 9);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (10, 10);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (11, 11);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (12, 12);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (13, 13);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (14, 14);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (15, 15);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (16, 16);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (17, 17);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (18, 18);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (19, 19);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (20, 20);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (21, 21);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (22, 22);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (23, 23);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (24, 24);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (25, 25);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (26, 26);
INSERT INTO seattable (seatno, ticket_ticketid) VALUES (27, 27);
COMMIT;


