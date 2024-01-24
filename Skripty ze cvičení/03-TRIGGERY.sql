CREATE TABLE Statistics
(
operation VARCHAR(10) PRIMARY KEY,
operationCount INT NOT NULL
);
INSERT INTO Statistics VALUES ('INSERT', 0);
INSERT INTO Statistics VALUES ('UPDATE', 0);
INSERT INTO Statistics VALUES ('DELETE', 0);

--Vytvoˇrte trigger OperationCount který zaznamená do tabulky
--Statistics pocty operací insert, update a delete. Tabulka ˇ
--Statistics bude tabulka se dvema atributy. První atribut ˇ
--operation bude pˇredstavovat typ operace a druhý atribut
--operationCount bude pˇredstavovat pocty daných operací ˇ
--(použijte detekci DML operace v triggeru).
CREATE OR REPLACE TRIGGER OperationCount BEFORE INSERT OR UPDATE OR DELETE ON student2
BEGIN
case
    when inserting then
      update statistics set operationcount = operationcount + 1 where operation = 'insert';
    when updating then
      update statistics set operationcount = operationcount + 1 where operation = 'update';
    when deleting then
      update statistics set operationcount = operationcount + 1 where operation = 'delete';
  end case;
END;

--Vytvořte tabulku StudentHistory:

CREATE TABLE StudentHistory
(
login CHAR(6),
columnName VARCHAR(30),
oldValue VARCHAR(30),
newValue VARCHAR(30),
dateTime TIMESTAMP
)

--Vytvořte trigger tg_StudentHistory, který bude logovat historii změn atributů v tabulce Student.
--S každou změnou jména nebo příjmení (fname, lname) přidáme záznam do tab. StudentHistory - login studenta, u kterého probíhá změna,
--kterého sloupce se změna týká (fname nebo lname), původní hodnota, nová hodnota a časové razítko změny.

CREATE OR REPLACE TRIGGER tg_StudentHistory BEFORE UPDATE ON student2 FOR EACH ROW
BEGIN
    IF updating('fname') THEN
        INSERT INTO studentHistory(login, columnName, oldValue, newValue, dateTime)
        VALUES(:OLD.login, 'fname', :OLD.fname, :NEW.fname, CURRENT_TIMESTAMP);
    END IF; 
    IF updating('lname') THEN
         INSERT INTO studentHistory(login, columnName, oldValue, newValue, dateTime)
        VALUES(:OLD.login, 'lname', :OLD.lname, :NEW.lname, CURRENT_TIMESTAMP);
    END IF;
END;

--Pˇridejte atribut kapacita do tabulky Kurz, který bude
--pˇredstavovat maximální kapacitu daného kurzu. Vytvoˇrte trigger
--kontrolaKapacity, který vypíše varovnou hlášku v pˇrípade,ˇ
--že je kapacita kurzu pˇrekrocena.
ALTER TABLE kurz
ADD kapacita INT NULL;

CREATE OR REPLACE TRIGGER kontrolaKapacity BEFORE INSERT ON studijniPlan FOR EACH ROW
DECLARE
v_count INT;
v_kapacita kurz.kapacita%TYPE;
capacity_exceeded EXCEPTION;
BEGIN
    SELECT kapacita INTO v_kapacita FROM kurz WHERE kod = :NEW.kod;
    SELECT COUNT(*) INTO v_count FROM studijniPlan WHERE kod = :NEW.kod;
    IF (v_count > v_kapacita) THEN
        RAISE capacity_exceeded;
        --dbms_output.put_line('Kapacita kurzu byla prekrocena!');
    END IF;
END;
