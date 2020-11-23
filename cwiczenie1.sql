--1
CREATE DATABASE s298269;

--2
CREATE SCHEMA firma;

--3
CREATE ROLE ksiegowosc;
GRANT CONNECT ON DATABASE s298269 to ksiegowosc;
GRANT USAGE ON SCHEMA firma TO ksiegowosc;
GRANT SELECT ON ALL TABLES IN SCHEMA firma TO ksiegowosc;
ALTER DEFAULT PRIVILEGES IN SCHEMA firma GRANT SELECT ON TABLES TO ksiegowosc;
   
--4
--a
CREATE TABLE firma.pracownicy(id_pracownika SERIAL, imie VARCHAR(50) NOT NULL, nazwisko VARCHAR(50) NOT NULL, adres VARCHAR(255), telefon VARCHAR(20));
CREATE TABLE firma.godziny(id_godziny SERIAL, data DATE NOT NULL, liczba_godzin INT NOT NULL, id_pracownika INT NOT NULL);
CREATE TABLE firma.pensja_stanowisko(id_pensji SERIAL, stanowisko VARCHAR(100) NOT NULL, kwota DECIMAL(8,2) NOT NULL);
CREATE TABLE firma.premia(id_premii SERIAL, rodzaj VARCHAR(100) NOT NULL, kwota DECIMAL(8,2) NOT NULL);
CREATE TABLE firma.wynagrodzenie(id_wynagrodzenia SERIAL, data DATE NOT NULL, id_pracownika INT NOT NULL, id_godziny INT NOT NULL, id_pensji INT NOT NULL, id_premii INT NOT NULL);

--b 
ALTER TABLE firma.pracownicy ADD PRIMARY KEY (id_pracownika);
ALTER TABLE firma.godziny ADD PRIMARY KEY (id_godziny);
ALTER TABLE firma.pensja_stanowisko ADD PRIMARY KEY (id_pensji);
ALTER TABLE firma.premia ADD PRIMARY KEY (id_premii);
ALTER TABLE firma.wynagrodzenie ADD PRIMARY KEY (id_wynagrodzenia);
   
--c
ALTER TABLE firma.godziny ADD FOREIGN KEY (id_pracownika) REFERENCES firma.pracownicy(id_pracownika) ON DELETE CASCADE;
ALTER TABLE firma.wynagrodzenie ADD FOREIGN KEY (id_pracownika) REFERENCES firma.pracownicy(id_pracownika) ON DELETE CASCADE;
ALTER TABLE firma.wynagrodzenie ADD FOREIGN KEY (id_godziny) REFERENCES firma.godziny(id_godziny) ON DELETE CASCADE;
ALTER TABLE firma.wynagrodzenie ADD FOREIGN KEY (id_pensji) REFERENCES firma.pensja_stanowisko(id_pensji) ON DELETE CASCADE;
ALTER TABLE firma.wynagrodzenie ADD FOREIGN KEY (id_premii) REFERENCES firma.premia(id_premii) ON DELETE CASCADE;
   
--d
CREATE INDEX idx_pracownicy_id_pracownika ON firma.pracownicy(id_pracownika);
CREATE INDEX idx_godziny_id_godziny ON firma.godziny(id_godziny);
CREATE INDEX idx_pensja_stanowisko_id_pensji ON firma.pensja_stanowisko(id_pensji);
CREATE INDEX idx_premia_id_premii ON firma.premia(id_premii);
CREATE INDEX idx_wynagrodzenia_id_wynagrodzenia ON firma.wynagrodzenie(id_wynagrodzenia);

--e 
COMMENT ON TABLE firma.pracownicy IS 'Table contains all hired people';
COMMENT ON TABLE firma.godziny IS 'Table contains information on number of hours worked during the day by the worker';
COMMENT ON TABLE firma.pensja_stanowisko IS 'Table contains monthly salary per position';
COMMENT ON TABLE firma.premia IS 'Table contains informations about prizes';
COMMENT ON TABLE firma.wynagrodzenie IS 'Table contains informations about workers salaries';
   
--5
--a
ALTER TABLE firma.godziny ADD COLUMN miesiac INT NOT NULL;
ALTER TABLE firma.godziny ADD COLUMN nr_tygodnia INT NOT NULL;

--b 
ALTER TABLE firma.wynagrodzenie ALTER COLUMN data TYPE VARCHAR;

INSERT INTO firma.pracownicy(imie, nazwisko, adres, telefon) VALUES 
('Jan', 'Kowalski', 'Mickiewicza 21', '123456789'), 
('Janusz', 'Kowalski', 'Mickiewicza 37', '987654321'), 
('Adam', 'Nowak', 'Glubczycka 3', '123454321'), 
('Maria', 'Podstawka', 'Raciborska 193', '987656789'), 
('John', 'Doe', 'Testowa 1', '213773211'), 
('Ala', 'Nowak', 'Polna 3', '666666666'), 
('Dummy', 'Dummy', 'Dummy 430', '999999999'), 
('Geogy', 'Phils', 'Lake Lane 321', '444545666'), 
('Anna', 'Jezierska', 'Lesna 39', '876678876'), 
('Mariusz', 'Przysiezny', 'Kozielska 98', '111111111');
   
DO
$do$
DECLARE
   data DATE := '2020-10-07';
BEGIN 
   FOR i IN 1..200 LOOP
   	data := (SELECT DATE((SELECT TIMESTAMP '2020-10-07' + random() * (TIMESTAMP '2020-12-31 20:00:00' - TIMESTAMP '2020-10-01 10:00:00'))));
	INSERT INTO firma.godziny (data, liczba_godzin, id_pracownika, miesiac, nr_tygodnia)
	VALUES (data, (SELECT floor(random() * 12)::INTEGER), (SELECT floor(random() * 9 + 1)::INTEGER), 
	(SELECT EXTRACT(MONTH FROM data)), (SELECT EXTRACT(WEEK FROM data)));
   END LOOP;
END
$do$;

INSERT INTO firma.pensja_stanowisko(stanowisko, kwota) VALUES ('Software Engineer', 8000.00), ('Software Developer', 7500.00), ('Intern Developer', 2500.00), ('HR Advisor', 400.00), ('Receptionist', 1500.00), ('Manager', 15000.00), ('Product Owner', 20000.00), ('Trainee', 999.999), ('Cloud Engineer', 12000.00), ('Staff Engineer', 25000.00);

INSERT INTO firma.premia(rodzaj, kwota) VALUES ('brak', 0), ('Uznaniowa', 500), ('Uznaniowa', 1000), ('Uznaniowa', 1500), ('Uznaniowa', 2000), ('Uznaniowa', 5000), ('Premia', 1000), ('Standardowa', 200), ('Swiateczna', 500), ('Awansowa', 3000);

DO
$do$
DECLARE
   data DATE := '2020-10-07';
BEGIN 
   FOR i IN 1..200 LOOP
        data := (SELECT godziny.data from godziny WHERE id_godziny=i);
   	pracownik := (SELECT id_pracownika from godziny WHERE id_godziny=i);
   	pensja := (SELECT id_pensji from temp WHERE id_pracownika=pracownik);
	INSERT INTO firma.wynagrodzenie (data, id_pracownika, id_godziny, id_pensji, id_premii)
	VALUES (data, pracownik, i, pensja), (SELECT floor(random() * 9 + 1)::INTEGER));
   END LOOP;
END
$do$;

--6
--a
SELECT id_pracownika, nazwisko FROM firma.pracownicy;

--b
SELECT DISTINCT id_pracownika FROM firma.wynagrodzenie JOIN firma.pensja_stanowisko ON firma.wynagrodzenie.id_pensji=firma.pensja_stanowisko.id_pensji WHERE firma.pensja_stanowisko.kwota > 1000;

--c
SELECT DISTINCT id_pracownika FROM firma.wynagrodzenie, firma.pensja_stanowisko, firma.premia WHERE firma.wynagrodzenie.id_pensji=firma.pensja_stanowisko.id_pensji
AND firma.wynagrodzenie.id_premii=firma.premia.id_premii AND firma.premia.rodzaj='brak' AND firma.pensja_stanowisko.kwota > 2000;

--d
SELECT imie, nazwisko FROM firma.pracownicy WHERE imie like 'J%';

--e
SELECT imie, nazwisko FROM firma.pracownicy WHERE nazwisko LIKE '%n%' AND imie LIKE '%a';

--f
SELECT imie, nazwisko, miesiac, (SUM(liczba_godzin)-160) AS nadgodziny FROM firma.godziny
JOIN firma.pracownicy ON firma.godziny.id_pracownika=firma.pracownicy.id_pracownika
GROUP BY imie, nazwisko, miesiac HAVING (SUM(liczba_godzin)-160) > 0; ORDER BY imie, nazwisko, miesiac
	
--g
SELECT DISTINCT imie, nazwisko FROM firma.pracownicy, firma.wynagrodzenie, firma.pensja_stanowisko WHERE
firma.pracownicy.id_pracownika=firma.wynagrodzenie.id_pracownika AND firma.wynagrodzenie.id_pensji=firma.pensja_stanowisko.id_pensji AND
firma.pensja_stanowisko.kwota BETWEEN 1500 AND 3000;
	
--h
SELECT imie, nazwisko FROM firma.pracownicy, firma.wynagrodzenie, firma.godziny, firma.premia WHERE firma.pracownicy.id_pracownika=firma.wynagrodzenie.id_pracownika AND firma.wynagrodzenie.id_godziny=firma.godziny.id_godziny AND firma.wynagrodzenie.id_premii=firma.premia.id_premii AND firma.godziny.liczba_godzin-160>0 AND firma.premia.kwota=0;

	
--7
--a
SELECT pr.id_pracownika FROM firma.pracownicy AS pr JOIN firma.wynagrodzenie AS w ON w.id_pracownika=pr.id_pracownika  JOIN firma.pensja_stanowisko AS ps ON w.id_pensji=ps.id_pensji JOIN firma.godziny AS g ON g.id_pracownika=w.id_pracownika ORDER BY liczba_godzin*kwota;

--b
SELECT  pr.id_pracownika,liczba_godzin*ps.kwota AS pensja,premia.kwota FROM firma.pracownicy AS pr JOIN firma.wynagrodzenie AS w ON w.id_pracownika=pr.id_pracownika  
JOIN firma.pensja_stanowisko AS ps ON w.id_pensji=ps.id_pensji 
JOIN firma.godziny AS g ON g.id_pracownika=w.id_pracownika 
FULL JOIN firma.premia ON premia.id_premii=w.id_premii WHERE  pr.id_pracownika is not null
ORDER BY liczba_godzin*ps.kwota DESC, premia.kwota DESC ;

--c
SELECT COUNT(pr.id_pracownika),stanowisko FROM firma.pracownicy AS pr JOIN firma.wynagrodzenie AS w ON w.id_pracownika=pr.id_pracownika  JOIN firma.pensja_stanowisko AS ps ON w.id_pensji=ps.id_pensji JOIN firma.godziny AS g ON g.id_pracownika=w.id_pracownika GROUP BY stanowisko;

--d
SELECT MIN(liczba_godzin*kwota),  AVG(liczba_godzin*kwota) ,  MAX(liczba_godzin*kwota) ,stanowisko FROM firma.pracownicy AS pr JOIN firma.wynagrodzenie AS w ON w.id_pracownika=pr.id_pracownika  JOIN firma.pensja_stanowisko AS ps ON w.id_pensji=ps.id_pensji JOIN firma.godziny AS g ON g.id_pracownika=w.id_pracownika GROUP BY stanowisko HAVING stanowisko='Kierownik';

--e
SELECT SUM(liczba_godzin*kwota) FROM firma.pracownicy AS pr JOIN firma.wynagrodzenie AS w ON w.id_pracownika=pr.id_pracownika  JOIN firma.pensja_stanowisko AS ps ON w.id_pensji=ps.id_pensji JOIN firma.godziny AS g ON g.id_pracownika=w.id_pracownika;

--f
SELECT SUM(liczba_godzin*kwota),stanowisko FROM firma.pracownicy AS pr JOIN firma.wynagrodzenie AS w ON w.id_pracownika=pr.id_pracownika  JOIN firma.pensja_stanowisko AS ps ON w.id_pensji=ps.id_pensji JOIN firma.godziny AS g ON g.id_pracownika=w.id_pracownika GROUP BY stanowisko;

--g
SELECT COUNT(id_premii) FROM firma.pracownicy AS pr JOIN firma.wynagrodzenie AS w ON w.id_pracownika=pr.id_pracownika  JOIN firma.pensja_stanowisko AS ps ON w.id_pensji=ps.id_pensji JOIN firma.godziny AS g ON g.id_pracownika=w.id_pracownika GROUP BY stanowisko;

--h
DELETE FROM firma.pracownicy WHERE id_pracownika NOT IN ( SELECT pr.id_pracownika FROM firma.pracownicy AS pr JOIN firma.wynagrodzenie AS w ON w.id_pracownika=pr.id_pracownika  
JOIN firma.pensja_stanowisko AS ps ON w.id_pensji=ps.id_pensji 
JOIN firma.godziny AS g ON g.id_pracownika=w.id_pracownika 
FULL JOIN firma.premia ON premia.id_premii=w.id_premii 
WHERE liczba_godzin*ps.kwota > 2700 AND w.id_premii is null AND pr.id_pracownika is not null ); 

--8
--a
UPDATE firma.pracownicy SET telefon = CONCAT('(+48) ', TELEFON);

--b
UPDATE firma.pracownicy SET telefon = CONCAT(LEFT(telefon, 6), SUBSTRING(telefon, 7, 3), '-', SUBSTRING(telefon, 10, 3), '-', RIGHT(telefon, 3));

--c
SELECT id_pracownika, UPPER(imie), UPPER(nazwisko), UPPER(adres), telefon FROM firma.pracownicy WHERE 
LENGTH(nazwisko) = (SELECT MAX(LENGTH(nazwisko)) FROM firma.pracownicy);

--d	
SELECT MD5(imie||nazwisko||adres||telefon||liczba_godzin*ps.kwota) FROM firma.pracownicy AS pr JOIN firma.wynagrodzenie AS w ON w.id_pracownika=pr.id_pracownika  
JOIN firma.pensja_stanowisko AS ps ON w.id_pensji=ps.id_pensji 
JOIN firma.godziny AS g ON g.id_pracownika=w.id_pracownika 
FULL JOIN firma.premia ON premia.id_premii=w.id_premii WHERE pr.id_pracownika is not null;
	
--9 
SELECT 'Pracownik ' || imie || ' ' || nazwisko || ', w dniu '|| EXTRACT(DAY from g.data)||'.'
||EXTRACT(MONTH FROM g.data)||'.'||EXTRACT(YEAR FROM g.data)||' otrzymał pensję całkowitą na kwotę ' 
||g.liczba_godzin*ps.kwota+firma.premia.kwota|| ' zł, gdzie wynagrodzenie zasadnicze wynosiło: '||160*ps.kwota ||' zł, premia: '
||firma.premia.kwota||' zł, nadgodziny: '||(liczba_godzin-160)*ps.kwota||' zł. '	
FROM firma.pracownicy AS pr JOIN firma.wynagrodzenie AS w ON w.id_pracownika=pr.id_pracownika  
JOIN firma.pensja_stanowisko AS ps ON w.id_pensji=ps.id_pensji 
JOIN firma.godziny AS g ON g.id_pracownika=w.id_pracownika 
FULL JOIN firma.premia ON premia.id_premii=w.id_premii WHERE pr.id_pracownika is not null;
