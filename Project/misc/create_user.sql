-- Create a role
CREATE ROLE C##ticket_user;



-- Grant privileges to the role
GRANT SELECT, INSERT, UPDATE ON C##CSE464.halltable TO C##ticket_user;
GRANT SELECT, INSERT, UPDATE ON C##CSE464.movietable TO C##ticket_user;
GRANT SELECT, INSERT, UPDATE ON C##CSE464.seattable TO C##ticket_user;
GRANT SELECT, INSERT, UPDATE ON C##CSE464.slottable TO C##ticket_user;
GRANT SELECT, INSERT, UPDATE ON C##CSE464.ticket TO C##ticket_user;
GRANT SELECT, INSERT, UPDATE ON C##CSE464.usertable TO C##ticket_user;
grant select on user_role to C##ticket_user;
grant select on user_role to C##CSE464;

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



-- INSERT INTO C##CSE464.movietable (movieid, moviename, releasedate, genre, movierating, rating, poster) VALUES (11, 'APU', TO_DATE('2000-07-16', 'YYYY-MM-DD'), 'DOC', 8.8, 'PG-13', 'APU.jpg');
-- COMMIT;
-- UPDATE C##CSE464.movietable SET moviename = 'APU - The Journey' WHERE movieid = 11;
-- COMMIT;
SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE = 'C##TICKET_USER';
SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE = 'C##USER1';

CREATE table user_role (
    id number, 
    username VARCHAR2(50),
    role VARCHAR2(50)
)

INSERT INTO user_role (id, username, role) VALUES (1, 'C##CSE64', 'administrator');
INSERT INTO user_role (id, username, role) VALUES (2, 'C##user1', 'admin');
INSERT INTO user_role (id, username, role) VALUES (3, 'C##user2', 'admin');
UPDATE user_role SET username = 'C##USER1' WHERE id = 2;
UPDATE user_role SET username = 'C##USER2' WHERE id = 3;
commit;
SELECT * FROM sys.user_role;