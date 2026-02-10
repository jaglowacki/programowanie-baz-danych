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




