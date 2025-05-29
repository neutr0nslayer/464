-- Create a role
CREATE ROLE C##ticket_user;



-- Grant privileges to the role
GRANT SELECT, INSERT, UPDATE ON C##CSE464.halltable TO C##ticket_user;
GRANT SELECT, INSERT, UPDATE ON C##CSE464.movietable TO C##ticket_user;
GRANT SELECT, INSERT, UPDATE ON C##CSE464.seattable TO C##ticket_user;
GRANT SELECT, INSERT, UPDATE ON C##CSE464.slottable TO C##ticket_user;
GRANT SELECT, INSERT, UPDATE ON C##CSE464.ticket TO C##ticket_user;
GRANT SELECT, INSERT, UPDATE ON C##CSE464.usertable TO C##ticket_user;


-- Assign the role to a user
-- Create common users (available across all PDBs)
CREATE USER C##user1 IDENTIFIED BY user1;
CREATE USER C##user2 IDENTIFIED BY user2;

-- Grant basic privileges
GRANT CONNECT, RESOURCE TO C##user1;
GRANT CONNECT, RESOURCE TO C##user2;

-- Grant your custom role if created (e.g., C##ticket_user)
GRANT C##ticket_user TO C##user1;
GRANT C##ticket_user TO C##user2;



INSERT INTO C##CSE464.movietable (movieid, moviename, releasedate, genre, movierating, rating, poster) VALUES (11, 'APU', TO_DATE('2000-07-16', 'YYYY-MM-DD'), 'DOC', 8.8, 'PG-13', 'APU.jpg');
COMMIT;
UPDATE C##CSE464.movietable SET moviename = 'APU - The Journey' WHERE movieid = 11;
COMMIT;