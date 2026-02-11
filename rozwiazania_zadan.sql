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

