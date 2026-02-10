--ZADANIE 3.2
--Na podstawie bazy Northwind-napisaæ funkcjê zwracaj¹c¹ wartoœæ sprzeda¿y towarów w podanych parametrami: 
--kategorii i nazwie klienta. Funkcja nigdy nie powinna zwracaæ wartoœci Null


USE Northwind

SELECT SUM(OD.UnitPrice * OD.Quantity) FROM Customers C 
JOIN Orders O ON C.CustomerID=O.CustomerID
JOIN [Order Details] OD ON O.OrderID=OD.OrderID
JOIN Products P ON OD.ProductID=P.ProductID
JOIN Categories CAT ON P.CategoryID=CAT.CategoryID
WHERE C.CompanyName='Antonio Moreno Taquería' AND CAT.CategoryName='Beverages'

SELECT C.CompanyName, CAT.CategoryName, OD.UnitPrice * OD.Quantity AS 'Wart.sprz.' 
FROM Customers C 
JOIN Orders O ON C.CustomerID=O.CustomerID
JOIN [Order Details] OD ON O.OrderID=OD.OrderID
JOIN Products P ON OD.ProductID=P.ProductID
JOIN Categories CAT ON P.CategoryID=CAT.CategoryID
WHERE C.CompanyName='Antonio Moreno Taquería' AND CAT.CategoryName='Beverages'

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

SELECT dbo.sprzedaz_klient_kategoria('Antonio Moreno Taquería','Beverages')