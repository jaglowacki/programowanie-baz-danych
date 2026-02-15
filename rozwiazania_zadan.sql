-- Studia Podyplomowe:	SZTUCZNA INTELIGENCJA W ANALIZIE DANYCH
-- Przedmiot:			PROGRAMOWANIE BAZ DANYCH
-- Student:				Janusz G³owacki


--ZADANIE 3.1
--Napisaæ funkcjê sprawdzaj¹c¹ czy podany w argumencie tekst jest palindromem
--Funkcja zwraca 1, gdy podane zdanie jest palindromem, 0 w przeciwnym przypadku

CREATE FUNCTION czy_palindrom(@zdanie VARCHAR(max)) RETURNS TINYINT 
AS
BEGIN
    DECLARE @tekst VARCHAR(max)
    DECLARE @wynik AS TINYINT
    SET @tekst=LOWER(REPLACE(TRANSLATE(@zdanie,',.!?:;-''"','         '),' ',''))
    IF LEN(@zdanie)>0 AND @tekst=REVERSE(@tekst)
        SET @wynik=1
    ELSE
        SET @wynik=0
    RETURN @wynik
END

--Sprawdzenie
--Oczekujemy 1 dla:
SELECT dbo.czy_palindrom('Koby³a ma ma³y bok') AS 'Wynik' 
SELECT dbo.czy_palindrom('Kajak') AS 'Wynik'
SELECT dbo.czy_palindrom('£apa³ za kran, a kanarka z³apa³') AS 'Wynik'
SELECT dbo.czy_palindrom('Anna') AS 'Wynik'
SELECT dbo.czy_palindrom('Mo¿e je¿ ³¿e je¿om') AS 'Wynik'
SELECT dbo.czy_palindrom('02.02.2020') AS 'Wynik'
--Oczekujemy 0 dla:
SELECT dbo.czy_palindrom('Janusz') AS 'Wynik'
SELECT dbo.czy_palindrom('01.02.2020') AS 'Wynik'
SELECT dbo.czy_palindrom('Inne zdanie') AS 'Wynik'
SELECT dbo.czy_palindrom('') AS 'Wynik'

--ZADANIE 3.2
--Na podstawie bazy Northwind-napisaæ funkcjê zwracaj¹c¹ wartoœæ sprzeda¿y towarów w podanych parametrami: 
--kategorii i nazwie klienta. Funkcja nigdy nie powinna zwracaæ wartoœci Null

USE Northwind

CREATE FUNCTION sprzedaz_klient_kategoria(@klient VARCHAR(max), @kategoria VARCHAR(max)) RETURNS FLOAT
AS
BEGIN
    DECLARE @wynik FLOAT
    SET @wynik=(SELECT SUM(OD.UnitPrice * OD.Quantity) FROM Customers C 
                JOIN Orders O ON C.CustomerID=O.CustomerID
                JOIN [Order Details] OD ON O.OrderID=OD.OrderID
                JOIN Products P ON OD.ProductID=P.ProductID
                JOIN Categories CAT ON P.CategoryID=CAT.CategoryID
                WHERE C.CompanyName=@klient AND CAT.CategoryName=@kategoria)
    IF (@wynik IS NULL)
        SET @wynik=0
    RETURN @wynik
END

--Sprawdzenie
SELECT dbo.sprzedaz_klient_kategoria('Antonio Moreno Taquería','Beverages') AS 'Wartoœæ Sprzeda¿y'
SELECT dbo.sprzedaz_klient_kategoria('Piccolo und mehr','Condiments') AS 'Wartoœæ Sprzeda¿y'

--ZADANIE 3.3
--Na podstawie bazy Northwind-napisaæ funkcjê zwracaj¹c¹ unikalne nazwy klientów, 
--którzy dokonali zakupu w miesi¹cu-podanym parametrem.
--Zak³adam, ¿e interesuj¹cy nas miesi¹c podawany jest w postaci cyfry od 1 do 12

USE Northwind

CREATE FUNCTION klient_miesiac_zakupu(@miesiac TINYINT) RETURNS TABLE
AS
RETURN (SELECT DISTINCT C.CompanyName FROM Customers C
        JOIN Orders O ON C.CustomerID=O.CustomerID
        WHERE MONTH(O.OrderDate)=@miesiac)

--Sprawdzenie
SELECT * FROM dbo.klient_miesiac_zakupu(3)
SELECT * FROM dbo.klient_miesiac_zakupu(7)

--ZADANIE 4.1
--Poprawiæ funkcjê czy_pesel (napisan¹ wspólne podczas zajêæ), tak aby by³a odporna na b³êdne 
--parametry (wyœwietla³a stosowny komunikat, zamiast generowania b³êdów), funkcja powinna byæ 
--'u¿yszkodnikoodporna' - funkcja powinna równie¿ dzia³aæ poprawnie w przypadku numerów 
--PESEL koñcz¹cych siê cyfr¹ 0.

CREATE FUNCTION czy_pesel(@pesel CHAR(11)) RETURNS TINYINT
AS
BEGIN
    DECLARE @suma INT, @m INT, @wynik TINYINT=0 -- tu inicjujemy
    SET @suma=CAST(SUBSTRING(@pesel,1,1) AS INT) * 1 + 
              CAST(SUBSTRING(@pesel,2,1) AS INT) * 3 +
              CAST(SUBSTRING(@pesel,3,1) AS INT) * 7 +
              CAST(SUBSTRING(@pesel,4,1) AS INT) * 9 +
              CAST(SUBSTRING(@pesel,5,1) AS INT) * 1 +
              CAST(SUBSTRING(@pesel,6,1) AS INT) * 3 +
              CAST(SUBSTRING(@pesel,7,1) AS INT) * 7 +
              CAST(SUBSTRING(@pesel,8,1) AS INT) * 9 +
              CAST(SUBSTRING(@pesel,9,1) AS INT) * 1 +
              CAST(SUBSTRING(@pesel,10,1) AS INT) * 3 
    SET @m = @suma % 10
    IF (LEN(@pesel)=11) AND (@pesel NOT LIKE '%[^0-9]%') 
    AND (CAST(SUBSTRING(@pesel,11,1) AS INT)=(10-@m) % 10)
        SET @wynik=1
    RETURN @wynik
END

--Sprawdzenie: PESEL Poprawny
SELECT dbo.czy_pesel('44051014586')
SELECT dbo.czy_pesel('49040501580')

--Sprawdzenie: PESEL B³êdny
SELECT dbo.czy_pesel('44051014582')
SELECT dbo.czy_pesel('44051O14586')
SELECT dbo.czy_pesel('4405101458')

--ZADANIE 4.2
--Napisaæ procedurê dodaj¹c¹ nowego studenta (do tabeli 'Studenci' z zajêæ). 
--Procedura nie powinna pozwoliæ na dopisanie studenta niepe³noletniego

USE pbd_podyplom

CREATE PROCEDURE dodaj_studenta 
    @imie VARCHAR(20),
    @nazwisko VARCHAR(30),
    @data_urodzenia DATETIME,
    @plec CHAR(1),
    @miasto VARCHAR(30),
    @liczba_dzieci INT
AS
IF @data_urodzenia<=DATEADD(YEAR, -18, GETDATE())
    BEGIN
        INSERT INTO "studenci" (imie, nazwisko, data_urodzenia, plec, miasto, liczba_dzieci)
        VALUES (@imie, @nazwisko, @data_urodzenia, @plec, @miasto, @liczba_dzieci)

        PRINT CONCAT('Dodano studenta: ', @imie, ' ', @nazwisko)
    END
ELSE 
    BEGIN
        RAISERROR('Student nie mo¿e byæ niepe³noletni !',16,1)
        RETURN -1
    END

--Sprawdzenie-student pe³noletni
EXEC dodaj_studenta 
    @imie = 'Janusz',
    @nazwisko = 'G³owacki',
    @data_urodzenia = '1974-06-25',
    @plec = 'M',
    @miasto = 'Piekary Œl¹skie',
    @liczba_dzieci = 1;

--Sprawdzenie-student niepe³noletni 
EXEC dodaj_studenta 
    @imie = 'Robert',
    @nazwisko = 'Mazur',
    @data_urodzenia = '2009-01-21',
    @plec = 'M',
    @miasto = 'Tarnowskie Góry',
    @liczba_dzieci = 2;

--ZADANIE 5.1 Utworzyæ tabelê: klienci ={id_klienta, imie, nazwisko, plec, data_urodzenia, pesel}. 
--Napisaæ wyzwalacz, który sprawdzi poprawnoœæ wprowadzonego numeru PESEL oraz 
--dopasowanie podanych wartoœci daty urodzenia i p³ci do numery PESEL.

USE pbd_podyplom

--Utworzenie pustaj tabeli

CREATE TABLE klienci(
  "id_klienta" int primary key identity,
  "imie" varchar(20) default NULL,
  "nazwisko" varchar(30) default NULL,
  "plec" char(1) default NULL,
  "data_urodzenia" datetime default NULL,
  "pesel" CHAR(11) default NULL)

--Korzystam z funkcji z ZADANIA 4.1 czy pesel, dla przypomnienia

CREATE FUNCTION czy_pesel(@pesel CHAR(11)) RETURNS TINYINT
AS
BEGIN
    DECLARE @suma INT, @m INT, @wynik TINYINT=0 
    SET @suma=CAST(SUBSTRING(@pesel,1,1) AS INT) * 1 + 
              CAST(SUBSTRING(@pesel,2,1) AS INT) * 3 +
              CAST(SUBSTRING(@pesel,3,1) AS INT) * 7 +
              CAST(SUBSTRING(@pesel,4,1) AS INT) * 9 +
              CAST(SUBSTRING(@pesel,5,1) AS INT) * 1 +
              CAST(SUBSTRING(@pesel,6,1) AS INT) * 3 +
              CAST(SUBSTRING(@pesel,7,1) AS INT) * 7 +
              CAST(SUBSTRING(@pesel,8,1) AS INT) * 9 +
              CAST(SUBSTRING(@pesel,9,1) AS INT) * 1 +
              CAST(SUBSTRING(@pesel,10,1) AS INT) * 3 
    SET @m = @suma % 10
    IF (LEN(@pesel)=11) AND (@pesel NOT LIKE '%[^0-9]%') 
    AND (CAST(SUBSTRING(@pesel,11,1) AS INT)=(10-@m) % 10)
        SET @wynik=1
    RETURN @wynik
END

--Definiujê funkcjê sparawdzaj¹c¹, czy numer PESEL odpowiada dacie urodzenia

CREATE FUNCTION czy_data(@pesel CHAR(11), @data DATETIME) RETURNS TINYINT
AS
BEGIN
    DECLARE @rr INT, @mm INT, @dd INT, @data_z_pesel DATETIME,
            @rok INT=0, @miesiac INT=0, @wynik TINYINT=0 
    SET @rr=CAST(SUBSTRING(@pesel,1,2) AS INT)
    SET @mm=CAST(SUBSTRING(@pesel,3,2) AS INT)
    SET @dd=CAST(SUBSTRING(@pesel,5,2) AS INT)
    IF @mm BETWEEN 81 AND 92 SET @rok=@rr+1800
    ELSE IF @mm BETWEEN 1 AND 12 SET @rok=@rr+1900
    ELSE IF @mm BETWEEN 21 AND 32 SET @rok=@rr+2000
    ELSE IF @mm BETWEEN 41 AND 52 SET @rok=@rr+2100
    ELSE IF @mm BETWEEN 61 AND 72 SET @rok=@rr+2200
    IF @mm>20 SET @miesiac=@mm%20 ELSE SET @miesiac=@mm
    IF (@rok BETWEEN 1800 AND 2299) AND (@miesiac BETWEEN 1 AND 12) 
    BEGIN
        SET @data_z_pesel=DATEFROMPARTS(@rok, @miesiac, @dd)
        IF @data=@data_z_pesel SET @wynik=1
    END
    RETURN @wynik
END

--utworzenie wyzwalacza

CREATE TRIGGER klienci_not_ok
ON klienci
FOR INSERT
AS
IF EXISTS (SELECT * FROM INSERTED I WHERE dbo.czy_pesel(I.pesel) = 0)
    BEGIN
        PRINT('Poda³eœ ninepoprawny PESEL!')
        ROLLBACK 
    END
IF EXISTS (SELECT * FROM INSERTED I 
           WHERE (CAST(SUBSTRING(I.pesel,10,1) AS INT) % 2 = 0 AND I.plec <> 'K')
              OR (CAST(SUBSTRING(I.pesel,10,1) AS INT) % 2 = 1 AND I.plec <> 'M'))
    BEGIN
        PRINT('Wprowadzona p³eæ nie odpowiada numerowi PESEL')
        ROLLBACK
    END
IF EXISTS (SELECT * FROM INSERTED I WHERE dbo.czy_data(I.pesel,I.data_urodzenia)=0)
    BEGIN
        PRINT('Data urodzenie nie odpowiada numerowi PESEL')
        ROLLBACK 
    END

--sprawdzenie (b³êdne dane)

INSERT INTO klienci(imie, nazwisko, plec, data_urodzenia, pesel)
VALUES ('Joanna', 'Kowalska', 'K', '1949-04-15', '49040501580')

INSERT INTO klienci(imie, nazwisko, plec, data_urodzenia, pesel)
VALUES ('Joanna', 'Kowalska', 'M', '1949-04-05', '49040501580')

INSERT INTO klienci(imie, nazwisko, plec, data_urodzenia, pesel)
VALUES ('Joanna', 'Kowalska', 'K', '1949-04-05', '49040501581')

-- sprawdzenie (dane poprawne)
INSERT INTO klienci(imie, nazwisko, plec, data_urodzenia, pesel)
VALUES ('Joanna', 'Kowalska', 'K', '1949-04-05', '49040501580')


--ZADANIE 5.2 W tabeli 'studenci' utworzyæ wyzwalacz, który uniemo¿liwi dopisanie niepe³noletnich matek.

USE pbd_podyplom

CREATE TRIGGER matka_not_ok
ON studenci
FOR INSERT
AS
IF EXISTS (SELECT * FROM INSERTED I WHERE I.plec='K' AND I.liczba_dzieci>0 AND I.data_urodzenia>DATEADD(YEAR, -18, GETDATE()))
    BEGIN
        PRINT('Próba wprowadzenia do bazy niepe³noletniej matki!')
        ROLLBACK 
    END

--Sprawdzenie-dane z niepe³noletni¹ matk¹
INSERT INTO studenci (imie, nazwisko, data_urodzenia, plec, miasto, liczba_dzieci)
VALUES ('Jadwiga', 'Rajner', '2009-02-12', 'K', 'Bytom', 1)

--Sprawdzenie-poprawne dane
INSERT INTO studenci (imie, nazwisko, data_urodzenia, plec, miasto, liczba_dzieci)
VALUES ('Monika', 'G³owacka', '1976-03-31', 'K', 'Piekary Œl¹skie', 1)
INSERT INTO studenci (imie, nazwisko, data_urodzenia, plec, miasto, liczba_dzieci)
VALUES ('Roman', 'Rajner', '2009-02-12', 'M', 'Bytom', 1)
INSERT INTO studenci (imie, nazwisko, data_urodzenia, plec, miasto, liczba_dzieci)
VALUES ('Dominika', 'Tomczyk', '2008-09-12', 'K', 'Bytom', 0)

-- Studia Podyplomowe:	SZTUCZNA INTELIGENCJA W ANALIZIE DANYCH
-- Przedmiot:			PROGRAMOWANIE BAZ DANYCH
-- Student:				Janusz G³owacki
