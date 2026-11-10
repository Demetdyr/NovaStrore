-- BÖLÜM 1: Veri Tabanı Tasarımı (Logical Design ve DDL)

-- 1. Veri Tabanı Oluşturma: NovaStoreDB
USE master;
GO

IF DB_ID('NovaStoreDB') IS NOT NULL
BEGIN
    ALTER DATABASE NovaStoreDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NovaStoreDB;
END
GO

CREATE DATABASE NovaStoreDB COLLATE Turkish_CI_AS;
GO

USE NovaStoreDB;
GO

-- 2.A Tablo: Categories (Kategoriler)
CREATE TABLE Categories
(
    CategoryID   INT IDENTITY(1,1) CONSTRAINT PK_Categories PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);
GO

-- 2.B Tablo: Products (Ürünler)
CREATE TABLE Products
(
    ProductID   INT IDENTITY(1,1) CONSTRAINT PK_Products PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2),
    Stock       INT CONSTRAINT DF_Products_Stock DEFAULT 0,
    CategoryID  INT CONSTRAINT FK_Products_Categories FOREIGN KEY REFERENCES Categories (CategoryID)
);
GO

-- 2.C Tablo: Customers (Müşteriler)
CREATE TABLE Customers
(
    CustomerID INT IDENTITY(1,1) CONSTRAINT PK_Customers PRIMARY KEY,
    FullName   VARCHAR(50),
    City       VARCHAR(20),
    Email      VARCHAR(100) CONSTRAINT UQ_Customers_Email UNIQUE
);
GO

-- 2.D Tablo: Orders (Siparişler)
CREATE TABLE Orders
(
    OrderID     INT IDENTITY(1,1) CONSTRAINT PK_Orders PRIMARY KEY,
    CustomerID  INT CONSTRAINT FK_Orders_Customers FOREIGN KEY REFERENCES Customers (CustomerID),
    OrderDate   DATETIME CONSTRAINT DF_Orders_OrderDate DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2)
);
GO

-- 2.E Tablo: OrderDetails (Sipariş Detayları - Ara Tablo)
CREATE TABLE OrderDetails
(
    DetailID  INT IDENTITY(1,1) CONSTRAINT PK_OrderDetails PRIMARY KEY,
    OrderID   INT CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY REFERENCES Orders (OrderID),
    ProductID INT CONSTRAINT FK_OrderDetails_Products FOREIGN KEY REFERENCES Products (ProductID),
    Quantity  INT
);
GO


-- BÖLÜM 2: Veri Girişi (DML - Insert)

-- Görev 1: 5 adet kategori ekleme
INSERT INTO Categories (CategoryName)
VALUES
    ('Elektronik'),
    ('Giyim'),
    ('Kitap'),
    ('Kozmetik'),
    ('Ev ve Yaşam');
GO

-- Görev 2: Her kategoriye ait toplam 13 ürün ekleme
INSERT INTO Products (ProductName, Price, Stock, CategoryID)
VALUES
    ('Akıllı Telefon',     24999.90, 15, 1),
    ('Kablosuz Kulaklık',   1899.50, 45, 1),
    ('Dizüstü Bilgisayar', 38999.00,  8, 1),
    ('Erkek Kot Pantolon',   899.90, 60, 2),
    ('Kadın Trençkot',      2499.00, 12, 2),
    ('Spor Ayakkabı',       1749.99, 30, 2),
    ('Suç ve Ceza',          165.00, 18, 3),
    ('Simyacı',              120.00, 75, 3),
    ('Nemlendirici Krem',    349.90, 40, 4),
    ('Parfüm',              1299.00,  5, 4),
    ('Kahve Makinesi',      3499.00, 10, 5),
    ('Nevresim Takımı',      749.90, 25, 5);

INSERT INTO Products (ProductName, Price, CategoryID)
VALUES ('Akıllı Saat', 6499.00, 1);
GO

-- Görev 3: 6 adet müşteri kaydı oluşturma
INSERT INTO Customers (FullName, City, Email)
VALUES
    ('Ahmet Yılmaz',  'İstanbul',  'ahmet.yilmaz@example.com'),
    ('Ayşe Demir',    'Ankara',    'ayse.demir@example.com'),
    ('Mehmet Kaya',   'İzmir',     'mehmet.kaya@example.com'),
    ('Zeynep Çelik',  'Bursa',     'zeynep.celik@example.com'),
    ('Can Şahin',     'Antalya',   'can.sahin@example.com'),
    ('Elif Arslan',   'Eskişehir', 'elif.arslan@example.com');
GO

-- Görev 4: Farklı tarihlerde 11 sipariş ve bu siparişlere ait sipariş detayları
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
VALUES
    (1, '2026-06-03T10:15:00', 26899.40),
    (2, '2026-06-18T14:40:00',  3798.00),
    (3, '2026-07-05T09:20:00', 38999.00),
    (1, '2026-07-22T19:05:00',   450.00),
    (4, '2026-08-09T11:30:00',  1799.60),
    (5, '2026-08-27T16:45:00',  3549.79),
    (2, '2026-09-14T13:10:00',  3499.00),
    (3, '2026-10-02T08:55:00',  4159.00),
    (1, '2026-10-19T21:25:00',  3848.90),
    (4, '2026-11-01T12:00:00',  1464.00);

INSERT INTO Orders (CustomerID, TotalAmount)
VALUES (5, 240.00);

INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
VALUES
    (1,  1,  1),
    (1,  2,  1),
    (2,  5,  1),
    (2,  10, 1),
    (3,  3,  1),
    (4,  7,  2),
    (4,  8,  1),
    (5,  9,  3),
    (5,  12, 1),
    (6,  6,  1),
    (6,  4,  2),
    (7,  11, 1),
    (8,  2,  2),
    (8,  8,  3),
    (9,  11, 1),
    (9,  9,  1),
    (10, 10, 1),
    (10, 7,  1),
    (11, 8,  2);
GO


-- BÖLÜM 3: Sorgulama ve Analiz (DQL - Select ve Joins)

-- Soru 1 (Temel Listeleme): Stoğu 20'den az olan ürünler, stok miktarına göre azalan sırada
SELECT
    ProductName AS UrunAdi,
    Stock       AS StokAdedi
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;
GO

-- Soru 2 (Veri Birleştirme - JOIN): Hangi müşteri, hangi tarihte sipariş vermiş
SELECT
    Customer.FullName         AS MusteriAdi,
    Customer.City             AS Sehir,
    CustomerOrder.OrderDate   AS SiparisTarihi,
    CustomerOrder.TotalAmount AS ToplamTutar
FROM Customers AS Customer
INNER JOIN Orders AS CustomerOrder
    ON CustomerOrder.CustomerID = Customer.CustomerID
ORDER BY CustomerOrder.OrderDate;
GO

-- Soru 3 (Çoklu Birleştirme): Ahmet Yılmaz'ın aldığı ürünlerin isimleri, fiyatları ve kategorileri
SELECT
    Product.ProductName   AS UrunAdi,
    Product.Price         AS Fiyat,
    Category.CategoryName AS KategoriAdi
FROM Customers AS Customer
INNER JOIN Orders AS CustomerOrder
    ON CustomerOrder.CustomerID = Customer.CustomerID
INNER JOIN OrderDetails AS OrderDetail
    ON OrderDetail.OrderID = CustomerOrder.OrderID
INNER JOIN Products AS Product
    ON Product.ProductID = OrderDetail.ProductID
INNER JOIN Categories AS Category
    ON Category.CategoryID = Product.CategoryID
WHERE Customer.FullName = 'Ahmet Yılmaz'
ORDER BY CustomerOrder.OrderDate, Product.ProductName;
GO

-- Soru 4 (Gruplama ve Aggregate Fonksiyonlar): Hangi kategoride toplam kaç adet ürün var
SELECT
    Category.CategoryName    AS KategoriAdi,
    COUNT(Product.ProductID) AS UrunSayisi,
    Category.CategoryName + ' - '
        + CAST(COUNT(Product.ProductID) AS VARCHAR(10)) + ' ürün' AS KategoriOzeti
FROM Categories AS Category
LEFT JOIN Products AS Product
    ON Product.CategoryID = Category.CategoryID
GROUP BY Category.CategoryName
ORDER BY UrunSayisi DESC, KategoriAdi;
GO

-- Soru 5 (Ciro Analizi): Her müşterinin toplam cirosu, en çok harcama yapandan en aza doğru
SELECT
    Customer.FullName                         AS MusteriAdi,
    COUNT(CustomerOrder.OrderID)              AS SiparisSayisi,
    ISNULL(SUM(CustomerOrder.TotalAmount), 0) AS ToplamCiro
FROM Customers AS Customer
LEFT JOIN Orders AS CustomerOrder
    ON CustomerOrder.CustomerID = Customer.CustomerID
GROUP BY Customer.CustomerID, Customer.FullName
ORDER BY ToplamCiro DESC;
GO

-- Soru 6 (Zaman Analizi): Bugünün tarihine göre siparişlerin üzerinden geçen gün sayısı
SELECT
    OrderID                              AS SiparisNo,
    OrderDate                            AS SiparisTarihi,
    DATEDIFF(DAY, OrderDate, GETDATE())  AS GecenGunSayisi
FROM Orders
ORDER BY OrderDate;
GO


-- BÖLÜM 4: İleri Seviye Veri Tabanı Nesneleri

-- 1. View Oluşturma: vw_SiparisOzet
CREATE VIEW vw_SiparisOzet
AS
SELECT
    Customer.FullName       AS MusteriAdi,
    CustomerOrder.OrderDate AS SiparisTarihi,
    Product.ProductName     AS UrunAdi,
    OrderDetail.Quantity    AS Adet
FROM Orders AS CustomerOrder
INNER JOIN Customers AS Customer
    ON Customer.CustomerID = CustomerOrder.CustomerID
INNER JOIN OrderDetails AS OrderDetail
    ON OrderDetail.OrderID = CustomerOrder.OrderID
INNER JOIN Products AS Product
    ON Product.ProductID = OrderDetail.ProductID;
GO

SELECT
    MusteriAdi,
    SiparisTarihi,
    UrunAdi,
    Adet
FROM vw_SiparisOzet
ORDER BY SiparisTarihi, UrunAdi;
GO

-- 2. Yedekleme (Backup): NovaStoreDB veri tabanının C:\Yedek\ klasörüne yedeklenmesi
BACKUP DATABASE NovaStoreDB
TO DISK = 'C:\Yedek\NovaStoreDB.bak'
WITH INIT, NAME = 'NovaStoreDB Tam Yedek';
GO
