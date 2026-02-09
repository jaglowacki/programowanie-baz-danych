SELECT * FROM studenci

-- wyœwietliæ dane osob, ktore maja  od 1 do 3 dzieci

SELECT * FROM studenci WHERE liczba_dzieci IN (1,2,3)
SELECT * FROM studenci WHERE liczba_dzieci BETWEEN 1 AND 3
SELECT * FROM studenci WHERE liczba_dzieci>=1 AND liczba_dzieci<=3
SELECT * FROM studenci WHERE liczba_dzieci=1 OR liczba_dzieci=2 OR liczba_dzieci=3
SELECT * FROM studenci WHERE NOT (liczba_dzieci<1 OR liczba_dzieci>3)

-- wyœwietliæ dane najm³odszej osoby w tabeli

SELECT TOP 1 * FROM studenci ORDER BY data_urodzenia DESC  -- jak bêdzie wiêcej ni¿ jedna osoba o tej dacie
                                                           -- urodzenia to dostaniemy tylko jedn¹ sosbê!
SELECT * FROM studenci  -- w tym zapytaniu nie wiadomo w jakiej kolejnoœci pojawi¹ siê wyniki, je¿eli 
                        -- maj¹ t¹ sam¹ wartoœæ, to SQL wyœwieli je tak aby zrobiæ to jak najszybciej
                        -- w zwi¹zku z czym 2 rózne osoby mog¹ otrzymaæ ró¿ne wyniki
--NIE MO¯NA TWORZYÆ ZAPYTANIA, KTÓRE W DWÓCH WYKONANIACH TAKIEGO SAMEGO ZAPYTANIA MO¯E DAÆ DWA RÓ¯NE WYNIKI

SELECT MIN(data_urodzenia) FROM studenci -- osoba najm³odsza ma najwiêksz¹ liczbê dlatego musimy:

SELECT TOP 1 * FROM studenci ORDER BY data_urodzenia DESC -- Z£E (Sortowanie kosztowa³o a¿ 78%, bo muszê uporz¹dkowaæ ca³y zbiór!)
                                                          -- (a mnie interesuje tylko wartoœæ skrajna bez pozosta³ej reszty)
                                                          -- (Uporz¹dkowanie jest bardzo zasobo i czasoch³onne)
SELECT * FROM studenci WHERE data_urodzenia=
(SELECT MAX(data_urodzenia) FROM studenci)       -- TAK JEST DOBRZE!

-- kto bêdzie mia³ urodziny w przysz³ym miesi¹cu

SELECT * FROM studenci WHERE MONTH(data_urodzenia) LIKE 3 -- NIE! - bo nie pytam kto ma urodziny w marcu
                                                          -- ale pytam siê kot ma urodziny w przysz³ym misi¹cu
SELECT * FROM studenci WHERE MONTH(GETDATE())+1=MONTH(data_urodzenia) -- LE bo w grudniu bêdzie 13 i nie dostaniemy
                                                                      -- ¿adnego rekordu!
-- Nigdy nie wyci¹gaæ z daty liczby bo to zawsze siê kiedyœ wywali, tutaj dodawanie wywala 

SELECT * FROM studenci WHERE MONTH(DATEADD(mm,1,GETDATE()))=MONTH(data_urodzenia) -- TAK DOBRZE!!!!
-- do koñca trktujemy wszystko jako daty!!!

SELECT * FROM studenci WHERE nazwisko LIKE 'k%' --TAK
SELECT * FROM studenci WHERE nazwisko LIKE 'kowalski' --NIE (je¿eli znam onkretn¹ wartoœæ to nie powinieniem likowaæ)
SELECT * FROM studenci WHERE nazwisko='kowalski'

-- wysiwetliæ w jednej kolumnie nazwisko i imiê studenta

SELECT * , nazwisko+' '+imie AS 'N i I' FROM studenci -- Nie nale¿y (bo tak dzi³a tylko w microsoft'cie)
SELECT CONCAT(nazwisko,' ',imie) AS 'N i I' FROM studenci -- tak zadzia³a w ka¿dej bazie danych

-- wyœwitliæ info ile osób mieszka w poszczególnych miastach

SELECT miasto, COUNT(*) AS 'Liczba osób' FROM studenci GROUP BY miasto

-- których miastach mieszka tylko jedna matka

SELECT miasto, COUNT(*) AS 'Liczba matek' FROM studenci WHERE plec='K' AND liczba_dzieci>0
GROUP BY miasto having COUNT(*)=1
-----------------------------------------------------------------------------------------

SELECT * FROM studenci
SELECT miasto, plec, COUNT(*) AS 'Liczba osob' FROM studenci 
GROUP BY miasto, plec WITH CUBE --pojawi³y siê w Null pomimo, ¿e nie by³y w tabeli
                                -- tworzy wszystkie mo¿liwe kombinacje
--(podobnie jest w JOIN LEFT lub JOIN RIGHT - outer JOIN. jak chcemy zobaczyæ studentów bez ocen, to 
-- u¿ywamy outer joina)

SELECT miasto, plec, COUNT(*) AS 'Liczba osob' FROM studenci 
GROUP BY miasto, plec WITH ROLLUP -- tutaj nie ma null'a w mieœcie, cube daje wszystkie mo¿³iwe kombinacje,
                                  -- zaœ rollup uwzglêdnia kolejnoœæ: miasto, p³eæ

SELECT plec, miasto, COUNT(*) AS 'Liczba osob' FROM studenci 
GROUP BY miasto, plec WITH ROLLUP

-- jak samemu zadecydowaæ jakie grupy powstan¹?

SELECT miasto, plec, COUNT(*) AS 'Liczba osob' FROM studenci 
GROUP BY GROUPING SETS (miasto, plec)

SELECT miasto, plec, COUNT(*) AS 'Liczba osob' FROM studenci 
GROUP BY GROUPING SETS (miasto, plec, (miasto, plec))

SELECT miasto, plec, COUNT(*) AS 'Liczba osob' FROM studenci 
GROUP BY GROUPING SETS (miasto, plec, (miasto, plec), ()) --dosta³em to samo co w CUBE
-- s¹ to rozszerzenia SQL'a w kierunku analizy danych

------------------------------------------------------------------------------------------

-- wyœwietliæ osobê na drugim miejscu pod wzglêdem wieku (drug¹ najstarsz¹)

SELECT *, RANK() OVER (ORDER BY data_urodzenia) AS 'ranking wieku' FROM studenci
-- zwróæ uwagê na rekord 23,24, osoba 25 przeskakuje w rankingu

SELECT *, DENSE_RANK() OVER (ORDER BY data_urodzenia) AS 'ranking wieku' FROM studenci
-- tutaj kolejna osoba nie przeskakuje w rankingu

CREATE VIEW widok1 AS SELECT *, DENSE_RANK() OVER (ORDER BY data_urodzenia) AS 'ranking wieku' FROM studenci
SELECT * FROM widok1 WHERE [ranking wieku]=2 -- wad¹ rozwi¹zania jest tworzenie nowej struktury
-- nle¿y unikaæ generowania widoków, które s¹ tylko na chwilê, bo nik ich nie sprz¹ta i zaœmiecamy bazê danch
-- Trzeba robiæ tak (¿eby nie zostawiæ œladu):
-- CTE (robimy widok nie robi¹c widoku)
WITH tabela AS (SELECT imie,nazwisko,plec FROM studenci)
SELECT * FROM tabela -- powsta³ widok nie zapisany na sztywno - wywo³ywaæ £¥CZNIE

SELECT * FROM tabela -- powala tylko raz tak zrobiæ WITH tabela istnieje tylko do pierwszego wykorzystania!

--teraz wracaj¹c do rankingu
WITH tabela2 AS (SELECT *, DENSE_RANK() OVER (ORDER BY data_urodzenia) AS 'ranking wieku' FROM studenci)
SELECT * FROM tabela2

SELECT *, ROW_NUMBER() OVER (order by data_urodzenia) lp from studenci

-- uporz¹dkowaæ studentów po nazwisku, obliczyæ ró¿nicê liczby dzieci pomiêdzy kolejnymi osobami

SELECT *, LAG(liczba_dzieci, 1) OVER (ORDER BY nazwisko) FROM studenci
-- kolumne z przesuniêciem danego atrybutu o jeden rekord

SELECT *, LAG(liczba_dzieci, 1, -100) OVER (ORDER BY nazwisko) FROM studenci
-- trzeci parametr pozbywa sie NULL'a (zastêpuje NULL'a parametrem)

SELECT *, LAG(liczba_dzieci, 4, -100) OVER (ORDER BY nazwisko) FROM studenci
-- trzeci parametr pozbywa sie NULL'a

-- nie mogê jednak zrobiæ tak
SELECT *, LAG(liczba_dzieci, -1, -100) OVER (ORDER BY nazwisko) FROM studenci
--wtedy zatêpujemy to funkcj¹ LEAD:
SELECT *, LEAD(liczba_dzieci, 1, -100) OVER (ORDER BY nazwisko) FROM studenci

------------------------
SELECT *, SUM(liczba_dzieci) OVER (ORDER BY miasto ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)
FROM studenci -- suma rekordów jeden poprzedni i jeden nastêpny)

--OVER - s¹ to tzw. funkcje OKNOWE!

SELECT *, SUM(liczba_dzieci) OVER (ORDER BY miasto ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING)
FROM studenci 

SELECT *, SUM(liczba_dzieci) OVER (ORDER BY miasto ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
AS 'Suma bie¿¹ca' FROM studenci -- sum bie¿¹ca od pocz¹tku do bie¿¹cego rekordu


------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
--FUNKCJE
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

SELECT MONTH(data_urodzenia) FROM studenci -- funkcja wbudowana

SELECT DATENAME(month,getdate()) -- istotne jest typ argumentów oraz typ zwracanej wartoœci

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

