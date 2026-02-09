-------------------------- (trzeba mieæ uprawniwnia administratora bazy danych)

--CREATE FUNCTION [nazwa]([arg]) RETURNS [typ]
--AS
--BEGIN
--    [cialo_funkcji]-- kod
--    RETURN [typ]
--END

----------------------------------------------------------------------------------
--funkcja teraz zwracaj¹ca bie¿¹c¹ datê

CREATE FUNCTION teraz() RETURNS DATETIME 
AS
BEGIN
    RETURN GETDATE()
END

SELECT dbo.teraz()


CREATE FUNCTION teraz2() RETURNS DATE --bo format date jest compatybilny z GETDATE
AS
BEGIN
    RETURN GETDATE()
END

SELECT dbo.teraz2()

-- napisaæ funkcje 'dlugosc tekstu' - ktora zwraca liczbe znakow

SELECT LEN('ala ma kota')

--@-oznacza, ¿e za ni¹ jest zmienna
-- tutaj najpierw nazwa zmiennej a potem typ

CREATE FUNCTION dlugosc_tekst(@tekst varchar(50)) RETURNS INT
AS
BEGIN
    RETURN LEN(@tekst)
END


SELECT dbo.dlugosc_tekst('Ala ma kota')

SELECT *, dbo.dlugosc_tekst(nazwisko) AS 'Liczba znaków NAZWISKA' FROM studenci

--DML - insert, update, delete

--DDL - create, alter, drop (drop i piszemy na now funkckjê) a alter nazwa zostaje z zmieniamy tylko cia³o funkcji (argumenty)

-------------------------------------------------------------------------------------------------

-- napisaæ funkcjê z_litery_wielkiej - zwraca tekst napisany w du¿ej litery (pozosta³e znaki to litery ma³e)
-- wykorzystaæ UPPER('abc') lub LOWER('ABC') lub SUBSTRING() lub LEFT() lub RIGHT()

-- to ja próbowa³em
--CREATE FUNCTION z_wielkiej_litery(@tekst VARCHAR(50)) RETURNS VARCHAR(50)
--AS
--BEGIN
--    RETURN CONCAT(UPPER(SUBSTRING(@tekst,1,1)),RIGHT(@tekst,2))        
--END

--SELECT UPPER('abc')
--SELECT RIGHT('abcasdas',2)
--SELECT CONCAT(UPPER(SUBSTRING('abc',1,1)),RIGHT('abc',2))

--SELECT dbo.z_wielkiej_litery('wszystko w zdaniu')

--------------------------------------------------------------------------------

--tutaj prowadz¹cy
SELECT CONCAT(UPPER(LEFT('ala ma koale',1)), LOWER(SUBSTRING('ala ma koale',2,LEN('ala ma koale')-1)))

-- uwaga, gdy zwracamy RETURN to obudowujemy funkcjê nawiasem, bo inaczej wywali b³¹d
CREATE FUNCTION z_wielkiej_litery(@tekst VARCHAR(255)) RETURNS VARCHAR(255)
AS
BEGIN
    RETURN (SELECT CONCAT(UPPER(LEFT(@tekst,1)), LOWER(SUBSTRING(@tekst,2,LEN(@tekst)-1)))) 
    -- mo¿na te¿ bez selecta: RETURN CONCAT(UPPER(LEFT(@tekst,1)), LOWER(SUBSTRING(@tekst,2,LEN(@tekst)-1)))
    -- wtedy nie trzeba obudowywaæ nawiasem
END

SELECT dbo.z_wielkiej_litery('aBcdEFg')

-----------------------------------------------------------------------------------

--napisaæ funkcjê 'inicja³y' np. Nowak Jacek ->NJ

SELECT UPPER(CONCAT(LEFT('nowak',1), LEFT('Jacek',1)))

-- tuaj alter bo przy pierwszej definicji pope³niliœmy b³¹t i chcemy zmieniæ funkcjê
-- dla inicj³ów wystarczy³oby pobraæ tylko pierwsze znaki ze zmiennych i wtedy mo¿na by³oby:
-- CREATE FUNCTION inicjaly(@nazwisko VARCHAR(1), @imie VARCHAR(1)) RETURNS VARCHAR(2)
-- wówczas nie muszê wycinaæ pierwszych liter
-- mo¿emy te¿ u¿yæ max: CREATE FUNCTION inicjaly(@nazwisko VARCHAR(max), @imie VARCHAR(max)) RETURNS VARCHAR(2)
-- wtedy rezerwujemy maksymaln¹ dostêpn¹ iloœc pamiêci na stringa ale wykorzystujem tylko tyle ile ma zmienna
ALTER FUNCTION inicjaly(@nazwisko VARCHAR(255), @imie VARCHAR(255)) RETURNS VARCHAR(2)
AS
BEGIN
    RETURN UPPER(CONCAT(LEFT(@nazwisko,1), LEFT(@imie,1)))
END

CREATE FUNCTION inicjaly2(@nazwisko VARCHAR(1), @imie VARCHAR(1)) RETURNS VARCHAR(2)
AS
BEGIN
    RETURN UPPER(CONCAT(@nazwisko, @imie))
END

SELECT dbo.inicjaly(nazwisko,imie), * FROM studenci
SELECT dbo.inicjaly2(nazwisko,imie), * FROM studenci

-- ró¿nice: 
--char(20) - 20 znaków, je¿eli wpiszemy 3 znaki to pozosta³e bêd¹ uzupe³nianie spacjami
--varchar(20) - maksymalnie mo¿e byæ 20 znaków, ale pamiêtane jest tylko tyle znaków ile wpiszemy

-----------------------------------------------------------------------------------------

-- napisaæ funkcjê 'ile_osob' - zwraca z tabeli studenci liczbê osób podanej w argumencie p³ci
-- poniewa¿ funkcja jest skalarna to przypilnowaæ , ¿eby funkcja zwraca³a jedn¹ wartoœæ

SELECT COUNT(*) FROM studenci WHERE plec='K'

CREATE FUNCTION ile_osob(@plec VARCHAR(1)) RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM studenci WHERE plec=@plec)
END

SELECT dbo.ile_osob('M')

------------------------------------------------------------------------------------------

-- napisaæ funkcjê ile_dzieci_z_miasta - zwraca liczbê dzieci mieszkaj¹cych w podanym parametrze mieœcie

SELECT SUM(liczba_dzieci) FROM STUDENCI WHERE miasto='Katowice'

ALTER FUNCTION ile_dzieci_z_miasta(@miasto VARCHAR(max)) RETURNS INT
AS
BEGIN
    RETURN (SELECT SUM(liczba_dzieci) FROM STUDENCI WHERE miasto=@miasto)
END

SELECT dbo.ile_dzieci_z_miasta('Katowice')

SELECT dbo.ile_dzieci_z_miasta('Szczecin') -- tu dostaliœmy NULL i to niedobrze
--bo np.
SELECT 2+NULL --> daje NULL a tego nie chcemy bo psuje nam obliczenia

-----------------------------------------------------------------------------------------------

-- napisaæ funkcjê inicja³y - litery powinny byæ rozdzielone kropkami po ka¿dej literze
-- np. Nowak Jan => N.J.
-- CONCAT_WS - ³¹czy z separatorem jako pierwszy argumentem

SELECT UPPER(CONCAT(LEFT('Nowak',1),'.',LEFT('Jan',1),'.'))
SELECT CONCAT_WS('.','Nowak','Jan')
SELECT CONCAT_WS('.','Nowak','Jan','')
SELECT UPPER(CONCAT_WS('.',LEFT('Nowak',1),LEFT('Jan',1),''))

-- napisaæ funkcjê inicjaly z kropkami albo bez w zale¿noœci od wartoœci trzeciego parametru
-- w SQL'u nie ma typu BOOL'a, TINYINT-INT na jednym bajcie

CREATE FUNCTION inicjaly3(@nazwisko VARCHAR(max), @imie VARCHAR(max), @czy_kropka TINYINT) RETURNS VARCHAR(4)
AS
BEGIN
    IF (@czy_kropka = 0)
        RETURN UPPER(CONCAT(LEFT(@nazwisko,1),LEFT(@imie,1)))
    ELSE
        RETURN UPPER(CONCAT(LEFT('Nowak',1),'.',LEFT('Jan',1),'.'))
END

-- B³¹d, bo RETURN musi byæ ostatnim poleceniem w funkcji, trzeba to zrobiæ za pomoc¹ zmiennej poœredniej,
-- któr¹ zwrócimy jako ostatnie polecenie

ALTER FUNCTION inicjaly3(@nazwisko VARCHAR(max), @imie VARCHAR(max), @czy_kropka TINYINT) RETURNS VARCHAR(4)
AS
BEGIN
    DECLARE @wynik VARCHAR(4) -- deklaracja zmiennej
    IF (@czy_kropka = 0)
        SET @wynik= UPPER(CONCAT(LEFT(@nazwisko,1),LEFT(@imie,1)))
    ELSE
        BEGIN
            SET @wynik=UPPER(CONCAT(LEFT(@nazwisko,1),'.',LEFT(@imie,1),'.'))
        END -- gdybyœmy mieli wiêcej instrukcji
    RETURN @wynik
END

SELECT dbo.inicjaly3(nazwisko, imie, 0), dbo.inicjaly3(nazwisko, imie, 1), * FROM studenci

------------------------------------------------------------------
-- wracamy do przyk³¹du liczby dzieci z miast

SELECT SUM(liczba_dzieci) FROM STUDENCI WHERE miasto='Katowice'
-- SUM() jak nic nie znajdzie zwraca NULL, COUNT() jak nic nie znajdzie zwraca 0

CREATE FUNCTION ile_dzieci_z_miasta2(@miasto VARCHAR(max)) RETURNS INT
AS
BEGIN
    DECLARE @wynik INT
    SET @wynik=(SELECT SUM(liczba_dzieci) FROM STUDENCI WHERE miasto=@miasto)
    IF (@wynik IS NULL) -- nie mo¿emy  u¿yæ = bo null jest wartoœci¹ pust¹ (mo¿e byæ IS NOT NULL)
        SET @wynik=0
    RETURN @wynik
END

SELECT dbo.ile_dzieci_z_miasta2('Katowice')

SELECT dbo.ile_dzieci_z_miasta2('Szczecin') 

--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--ZAWSZE NALE¯Y ROBIÆ TAK, ABY FUNKCJE NIGDY NIE ZWRACA£Y WARTOŒCI PUSTYCH!!!!!!!!!!!!!!
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

-- SUM() jak nic nie znajdzie zwraca NULL, COUNT() jak nic nie znajdzie zwraca 0 dlaczego?
--!!!!!!!!!!!!!!!!!!!!Dlatego przy SUM() musi zapaliæ siêczerwona lampka !!!!!!!!!!!!!!!!!!!

SELECT COUNT(*) FROM studenci
SELECT * FROM studenci
UPDATE studenci SET liczba_dzieci=null WHERE nazwisko='nijaka'
SELECT COUNT(liczba_dzieci) FROM studenci -- gdy liczymy wartoœci w konkretnym atrybucie (kolumnie)
                                          -- to null'e nie s¹ zliczane
UPDATE studenci SET liczba_dzieci=0 WHERE nazwisko='nijaka' --wrcamy z wartoœci¹ liczba dzieci=0
SELECT * FROM studenci

SELECT COUNT(DISTINCT imie) FROM studenci -- zwraca liczbê unikalnych imion
SELECT * FROM studenci

-- co z MIN() i MAX()
-- MIN() i MAX() ignoruje wartoœæ pust¹ - eliminuje wartoœæ pust¹

UPDATE studenci SET liczba_dzieci=null WHERE nazwisko='nijaka'
SELECT * FROM studenci
SELECT MIN(liczba_dzieci) FROM studenci
SELECT MAX(liczba_dzieci) FROM studenci
--UPDATE studenci SET liczba_dzieci=0 WHERE nazwisko='nijaka' --wrcamy z wartoœci¹ liczba dzieci=0

-----------------------------------------------------------------------------------------------------------
-- UWAGA ! ZMIENIAMY BAZÊ NA NORTHWIND!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-----------------------------------------------------------------------------------------------------------


-- na podstawie danych Nordwind napisaæ funkcje wartoœæ sprzeda¿y
-- z podanego parametru kraju klienta, z eliminacj¹ zwrócenia wartoœci null!

SELECT SUM(UnitPrice * Quantity)
FROM Customers C JOIN Orders O ON C.CustomerID=O.CustomerID
JOIN [Order Details] OD ON O.OrderID=OD.OrderID
WHERE Country='Poland'

-- zwracana wartoœæ jest liczb¹ zmiennoprzecinkow¹

ALTER FUNCTION sprzedaz_z_kraju(@kraj VARCHAR(max)) RETURNS FLOAT
AS
BEGIN
    DECLARE @wynik FLOAT
    SET @wynik=(SELECT SUM(UnitPrice * Quantity)
            FROM Customers C JOIN Orders O ON C.CustomerID=O.CustomerID
            JOIN [Order Details] OD ON O.OrderID=OD.OrderID
            WHERE Country=@kraj)
    IF (@wynik IS NULL)
        SET @wynik=0
    RETURN @wynik
END

SELECT dbo.sprzedaz_z_kraju('Poland')
SELECT dbo.sprzedaz_z_kraju('Polska') -- dostajemy 0 , a bez IF'a dostalibyœmy NULL

--------------------------------------------------------------------------------------

--napisaæ funkcjê zwracaj¹c¹ liczbê sztuk produktów sprzedanych z kategorii podanej jako parametr
--wyeliminowaæ wartoœæ NULL

SELECT SUM(Quantity) 
FROM Categories C JOIN Products P ON C.CategoryID=P.CategoryID  
                  JOIN [Order Details] OD ON P.ProductID=OD.ProductID
WHERE CategoryName = 'Beverages'

CREATE FUNCTION liczba_sztuk(@kategoria VARCHAR(max)) RETURNS INT
AS
BEGIN
    DECLARE @wynik FLOAT
    SET @wynik=(SELECT SUM(Quantity) 
                FROM Categories C JOIN Products P ON C.CategoryID=P.CategoryID  
                JOIN [Order Details] OD ON P.ProductID=OD.ProductID
                WHERE CategoryName = @kategoria)
    IF (@wynik IS NULL)
        SET @wynik=0
    RETURN @wynik
END

SELECT dbo.liczba_sztuk('Beverages')

--SELECT ISNULL(atrybut,wartoœæ_gdy_null) - jest to gotowa funkcja kótra sprawdza czy jest NULL, wtedy nie trzeba stosowaæ IF
SELECT ISNULL(2,-1) 
SELECT ISNULL(NULL,-1)

CREATE FUNCTION liczba_sztuk2(@kategoria VARCHAR(max)) RETURNS INT
AS
BEGIN
    DECLARE @wynik FLOAT
    RETURN ISNULL((SELECT SUM(Quantity) 
                FROM Categories C JOIN Products P ON C.CategoryID=P.CategoryID  
                JOIN [Order Details] OD ON P.ProductID=OD.ProductID
                WHERE CategoryName = @kategoria), 0)
END

SELECT dbo.liczba_sztuk2('Beverages')
SELECT dbo.liczba_sztuk2('ryby')

---------------------------------------------------------------------------------
-- Algorytm na prawdzanie numeru PESEL
-- PESEL 44051014582 - nie ok
-- PESEL 44051014586 - jest ok
-- trzeba rozmiæ na osobne cyfry 4,4,0,5,1,1,4,5,8,2
-- 4*1 = 4
-- 4*3 = 12
-- 0*7 = 0
-- 5*9 = 45
-- 1*1 = 1
-- 0*3 = 0
-- 1*7 = 7
-- 4*9 = 36
-- 5*1 = 5
-- 8*3 = 24
-- 2=c
-- suma= 134
-- m = suma % 10 = 4
-- if (c = 10-m) TRUE jest PESEL OK

ALTER FUNCTION czy_pesel(@pesel CHAR(11)) RETURNS INT
AS
BEGIN
    DECLARE @suma INT, @m INT, @wynik TINYINT
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
    IF (CAST(SUBSTRING(@pesel,11,1) AS INT)=10-@m)
        SET @wynik=1
    ELSE
        SET @wynik=0
    RETURN @wynik
END

SELECT dbo.czy_pesel('44051014582')
SELECT dbo.czy_pesel('44051014586')

--lepsza wersja

ALTER FUNCTION czy_pesel2(@pesel CHAR(11)) RETURNS INT
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
    IF (CAST(SUBSTRING(@pesel,11,1) AS INT)=10-@m)
        SET @wynik=1
    RETURN @wynik
END

SELECT dbo.czy_pesel2('44051014582')
SELECT dbo.czy_pesel2('44051014586')

-- co siê stanie , gdy numer bêdzie za krótki,czy za d³ugi? - Wrzuciæ IF'a, jeœli nie jest 11 znaków to @wynik=0
-- co jeœ³i ktoœ zamiast 0 wpisze O: - uzupe³niæ kod, ¿eby wynik by³ poprawny czyli @wynik=0, a nie error np. ISNUMERIC
SELECT dbo.czy_pesel2('44051O14586')

SELECT dbo.czy_pesel2('44051014582')
SELECT dbo.czy_pesel2('49040501580') -- ten pesel jest poprawny, a funkcja zwraca b³¹d, dzieje siê
---tak gdy cyfra kontrolna równa siê 0!, trzeba to poprawiæ

-- szczególny przypadek
-- 2022-02-22, PESEL: 22222222222
SELECT dbo.czy_pesel2('22222222222')--technicznie poprawny 

--***************************************************************************************************
--***************************************************************************************************

--------------------------------FUNKCJE WEKOTOROWE (TABLICOWE)---------------------------------------

-- napisaæ funkcjê zwracaj¹c¹ dane wszystkich matek (z bazy studenci)
-- przy funkcjach tablicowych nie wykorzystujemy BEGIN END jako deklaracji cia³a funkcji

ALTER FUNCTION show_matki() RETURNS TABLE
AS
    RETURN (SELECT * FROM studenci WHERE plec='K')

SELECT * FROM dbo.show_matki()

-- napisaæ funkcje zwracaj¹c¹ dane osob mieszkaj¹cych w podanym par. mieœcie

CREATE FUNCTION show_osoby_z_miasta(@miasto VARCHAR(200)) RETURNS TABLE
AS
    RETURN (SELECT * FROM studenci WHERE miasto=@miasto)

SELECT * FROM dbo.show_osoby_z_miasta('Katowice')

-- funkcje wektorowe (tabelaryczne s¹ tylko MS SQL, np. w MySQL ich nie ma, s¹ tylko skalarne)
-- ró¿nica miêdzy widokiem a funkcj¹ wektorow¹ - do widoku nie mo¿emy przekazaæ parametru!

SELECT * FROM dbo.show_osoby_z_miasta('Szczecin')

SELECT nazwisko,liczba_dzieci FROM show_osoby_z_miasta('Katowice') -- nie trzeba dbo.!
-- musimy pilnowaæ, ¿eby nazwy parametru by³y ró¿ne od nazwy atrybutów (kolumn) tabeli!

--EXCELEM mo¿emy bezpoœrednio ³¹czyæ siê z baz¹ danych, przeliczyæ i obrobiæ dane, a nastêpnie
--z powrotem zapisaæ do bazy danych. (Jest te¿ POWER VI) - nie trzeba pisaæ dziêki temu specjalnych aplikacji

---------------------------Prechodzimy do NorthWind---------------------------------------

-- napisaæ funkcje która zwraca dane o zamowieniach klienta (CompanyName) podanego parametrem
-- interesuje nas nazwy produktów i nazwy ich kategorii

SELECT * FROM Customers

SELECT ProductName, CategoryName FROM Customers C JOIN Orders O ON C.CustomerID=O.CustomerID
JOIN [Order Details] OD ON O.OrderID=OD.OrderID 
JOIN Products P ON OD.ProductID=P.ProductID
JOIN Categories CA ON P.CategoryID=CA.CategoryID
WHERE CompanyName='Alfreds Futterkiste'

SELECT ProductName, CategoryName FROM Customers C JOIN Orders O ON C.CustomerID=O.CustomerID
JOIN [Order Details] OD ON O.OrderID=OD.OrderID 
JOIN Products P ON OD.ProductID=P.ProductID
JOIN Categories CA ON P.CategoryID=CA.CategoryID
WHERE CompanyName='Comércio Mineiro'
-- uwaga  w wierszu 5,6 pojawia siê duplikat dlatego musimy u¿yæ DISTINCT

SELECT DISTINCT ProductName, CategoryName FROM Customers C JOIN Orders O ON C.CustomerID=O.CustomerID
JOIN [Order Details] OD ON O.OrderID=OD.OrderID 
JOIN Products P ON OD.ProductID=P.ProductID
JOIN Categories CA ON P.CategoryID=CA.CategoryID
WHERE CompanyName='Comércio Mineiro'

CREATE FUNCTION produkty_klient(@klient VARCHAR(200)) RETURNS TABLE
AS
RETURN SELECT DISTINCT ProductName, CategoryName FROM Customers C JOIN Orders O ON C.CustomerID=O.CustomerID
JOIN [Order Details] OD ON O.OrderID=OD.OrderID 
JOIN Products P ON OD.ProductID=P.ProductID
JOIN Categories CA ON P.CategoryID=CA.CategoryID
WHERE CompanyName=@klient --ORDER BY 1 --nie mo¿na u¿ywaæ order by ani z with nie mo¿na order by
                                     -- mogê tylko wyœwietlaj¹c t¹ funkcjê

SELECT * FROM produkty_klient('Comércio Mineiro') ORDER BY 2 -- tu wolno

-- gdy nie do koñca namy nazwê klienta to

ALTER FUNCTION produkty_klient2(@klient VARCHAR(200)) RETURNS TABLE
AS
RETURN SELECT DISTINCT ProductName, CategoryName, CompanyName FROM Customers C JOIN Orders O ON C.CustomerID=O.CustomerID
JOIN [Order Details] OD ON O.OrderID=OD.OrderID 
JOIN Products P ON OD.ProductID=P.ProductID
JOIN Categories CA ON P.CategoryID=CA.CategoryID
WHERE CompanyName LIKE @klient

SELECT * FROM produkty_klient2('%Comércio%') ORDER BY 2
-- distinct dotyczy ca³ego wiersza (ca³ego rekordu) czyli w rekordzie wszystkie atrybuty w dwóch
-- wierszach musz¹ byæ takie same, wtedy wywala ten rekord, czyli im wiêcej atrybutów za distinct
-- tym mniejsze prawdopodobieñstwo, ¿e rekord zostanie usuniêty.

--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--!!!!!!!!!!!!!!!!!!!!!!!!!! PROCEDURY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- procedury coœ wykonuj¹ ale nic nie zwraca

CREATE PROCEDURE proc1 --tutaj podobnie jak w funkcjach tabelarycznych nie ma BEGIN/END
AS
SELECT * FROM studenci

--sposoby wywo³ywania procedury
EXECUTE proc1
EXEC proc1
proc1-- tylko wtedy, gdy w instrukcji poprzedzja¹cej nie by³o ju¿ jej wykonania, st¹d u¿ywamy EXEC lub EXECUTE

-- napisaæ procedurê dodaj¹c¹ po jednym dziecku osobom mieszkaj¹cym w katowicach, wyœwietliæ dane przed i po

ALTER PROCEDURE dodaj_dziecko
AS
SELECT * FROM studenci WHERE miasto='Katowice'
UPDATE studenci SET liczba_dzieci=liczba_dzieci+1 WHERE miasto='Katowice'
SELECT * FROM studenci WHERE miasto='Katowice'

EXEC dodaj_dziecko

-- procedury mog¹ przyjmowaæ parametry
-- napisaæ procedurê dodaj¹cym po jednym dziecku osbom miszkaj¹cym w mieœcie o podanym parametrze

ALTER PROCEDURE dodaj_dziecko2 @miasto VARCHAR(200) -- w procedurze parametr jest bez nawiasu
ALTER PROCEDURE dodaj_dziecko2 @miasto VARCHAR(200) -- w procedurze parametr jest bez nawiasu
AS
SELECT * FROM studenci WHERE miasto=@miasto
UPDATE studenci SET liczba_dzieci=liczba_dzieci+1 WHERE miasto=@miasto
SELECT * FROM studenci WHERE miasto=@miasto

EXEC dodaj_dziecko2 'Krakow'

-- napisaæ proc podaj¹c¹ 'n' dzieci osobom mieszkajacym w miescie - parametr
-- max liczba dodawanych dzieci =5
-- jak poinformowaæ u¿ytkownika, ¿e poda³ parametr spoza zakresu?

ALTER PROCEDURE dodaj_n_dzieci @miasto VARCHAR(200), @dzieci INT
AS
IF @dzieci<=5
    BEGIN
        SELECT * FROM studenci WHERE miasto=@miasto
        UPDATE studenci SET liczba_dzieci=liczba_dzieci+@dzieci WHERE miasto=@miasto
        SELECT * FROM studenci WHERE miasto=@miasto
    END
ELSE 
    SELECT 'Poda³eœ za du¿o dzieci do dodania - makymalnie moze byæ 5'

EXEC dodaj_n_dzieci 'Chorzow', 0

CREATE PROCEDURE dodaj_n_dzieci2 @miasto VARCHAR(200), @dzieci INT
AS
IF @dzieci<=5
    BEGIN
        SELECT * FROM studenci WHERE miasto=@miasto
        UPDATE studenci SET liczba_dzieci=liczba_dzieci+@dzieci WHERE miasto=@miasto
        SELECT * FROM studenci WHERE miasto=@miasto
    END
ELSE 
    BEGIN
        RAISERROR('Poda³eœ za du¿o dzieci do dodania - makymalnie moze byæ 5',16,1)
        -- 16-poziom (nie wiêksze od 18, bo wiêksze to fatal error), 1- stan (wyœwietlane w komunikacie b³êdu)
        RETURN -1
    END

EXEC dodaj_n_dzieci2 'Chorzow', 20

EXEC SP -- pojawia siê mnóstwo wbudowanych procedur systemowych
EXEC sp_addlogin -- np dodawanie nowego u¿ytkownika

EXEC sp_configure --pokazuje niektóre parametry serwera bazodanowego,najpierw ustawiam (config_value) a 
                  --dopiero potem mówiê serwerowi, ¿e z t¹ wartoœciom ma dzia³aæ (run_value)

EXEC sp_configure 'show advanced options', 1
EXEC sp_configure
RECONFIGURE
EXEC sp_configure -- teraz pokaza³o siê namo wiele wiêcej weirszy - microsoft ukrywa parametry zaawansowane
-- np. xp_cmdshell - stawiaj¹c 1 (true) pozwala uruchamiaæ zewnêtrzn¹ aplikacjê

-----------------------********************************-------------------------------------
----------------------          WYZWALACZ (TRIGGER) -----------------------------------------
---------------------- sam bêdzie uruchamia³ w okreœlonych warunkach -----------------------

--CREATE TRIGGER [nazwa]
--ON [tabela/widok]
--FOR INSERT | UPDATE | DELETE
--AS
--[cia³o wyzwalacza]

-- napisaæ wyzwalacz reaguj¹cy tekstem na dopisanie nowego studenta do dabeli studenci

CREATE TRIGGER dopisanie1
ON studenci
FOR INSERT
AS
PRINT 'Dopisano nowego studenta'

INSERT INTO studenci (nazwisko) VALUES ('abc')
INSERT INTO studenci (nazwisko) VALUES ('abc'), ('efg'), ('hij') -- wyzwoli to tylko jeden trigger
                                                                 -- mimo i¿ dopisaliœmy 3 rekordy
SELECT * FROM studenci

ALTER TRIGGER dopisanie2
ON studenci
FOR INSERT
AS
SELECT * FROM inserted
SELECT * FROM deleted

INSERT INTO studenci (nazwisko) VALUES ('xtz')

--uswamy rekordy i reagujemy wyzwalaczem

ALTER TRIGGER usuwanie1
ON studenci
FOR DELETE
AS
SELECT * FROM inserted
SELECT * FROM deleted

-- w delete nie u¿ywamy * bo usuwamy ca³y wiersz!!! -odejmuje punkty za zadanie!!
DELETE FROM studenci WHERE nazwisko='xtz'

SELECT * FROM studenci

CREATE TRIGGER zmiana1
ON studenci
FOR UPDATE
AS
SELECT * FROM inserted
SELECT * FROM deleted

UPDATE studenci SET liczba_dzieci=liczba_dzieci+1 WHERE miasto='Katowice'
-- deleted jest wype³niania starymi wartoœciami a inserted jest wype³niane nowymi wartoœciami.
-- deleted i inserted to tabele systemowe (1 insert i 1 delete) dostepne z poziomu wyzwalaczy
-- dopiero po tym wykonywane jest fizyczne zapisanie/usuniêcie w tabeli docelowej.
-- po zakoñczeniu wyzwalacz te tabele s¹ usuwane

-- napisaæ wyzwalacz który nie pozwoli na dopisanie studenta o nazwisku 'iksinski'
--(wiemy ¿e dane , które chcemy dopisaæ bêd¹ l¹dowa³y w inserted)

CREATE TRIGGER nie_iksinski
ON studenci
FOR INSERT
AS
IF ((SELECT COUNT(*) FROM inserted WHERE nazwisko='iksinski') >0)
    BEGIN
        PRINT('Nie dopisujemy iksinskich')
        ROLLBACK -- cofiemy transakcje
    END
-- gdy if nie bêdzie spe³niony to wykona siê transakcja dodanie

INSERT INTO studenci (nazwisko) VALUES ('abacki') , ('dabacki'), ('cacaki')
--nowy rekord nie koniecznie musi znaleŸæ siê na koñcu
SELECT * FROM studenci

INSERT INTO studenci (nazwisko) VALUES ('abacki') , ('dabacki'), ('cacaki'), ('iksinski')
-- przez iksinskiego nie dopisa³ pozosta³ych trzech nowych studentow, poniewa¿ tych czworo nowych
-- studentów by³o w jednej transakcji, a poniewa¿ by³a ona odrzucona, wiêc nie dopisano ¿adnego

-- napisaæ wyzwalacz który uniemo¿liwi usuniêcie wiêcej jak dwóch rekordów z tabeli studenci
-- bardzo przydatne z powodów bezpieczeñstwa!!!!

CREATE TRIGGER usuwanie_blok
ON studenci
FOR DELETE
AS
IF ((SELECT COUNT(*) FROM DELETED) >2)
    BEGIN
        PRINT 'Za du¿o usuwasz'
        ROLLBACK
    END

DELETE FROM studenci WHERE imie IS NULL

SELECT * FROM studenci

DELETE FROM studenci WHERE nazwisko='hij' 

-------------------------------------------------------------------
-- teraz wylaczamy przygotowany wyzwalacz
DISABLE TRIGGER usuwanie_blok ON studenci
-- robimy co mamy zrobiæ (czyli usuwamy tyle wierszy ile chcemy)
ENABLE TRIGGER usuwanie_blok ON studenci
-- z powrotem przywracamy wyzwalacz

-----------------------------------------------------------------------
--oprócz walidacji numeru pesel (sprawdzenie jego poprawnoœci) sprawdzamy tak¿e czy dane z pesela
--pasuj¹ do daty urodzeni i p³ci, je¿eli pasuje to dopisujê a jeœeli nie to cofam transakcjê
--wykorzystujê do tego triggera!!!!!!

-- Generalnie powinniœmy robiæ wszystko, ¿eby nie dopisaæ do bazy jakiœ nieprawdziwych danych (œmieci)
-- bo usuwanie z du¿ych baz danych to problem i zawsze mo¿e pojawiæ siê gdzieœ w któreœ tabeli jakiœ
-- nie usuniêty element
-- Baza nie powinna pozwalaæ na wprowadzanie i trzymanie nie prawdziwych danych, bo
-- przy uczeniu maszynowym póŸniej nie musimy traciæ czasu na przygotowanie danych

DISABLE TRIGGER usuwanie_blok ON studenci
DISABLE TRIGGER usuwanie_1 ON studenci

--- dodajê now¹ kolumnê
ALTER TABLE studenci ADD usunieto VARCHAR(2)
SELECT * FROM studenci
-- dodajê klucz primary (podstawowy)
ALTER TABLE studenci ADD id_studenta int primary key identity
SELECT * FROM studenci

CREATE TRIGGER usuwanie3
ON studenci
INSTEAD OF DELETE
AS
UPDATE studenci SET usunieto='*' WHERE id_studenta IN (SELECT id_studenta FROM deleted)

SELECT * FROM studenci
DELETE FROM studenci WHERE liczba_dzieci=0
SELECT * FROM studenci

------------------------------------
--- tworzenie dokumentu XML'owego z tabeli baz danych
SELECT * FROM studenci FOR XML PATH

-- tworzenie json
SELECT * FROM studenci FOR JSON PATH

