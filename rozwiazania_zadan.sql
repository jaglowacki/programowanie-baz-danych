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

CREATE FUNCTION czy_pesel(@pesel CHAR(11)) RETURNS INT
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
