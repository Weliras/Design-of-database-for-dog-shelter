--Petr Lukáš
--9:02
--Pøidejte do tabulky Device atribut warning_msg typu VARCHAR2(50) a warning_at typu TIMESTAMP. Napište trigger tgSetWarning,
--který pøi vzniku zaznamenávané události (is_recorded = 1) nastaví u daného zaøízení atribut warning_msg dle atributu
--event_description pøíslušného typu události a atribut warning_at na aktuální èasové razítko.

ALTER TABLE Device
ADD warning_msg VARCHAR2(50) NULL;

ALTER TABLE Device
ADD warning_at TIMESTAMP NULL;

create or replace TRIGGER tgSetWarning BEFORE INSERT ON device_event FOR EACH ROW
DECLARE
v_eventType event_type%ROWTYPE;
BEGIN
    SELECT distinct e_t.* INTO v_eventType FROM event_type e_t
    JOIN device_event d_e ON d_e.tid = e_t.tid
    WHERE d_e.tid = :NEW.tid;

    IF v_eventType.is_recorded = 1 THEN
        UPDATE device
        SET device.warning_msg = v_eventType.event_description, device.warning_at = CURRENT_TIMESTAMP
        WHERE device.did = :NEW.did;
    END IF;
END;

select * from event_type;
select * from device_event;
select * from device;

INSERT INTO device_event(eid,did, pid, tid, startdate, enddate)
VALUEs(200,1,1,1,CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);



--Pøidejte do tabulky Device tøi atributy: pID1, pID2 a pID3. Všechny tyto atributy budou pøedstavovat nepovinný cizí klíè
--do tabulky Person. Napište proceduru spSetDeviceStats s parametrem dID (ID zaøízení), která danému zaøízení nastaví
--hodnoty nových atributù pID1 -- pID3 na osoby, které na daném zaøízení nahlásily nejvíce poruch, tj. pID1 bude
--osoba, která nahlásila nejvíce poruch, pID2 bude druhá taková osoba atd. V pøípadì shodnosti poètu poruch upøednostnìte poøadí
--dle ID osoby.

ALTER TABLE DEVICE
ADD (pid1 NUMBER REFERENCES Person(pid),
    pid2 NUMBER REFERENCES Person(pid),
    pid3 NUMBER REFERENCES Person(pid));
    
CREATE OR REPLACE PROCEDURE spSetDeviceStats(p_dID device.did%TYPE) IS
    CURSOR c_persons IS
        SELECT person.pid 
        FROM Person
        JOIN device_event ON device_event.pid = person.pid
        WHERE device_event.did = p_dID
        GROUP BY person.pid
        ORDER BY COUNT(*) DESC, person.pid ASC
        FETCH FIRST 3 ROWS ONLY;
    v_pid Person.pid%TYPE;    
    v_position INT;
BEGIN
    v_position := 1;
    OPEN c_persons;
    LOOP
    FETCH c_persons INTO v_pid;
        EXIT WHEN c_persons%NOTFOUND;
        IF v_position = 1 THEN
            UPDATE device
            SET pid1 = v_pid
            WHERE device.did = p_dID;
        ELSIF v_position = 2 THEN
            UPDATE device
            SET pid2 = v_pid
            WHERE device.did = p_dID;
        ELSIF v_position = 3 THEN
            UPDATE device
            SET pid3 = v_pid
            WHERE device.did = p_dID;
        END IF;
        v_position := v_position + 1;
    END LOOP;
    CLOSE c_persons;
END;

BEGIN
    spSetDeviceStats(1);
END;

--Pøidejte do tabulky Device povinný atribut is_inactive, který mùže nabývat pouze hodnot 0 nebo 1. Pro existující
--zaøízení bude hodnota nastavena na 0. Napište proceduru spDeleteDevice s parametrem dID (ID zaøízení), která
--na daném zaøízení smaže všechny události s dùležitostí 0 nebo 1. Pokud zaøízení nemá žádnou událost s dùležitostí 2,
--smaže se fyzicky i dané zaøízení. V opaèném pøípadì se u zaøízení pouze nastaví hodnota is_inactive na 1. Procedura
--bude øešena jako transakce.

ALTER TABLE device
ADD is_inactive INT DEFAULT(0) NOT NULL;
ALTER TABLE device
ADD CONSTRAINT ch_is_inactive CHECK(is_inactive IN (0,1));

CREATE OR REPLACE PROCEDURE spDeleteDevice(p_dID device.did%TYPE) AS
count_of_events_of_importance_2 INT;
BEGIN
    DELETE FROM device_event
    WHERE did = p_dID AND tid IN (
        SELECT tid FROM event_type
        WHERE importance = 0 OR importance = 1
    );
    
    SELECT COUNT(*) INTO count_of_events_of_importance_2 FROM device_event
    JOIN event_type ON event_type.tid = device_event.tid
    WHERE device_event.did = p_dID AND importance = 2;
    
    IF count_of_events_of_importance_2 = 0 THEN
        DELETE FROM DEVICE
        WHERE did = p_dID;
    ELSE
        UPDATE DEVICE
        SET is_inactive = 1
        WHERE did = p_dID;
    END IF;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;
--Pøidejte do tabulky Device atributy week_event_max a max_alert. Napište PL/SQL kód, kde pøi pøidávání záznamu do tabulky device_event (tzn. pøi pøidání události na zaøízení),
--zkontrolujete, zda-li poèet událostí s dùležitostí 2 nepøekroèil nastavenou hodnotu week_event_max u daného zaøízení.
--Pokud poèet událostí pøekroèí hodnotu week_event_max, pak u zaøízení nastavte hodnotu max_alert na 1.
ALTER TABLE DEVICE 
ADD (week_event_max INT DEFAULT(5),
     max_alert INT DEFAULT(0));
     
CREATE OR REPLACE TRIGGER checkMaxEvents BEFORE INSERT ON device_event FOR EACH ROW
DECLARE
v_event_count INT;
v_week_event_max Device.week_event_max%TYPE;
BEGIN
    SELECT COUNT(eid) INTO v_event_count FROM device_event
    JOIN event_type ON event_type.tid = device_event.tid
    WHERE device_event.did = :NEW.did AND event_type.importance = 2;
    
    SELECT week_event_max INTO v_week_event_max FROM Device
    WHERE did = :NEW.did;
    
    IF v_event_count > v_week_event_max THEN
        UPDATE device
        SET max_alert = 1
        WHERE did = :NEW.did;
    END IF;    
END;
--Vytvoøte proceduru setLanguage, která bude mít dva vstupní parametry p_person_id a p_language.
--Nastavte dané osobì a všem jeho podøízeným atribut mother_language dle parametru p_language. Projdìte všechny podøízené (nejen ty pøímo podøízené).

CREATE OR REPLACE PROCEDURE setLanguage(p_person_id person.pid%TYPE, p_language person.mother_language%TYPE) AS
BEGIN
  UPDATE person 
  SET mother_language = p_language
  WHERE pid = p_person_id;

  FOR sub IN (SELECT * FROM person WHERE bossid = p_person_id) 
  LOOP
    setlanguage(sub.pid, p_language);
  END LOOP;
END;


--Napiste proceduru PovysenieNaSefa, ktora troch beznych zamestnancov (tzn. zamestnancov, ktori maju definovane bossID)
--s najvyssou odpracovanou dobou (tzn. suctu casu straveneho na vsetkych udalostiach nimi spracovanymi) povysi na sefa (nastavi im bossID na NULL).
--Procedura bude riesena ako transakcia a vypise na obrazovku zoznam povysenych zamestnancov vo formate:
-- Zoznam povysenych zamestnancov: 
--    1. Ivana
--    2. Hiro
--    3. Oumar

CREATE OR REPLACE PROCEDURE PovyseniNaSefa AS
CURSOR bezni_zamestnanci is
        select person.pID, person.name, sum(endDate - startDate) odpracovana_doba from person 
        join device_event on person.pID = device_event.pID 
        where bossID is not NULL 
        group by person.pID, person.name 
        order by sum(endDate - startDate) desc;
  pocitadlo int;
BEGIN
    dbms_output.put_line('Zoznam povysenych zamestnancov: ');
    FOR jeden_zamestanec IN bezni_zamestnanci LOOP
        UPDATE person
        SET bossId = NULL
        WHERE person.pid = jeden_zamestanec.pid;
        dbms_output.put_line('  ' || to_char(pocitadlo) || '. ' || jeden_zamestanec.name);
        EXIT WHEN pocitadlo = 3;
        pocitadlo:=pocitadlo+1;
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN 
        ROLLBACK;
END;

