-- Users table creation with sequence for FelhasznaloID
CREATE SEQUENCE FelhasznaloID_sequence START WITH 1 INCREMENT BY 1;
CREATE TABLE Felhasznalok (
    FelhasznaloID INT DEFAULT NEXT VALUE FOR FelhasznaloID_sequence PRIMARY KEY,
    Nev NVARCHAR(100),
    Email NVARCHAR(100) UNIQUE,
    RegisztracioDatuma DATE
);

-- Products table creation with sequence for TermekID
CREATE SEQUENCE TermekID_sequence START WITH 1 INCREMENT BY 1;
CREATE TABLE Termekek (
    TermekID INT DEFAULT NEXT VALUE FOR TermekID_sequence PRIMARY KEY,
    Nev NVARCHAR(100),
    Ar MONEY,
    KeszletMennyiseg INT
);

-- Orders table creation with sequence for RendelesID
CREATE SEQUENCE RendelesID_sequence START WITH 1 INCREMENT BY 1;
CREATE TABLE Rendelesek (
    RendelesID INT DEFAULT NEXT VALUE FOR RendelesID_sequence PRIMARY KEY,
    FelhasznaloID INT FOREIGN KEY REFERENCES Felhasznalok(FelhasznaloID),
    TermekID INT FOREIGN KEY REFERENCES Termekek(TermekID),
    RendelesekSzama INT,
    RendelesDatuma DATETIME
);

-- Insert data into the Users table
INSERT INTO Felhasznalok (Nev, Email, RegisztracioDatuma)
VALUES 
    ('Kovács Péter', 'kovacs.peter@example.com', '2023-05-10'),
    ('Nagy Anna', 'nagy.anna@example.com', '2023-07-15'),
    ('Kiss Gábor', 'kiss.gabor@example.com', '2023-09-20');

-- Insert data into the Products table
INSERT INTO Termekek (Nev, Ar, KeszletMennyiseg)
VALUES 
    ('Laptop', 120000, 10),
    ('Okostelefon', 80000, 15),
    ('Tablet', 60000, 20);

-- Insert data into the Orders table
INSERT INTO Rendelesek (FelhasznaloID, TermekID, RendelesekSzama, RendelesDatuma)
VALUES
    (1, 1, 2, '2024-02-28 10:15:00'),
    (2, 2, 1, '2024-03-01 14:30:00'),
    (3, 3, 3, '2024-03-02 09:45:00'),
    (1, 2, 1, '2024-03-10 20:35:00'),
    (1, 3, 2, '2024-03-15 12:25:00'),
    (2, 1, 5, '2024-03-20 10:10:00');

-- "All Users"
SELECT * FROM Felhasznalok;

-- "Products and Prices"
SELECT Nev, Ar FROM Termekek ORDER BY Ar ASC;

-- "Latest 3 Orders"
SELECT TOP 3 * FROM Rendelesek ORDER BY RendelesDatuma DESC;

-- "Users, Orders, Ordered Products, Remaining Stock and Total Price"
SELECT f.Nev AS UserName,
       COUNT(DISTINCT r.RendelesID) AS NumOrders,
       SUM(r.RendelesekSzama) AS TotalOrderedProducts,
       t.Nev AS ProductName,
       t.KeszletMennyiseg - SUM(r.RendelesekSzama) AS RemainingStock,
       SUM(r.RendelesekSzama) * t.Ar AS TotalPrice
FROM Felhasznalok f
JOIN Rendelesek r ON f.FelhasznaloID = r.FelhasznaloID
JOIN Termekek t ON r.TermekID = t.TermekID
GROUP BY f.FelhasznaloID, t.Nev, t.Ar, t.KeszletMennyiseg, f.Nev
ORDER BY TotalPrice DESC;

--Update Termekek table
UPDATE Termekek
SET KeszletMennyiseg = KeszletMennyiseg - (
    SELECT SUM(RendelesekSzama)
    FROM Rendelesek
    WHERE Rendelesek.TermekID = Termekek.TermekID
)
WHERE TermekID IN (
    SELECT TermekID
    FROM Rendelesek
);

--Updated table queries
SELECT t.KeszletMennyiseg as ItemsLeft, t.Nev as ItemName 
From Termekek t
ORDER BY ItemsLeft DESC;

