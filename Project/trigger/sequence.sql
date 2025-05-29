
GRANT CREATE SEQUENCE TO C##CSE464;



-- Sequences for audit tables
CREATE SEQUENCE halltable_audit_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE movietable_audit_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seattable_audit_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE slottable_audit_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE ticket_audit_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE audit_rating_seq START WITH 1 INCREMENT BY 1;

DROP SEQUENCE halltable_audit_seq;
DROP SEQUENCE movietable_audit_seq;
DROP SEQUENCE seattable_audit_seq;
DROP SEQUENCE slottable_audit_seq;
DROP SEQUENCE ticket_audit_seq;
DROP SEQUENCE audit_rating_seq;