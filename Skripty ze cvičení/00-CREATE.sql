CREATE TABLE Student(
login CHAR (6) NOT NULL,
jmeno VARCHAR (30) NOT NULL,
prijmeni VARCHAR (50) NOT NULL,
PRIMARY KEY (login)
)

CREATE TABLE Ucitel(
login CHAR (5) NOT NULL,
jmeno VARCHAR (30) NOT NULL,
prijmeni VARCHAR (50) NOT NULL,
PRIMARY KEY (login)
)

CREATE TABLE Kurz(
kod CHAR(11) NOT NULL,
nazev VARCHAR(50) NOT NULL,
PRIMARY KEY (kod)
)

CREATE TABLE Garant(
rok VARCHAR (4) NOT NULL,
login CHAR(5) NOT NULL,
kod CHAR(11) NOT NULL,
CONSTRAINT garant_ucitel FOREIGN KEY (login) REFERENCES Ucitel(login),
CONSTRAINT garant_kurz FOREIGN KEY (kod) REFERENCES Kurz(kod),
PRIMARY KEY (rok, login, kod)
)

CREATE TABLE StudijniPlan(
rok VARCHAR (4) NOT NULL,
login CHAR(6) NOT NULL,
kod CHAR(11) NOT NULL,
CONSTRAINT studijniplan_student FOREIGN KEY (login) REFERENCES Student(login),
CONSTRAINT studijniplan_kurz FOREIGN KEY (kod) REFERENCES Kurz(kod),
PRIMARY KEY (rok, login, kod)
)

--INIT

select * from student
select * from kurz
select * from Garant

INSERT INTO student (login, jmeno, prijmeni)
VALUES ('pla457','Jan','Plaváèek');
INSERT INTO student (login, jmeno, prijmeni)
VALUES ('sob458', 'Yveta','Sobotová');
INSERT INTO student (login, jmeno, prijmeni)
VALUES ('pta054','Petr','Ptáèek');

INSERT INTO Ucitel (login, jmeno, prijmeni)
VALUES ('bay01','Josef','Bayer');
INSERT INTO Ucitel (login, jmeno, prijmeni)
VALUES ('cod02','Stanislav','Codd');

INSERT INTO Kurz (kod, nazev)
VALUES ('456-dais-01', 'Databázové a Informaèní systémy');
INSERT INTO Kurz (kod, nazev)
VALUES ('456-tzd-01','Teorie zpracování dat');
INSERT INTO Kurz (kod, nazev)
VALUES ('460-2056/01', 'Databázové systémy 1');
INSERT INTO Kurz (kod, nazev)
VALUES ('460-2006/03', 'Poèítaèové sítì');
INSERT INTO Kurz (kod, nazev)
VALUES ('470-2301/03', 'Diskrétní matematika');

INSERT INTO Garant (rok, login, kod)
VALUES ('2009','bay01','456-dais-01');
INSERT INTO Garant (rok, login, kod)
VALUES ('2009','bay01','460-2056/01');
INSERT INTO Garant (rok, login, kod)
VALUES ('2009','cod02','456-tzd-01');
INSERT INTO Garant (rok, login, kod)
VALUES ('2009','cod02','460-2006/03');

insert into STUDIJNIPLAN (login, kod, rok) values ('pla457', '456-dais-01', '2009');
insert into STUDIJNIPLAN (login, kod, rok) values ('pla457', '456-tzd-01', '2009');
insert into STUDIJNIPLAN (login, kod, rok) values ('pla457', '460-2056/01', '2009');
insert into STUDIJNIPLAN (login, kod, rok) values ('sob458', '460-2006/03', '2009');
insert into STUDIJNIPLAN (login, kod, rok) values ('sob458', '470-2301/03', '2009');
insert into STUDIJNIPLAN (login, kod, rok) values ('sob458', '460-2056/01', '2009');
insert into STUDIJNIPLAN (login, kod, rok) values ('pta054', '456-dais-01', '2009');
insert into STUDIJNIPLAN (login, kod, rok) values ('pta054', '456-tzd-01', '2009');
insert into STUDIJNIPLAN (login, kod, rok) values ('pta054', '470-2301/03', '2009');

-- DOTAZY

--Vypište studenty (tedy hodnoty všech atribut ?u), kte¡rí mají v roce
--2009 zapsány kurzy garantované ucitelem p ¡ ¡ríjmením Codd.
SELECT s.* 
FROM student s JOIN studijniplan st ON s.login = st.login
    JOIN kurz k ON k.kod = st.kod
    JOIN GARANT g ON g.kod = k.kod
    JOIN Ucitel u ON u.login = g.login
WHERE st.rok = '2009' AND u.prijmeni = 'Codd'

--Vypište kurzy, které si v roce 2009 zapsal student p¡ríjmením
--Plavácek.
SELECT DISTINCT k.*
FROM kurz k JOIN studijniplan st ON st.kod = k.kod
    JOIN student s ON s.login = st.login
WHERE st.rok = '2009' AND s.prijmeni = 'Plaváèek'    

--Vypište kurzy, které si zapsal student p¡ríjmením Plavácek
SELECT DISTINCT k.*
FROM kurz k JOIN studijniplan st ON st.kod = k.kod
    JOIN student s ON s.login = st.login
WHERE s.prijmeni = 'Plaváèek' 

--Vypište kódy kurz ?u, které si v roce 2009 zapsal alespon jeden ¡
--student (odstrante duplicitní záznamy).
SELECT DISTINCT k.*
FROM kurz k JOIN studijniplan st ON st.kod = k.kod
    JOIN student s ON s.login = st.login
WHERE st.rok = '2009'    
    
--Vypište ucitele, kte ¡ ¡rí v roce 2009 garantují kurzy, které si ve
--stejném roce zapsal alespon jeden student (odstra ¡ nte duplicitní ¡
--záznamy).
SELECT DISTINCT u.*
FROM ucitel u JOIN garant g ON g.login = u.login AND g.rok ='2009'
    JOIN kurz k ON k.kod = g.kod
    JOIN studijniplan st ON st.kod = k.kod AND st.rok = '2009'

