CREATE TABLE Teacher (
login CHAR(6) NOT NULL PRIMARY KEY,
fname VARCHAR2(30) NOT NULL,
lname VARCHAR2(50) NOT NULL,
department INT NOT NULL,
specialization VARCHAR2(30) NULL);

--Přidejte do tabulky Student atribut isTall, který bude nabývat
--hodnoty 0 nebo 1.
ALTER TABLE student2
ADD isTall NUMBER(1) NULL CHECK(isTall IN (1,0));

execute AddStudent('nov12', 'Jarda', 'Novak', 170);
execute AddStudent('nov90', 'Lada', 'Novakova', 173);
execute AddStudent('hla10', 'Uhor', 'Hladky', 185);


set serveroutput on;
execute dbms_output.put_line(FAddStudent2('bon007', 'James', 'Bond', 190));
execute dbms_output.put_line(FAddStudent2('bac27', 'Radim', 'Baca', 175));

execute StudentBecomeTeacher('bac27', 1)

EXECUTE isStudentTall('bon007');

select * from student2;
select * from teacher;

 SELECT AVG(tallness) FROM student2;

--PROCEDURY A FUNKCE

--Vytvořte uloženou proceduru1 AddStudent se čtyřmi parametry
--p_login, p_fname, p_lname, p_tallness, která vloží nový
--záznam. Zavolejte uloženou proceduru příkazem EXECUTE.
create or replace PROCEDURE AddStudent(
p_login IN Student2.login%TYPE,
p_fname IN Student2.fname%TYPE,
p_lname IN Student2.lname%TYPE,
p_tallness IN Student2.tallness%TYPE)
AS BEGIN
    INSERT INTO student2 (login, fname, lname, tallness) VALUES (p_login, p_fname, p_lname, p_tallness);
END AddStudent;

--Vytvořte uloženou funkci2 FAddStudent, která bude fungovat stejně
--jako procedura AddStudent a navíc bude vracet ’ok’, pokud bude
--záznam úspěšně vložen a ’error’ pokud dojde k chybě (Použijte část
--Exception). K vypsání výsledku funkce použijte funkci
--dbms_output.put_line. Před zavoláním této funkce je nutné
--nastavit Set Serveroutput on.
create or replace FUNCTION FAddStudent2(
p_login IN Student2.login%TYPE,
p_fname IN Student2.fname%TYPE,
p_lname IN Student2.lname%TYPE,
p_tallness IN Student2.tallness%TYPE) 
RETURN VARCHAR AS 
BEGIN
    INSERT INTO student2 (login, fname, lname, tallness) VALUES (p_login, p_fname, p_lname, p_tallness);
    COMMIT;
    return 'ok';
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        return 'not ok!';
END FAddStudent2;

--Vytvořte proceduru StudentBecomeTeacher se dvěma parametry
--p_login a p_department, která přesune záznam studenta s daným
--loginem z tabulky Student do tabulky Teacher (příkaz SELECT
--INTO ).
--Upravte proceduru StudentBecomeTeacher tak, aby představovala
--jednu transakci.
create or replace PROCEDURE StudentBecomeTeacher(p_login IN student2.login%TYPE, p_department IN teacher.department%TYPE) IS
v_student Student2%ROWTYPE;
BEGIN
    SELECT * INTO v_student FROM student2 WHERE login = p_login;
    DELETE FROM student2
    WHERE login = v_student.login;
    INSERT INTO teacher (login, fname, lname, department)
    VALUES (v_student.login, v_student.fname, v_student.lname, p_department);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        rollback;
END StudentBecomeTeacher;

--Vytvořte proceduru AddStudent2 se třemi parametry p_fname,
--p_lname a p_tallness, která vytvoří login z příjmení (parametr
--p_lname) přidáním ’00’ a vloží záznam do tabulky (použijte
--SUBSTR).
CREATE OR REPLACE PROCEDURE AddStudent2(p_fname student2.fname%TYPE, p_lname student2.lname%TYPE, p_tallness student2.tallness%TYPE)
AS
v_login student2.login%TYPE;
v_counter INT;
BEGIN
v_counter := 0;
LOOP
    v_login := LOWER(SUBSTR(p_lname,1,3)) || LPAD(CAST(v_counter AS VARCHAR), 3, '0');
    IF NOT LoginExist(v_login) THEN
        EXIT;
    END IF;
    v_counter := v_counter + 1;
END LOOP;    
INSERT INTO student2 (login, fname, lname, tallness)
VALUES (v_login, p_fname, p_lname, p_tallness);
END;

SELECT * FROM student2;
EXECUTE AddStudent2('Petr', 'Ptacek', 172);

--Vytvořte proceduru IsStudentTall s jedním parametrem p_login,
--která nalezne záznam s daným loginem. Nastaví u něj hodnotu
--atributu isTall na 0 pokud je atribut tallness menší než jeho
--průměrná hodnota a hodnotu 1 v opačném případě (příkaz IF).
create or replace PROCEDURE IsStudentTall (p_login IN student2.login%TYPE) AS
v_student student2%ROWTYPE;
v_avgTallness FLOAT;
BEGIN
    SELECT * INTO v_student FROM student2 WHERE login = p_login;
    SELECT AVG(tallness) INTO v_avgTallness FROM student2;
    IF v_student.tallness > v_avgTallness THEN
        UPDATE student2 SET isTall = 1
        WHERE login = v_student.login;
    ELSE
        UPDATE student2 SET isTall = 0
        WHERE login = v_student.login;
    END IF;
END IsStudentTall;

--Vytvořte funkci LoginExist s jedním parametrem p_login, která
--vrátí true pokud existuje záznam s loginem p_login. Použijte funkci
--LoginExist k rozšíření procedury AddStudent2, která bude vytvářet
--login tak dlouho dokud nenalezne nepoužitý login (příkaz LOOP).
CREATE OR REPLACE FUNCTION LoginExist(p_login student2.login%TYPE) RETURN BOOLEAN
AS
v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM student2 WHERE login = p_login;
    IF v_count = 0 THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
END;

--Upravte proceduru IsStudentTall aby procházela všechny záznamy
--a nastavovala příslušnou hodnotu atributu isTall. Procedura tedy
--bude bez parametrů. Využijte typ student%ROWTYPE a příkazy
--OPEN, FETCH, CLOSE.
create or replace PROCEDURE IsStudentTall AS
v_student student2%ROWTYPE;
v_avgTallness FLOAT;
CURSOR student_cur IS select * from student2;

BEGIN
    SELECT AVG(tallness) INTO v_avgTallness FROM student2;
    OPEN student_cur;
    LOOP
        FETCH student_cur INTO v_student;
        EXIT WHEN student_cur%NOTFOUND;
        
        IF v_student.tallness > v_avgTallness THEN
            UPDATE student2 SET isTall = 1
            WHERE login = v_student.login;
        ELSE
            UPDATE student2 SET isTall = 0
            WHERE login = v_student.login;
        END IF;
    END LOOP;
    CLOSE student_cur;      
END IsStudentTall;

--Přepište proceduru IsStudentTall aby používala cyklus FOR.
create or replace PROCEDURE IsStudentTall AS
v_avgTallness FLOAT;
BEGIN
    SELECT AVG(tallness) INTO v_avgTallness FROM student2;
    FOR v_student IN (select * from student2) LOOP
        IF v_student.tallness > v_avgTallness THEN
            UPDATE student2 SET isTall = 1
            WHERE login = v_student.login;
        ELSE
            UPDATE student2 SET isTall = 0
            WHERE login = v_student.login;
        END IF;    
    END LOOP; 
END IsStudentTall;


EXECUTE isStudentTall();
select * from student2;
