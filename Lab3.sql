CREATE TABLE DatabaseVersion (
    VersionId INT PRIMARY KEY,
    VersionNumber INT
);
INSERT INTO DatabaseVersion (VersionId, VersionNumber) VALUES (1, 1);

CREATE PROCEDURE ChangeColumnType
AS
BEGIN
    ALTER TABLE Customers
    ALTER COLUMN phone VARCHAR(50);
END;

CREATE PROCEDURE RevertChangeColumnType
AS
BEGIN
    ALTER TABLE Customers
    ALTER COLUMN phone VARCHAR(20);
END;

CREATE PROCEDURE AddColumn
AS
BEGIN
    ALTER TABLE Customers
    ADD age INT;
END;

CREATE PROCEDURE RemoveColumn
AS
BEGIN
    ALTER TABLE Customers
    DROP COLUMN age;
END;

CREATE PROCEDURE AddDefaultConstraint
AS
BEGIN
    ALTER TABLE Products
    ADD CONSTRAINT DF_StockQuantity DEFAULT 0 FOR stock_quantity;
END;

CREATE PROCEDURE RemoveDefaultConstraint
AS
BEGIN
    ALTER TABLE Products
    DROP CONSTRAINT DF_StockQuantity;
END;

CREATE PROCEDURE AddPrimaryKey
AS
BEGIN
    ALTER TABLE Customers
    ADD CONSTRAINT PK_CustomerID PRIMARY KEY (customer_id);
END;

CREATE PROCEDURE RemovePrimaryKey
AS
BEGIN
    ALTER TABLE Customers
    DROP CONSTRAINT PK_CustomerID;
END;

CREATE PROCEDURE AddCandidateKey
AS
BEGIN
    ALTER TABLE Products
    ADD CONSTRAINT UK_ProductName UNIQUE (name);
END;

CREATE PROCEDURE RemoveCandidateKey
AS
BEGIN
    ALTER TABLE Products
    DROP CONSTRAINT UK_ProductName; -- Removing candidate key constraint from 'name'
END;

CREATE PROCEDURE AddForeignKey
AS
BEGIN
    ALTER TABLE Purchase
    ADD CONSTRAINT FK_CustomerID FOREIGN KEY (customer_id) REFERENCES Customers(customer_id); -- Adding foreign key constraint to 'customer_id'
END;

CREATE PROCEDURE RemoveForeignKey
AS
BEGIN
    ALTER TABLE Purchase
    DROP CONSTRAINT FK_CustomerID; -- Removing foreign key constraint from 'customer_id'
END;

CREATE PROCEDURE CreateOrderDetailsTable
AS
BEGIN
    CREATE TABLE OrderDetails (
        OrderID INT PRIMARY KEY,
        ProductID INT,
        Quantity INT,
        TotalAmount DECIMAL(10, 2)
    );
END;

CREATE PROCEDURE DropOrderDetailsTable
AS
BEGIN
    DROP TABLE OrderDetails;
END;

CREATE PROCEDURE UpdateDatabaseVersion @VersionNumber INT
AS
BEGIN
    DECLARE @CurrentVersion INT;
    SELECT @CurrentVersion = VersionNumber FROM DatabaseVersion WHERE VersionId = 1;
    
    WHILE @CurrentVersion < @VersionNumber
    BEGIN
        IF @CurrentVersion = 1
        BEGIN
            EXEC ChangeColumnType;
            EXEC AddColumn;
            EXEC AddDefaultConstraint;
            EXEC AddPrimaryKey;
            EXEC AddCandidateKey;
            EXEC AddForeignKey;
            EXEC CreateOrderDetailsTable;
        END
        ELSE IF @CurrentVersion = 2
        BEGIN
            EXEC RevertChangeColumnType;
            EXEC RemoveColumn;
            EXEC RemoveDefaultConstraint;
            EXEC RemovePrimaryKey;
            EXEC RemoveCandidateKey;
            EXEC RemoveForeignKey;
            EXEC DropOrderDetailsTable;
        END
        
        SET @CurrentVersion = @CurrentVersion + 1;
        UPDATE DatabaseVersion SET VersionNumber = @CurrentVersion WHERE VersionId = 1;
    END;
END;
