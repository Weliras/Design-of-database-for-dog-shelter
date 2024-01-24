SET SERVEROUTPUT ON

CREATE TABLE Student2 (
login CHAR(6) PRIMARY KEY,
fname VARCHAR(30) NOT NULL,
lname VARCHAR(50) NOT NULL,
email VARCHAR(50) NOT NULL);

ALTER TABLE Student2 ADD tallness int NOT NULL;

ALTER TABLE Student2 MODIFY email VARCHAR(30) NULL;

BEGIN
INSERT INTO Student2
(login, fname, lname, tallness)
VALUES ('buh05', 'Jan', 'Buhda', 175);
END;

BEGIN 
dbms_output.put_line('Ahoj');
END;

EXECUTE dbms_output.put_line('Ahoj');

DECLARE
v_login CHAR(6) := 'buh05';
v_fname VARCHAR2(30) := 'Jan';
v_lname VARCHAR2(50) := 'Buhda';
v_tallness INT := 175;
BEGIN
dbms_output.put_line(v_login);
dbms_output.put_line(v_fname);
dbms_output.put_line(v_lname);
dbms_output.put_line(v_tallness);
COMMIT;
END;

DECLARE
v_login Student2.login%TYPE :='buh05' ;
v_fname Student2.fname%TYPE := 'Jan';
v_lname Student2.lname%TYPE := 'Buhda';
v_tallness Student2.tallness%TYPE := 175;
BEGIN
dbms_output.put_line(v_login);
dbms_output.put_line(v_fname);
dbms_output.put_line(v_lname);
dbms_output.put_line(v_tallness);
INSERT INTO student2(login, fname, lname, tallness)
VALUES (v_login, v_fname, v_lname, v_tallness);
COMMIT;
END;

DECLARE
v_student Student2%ROWTYPE;
BEGIN
SELECT * INTO v_student FROM student2 WHERE login = 'buh05';
dbms_output.put_line(v_student.login);
dbms_output.put_line(v_student.fname);
dbms_output.put_line(v_student.lname);
dbms_output.put_line(v_student.tallness);
COMMIT;
END;

BEGIN
INSERT INTO student2(login, fname, lname, tallness)
VALUES ('pta04', 'Petr', 'Pt·Ëek', 172);
INSERT INTO student2(login, fname, lname, tallness)
VALUES ('pta04', 'Petr', 'Pt·Ëek', 172);
COMMIT;
EXCEPTION
WHEN OTHERS THEN 
    ROLLBACK;
END;

SELECT * FROM Student2;
