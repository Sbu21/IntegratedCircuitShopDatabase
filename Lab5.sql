CREATE TABLE Ta (
    aid INT PRIMARY KEY,
    a2 INT UNIQUE,
    a3 INT
);

CREATE TABLE Tb (
    bid INT PRIMARY KEY,
    b2 INT
);

CREATE TABLE Tc (
    cid INT PRIMARY KEY,
    aid INT,
    bid INT,
    FOREIGN KEY (aid) REFERENCES Ta(aid),
    FOREIGN KEY (bid) REFERENCES Tb(bid)
);

-- 1. Clustered Index Scan

SELECT a3
FROM Ta
WHERE aid = 12

-- 2. Clustered Index Seek

SELECT a3
FROM Ta
WHERE aid between 7 and 18

-- 3. Non-Clustered Index Scan

SELECT a2
FROM Ta

-- 4. Non-Clustered Index Seek

SELECT a2
FROM Ta
WHERE a2 > 5

-- 5. Key Look-Up

SELECT a2, a3
FROM Ta
WHERE a2 = 11

B.
SELECT * FROM Tb WHERE b2 = 100;

CREATE INDEX IX_b2 ON Tb(b2);

SELECT * FROM Tb WHERE b2 = 100;

C.
CREATE VIEW MyView AS
SELECT Ta.aid, Ta.a2, Tb.bid, Tb.b2
FROM Ta
JOIN Tc ON Ta.aid = Tc.aid
JOIN Tb ON Tc.bid = Tb.bid;
