SET NOCOUNT ON;

CREATE FUNCTION RandIntBetween(@lower INT, @upper INT, @rand FLOAT)
RETURNS INT
AS
BEGIN
  DECLARE @result INT;
  DECLARE @range INT = @upper - @lower + 1;
  SET @result = FLOOR(@rand * @range + @lower);
  RETURN @result;
END
GO

IF EXISTS (SELECT [name] FROM sys.objects 
            WHERE object_id = OBJECT_ID('RandIntBetween'))
BEGIN
   DROP FUNCTION RandIntBetween;
END
GO


CREATE PROCEDURE deleteDataFromTable
    @TableName NVARCHAR(50)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = 'DELETE FROM ' + QUOTENAME(@TableName);
    EXEC sp_executesql @SQL;
END;
GO

CREATE PROC deleteData
@table_id INT
AS
BEGIN
	-- we get the table name
	DECLARE @table_name NVARCHAR(50) = (
		SELECT [Name] FROM [Tables] WHERE TableID = @table_id
	)

	-- we declare the function we are about to execute
	DECLARE @function NVARCHAR(MAX)
	-- we set the function
	SET @function = N'DELETE FROM ' + @table_name
	PRINT @function
	-- we execute the function
	EXEC sp_executesql @function
END
GO


CREATE OR ALTER PROC deleteDataFromAllTables
@test_id INT
AS
BEGIN
	DECLARE @tableID INT
	DECLARE cursorForDelete cursor local for
		SELECT TT.TableID
		FROM TestTables TT
			INNER JOIN Tests T ON TT.TestID = T.TestID
		WHERE T.TestID = @test_id
		ORDER BY TT.Position DESC

	OPEN cursorForDelete
	FETCH cursorforDelete INTO @tableID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		exec deleteDataFromTable @tableID

		FETCH NEXT FROM cursorForDelete INTO @tableID
	END
	CLOSE cursorForDelete
END


CREATE OR ALTER PROC insertDataIntoPerson
@nrOfRows INT,
@tableName VARCHAR(50)
AS
BEGIN
	DECLARE @FirstName VARCHAR(50)
    DECLARE @LastName VARCHAR(50)
    DECLARE @Address VARCHAR(255)
    DECLARE @Email VARCHAR(100)
    DECLARE @Phone VARCHAR(20)
	WHILE @nrOfRows > 0
	BEGIN
		SET @FirstName = (SELECT CHOOSE( CAST(RAND()*(10)+1 AS INT),'Djokovic','Tsitsipas','Thiem','Fognini', 'Medvevev','Kyrgios','Murray','Bautista-Agut','Nadal','Federer'))
		SET @LastName = (SELECT CHOOSE( CAST(RAND()*(10)+1 AS INT),'a','b','c','d', 'e','f','g','h','i','j'))
		SET @Address = (SELECT CHOOSE( CAST(RAND()*(10)+1 AS INT),'a','b','c','d', 'e','f','g','h','i','j'))
		SET @Email = (SELECT CHOOSE( CAST(RAND()*(10)+1 AS INT),'a','b','c','d', 'e','f','g','h','i','j'))
		SET @Phone = (SELECT CHOOSE( CAST(RAND()*(10)+1 AS INT),'1','2','3','4','5','6','7','8','9','10'))
	INSERT INTO Customers (first_name, last_name, address, email, phone)
        VALUES (@FirstName, @LastName, @Address, @Email, @Phone);
	SET @nrOfRows = @nrOfRows - 1
	END
END


CREATE OR ALTER PROCEDURE insertDataIntoProducts
    @nrOfRows INT,
    @tableName VARCHAR(50)
AS
BEGIN
    DECLARE @ProductName VARCHAR(100)
    DECLARE @Description VARCHAR(MAX)
    DECLARE @Price DECIMAL(10, 2)
    DECLARE @StockQuantity INT
	DECLARE @newProductID INT
	SET @newProductID = (SELECT MAX(product_id) + 1 FROM Products)
	if @newProductID is NULL
		SET @newProductID = 1
    WHILE @nrOfRows > 0
    BEGIN
        SET @ProductName = (
            SELECT CHOOSE(CAST(RAND()*(10)+1 AS INT), 'Product A', 'Product B', 'Product C', 'Product D', 'Product E', 'Product F', 'Product G', 'Product H', 'Product I', 'Product J')
        )
		SET @ProductName = @ProductName + CONVERT(VARCHAR, @newProductID)
		WHILE @ProductName is NULL
		BEGIN
			SET @ProductName = (
            SELECT CHOOSE(CAST(RAND()*(10)+1 AS INT), 'Product A', 'Product B', 'Product C', 'Product D', 'Product E', 'Product F', 'Product G', 'Product H', 'Product I', 'Product J')
			)
			SET @ProductName = @ProductName + CONVERT(VARCHAR, @newProductID)
		END
        SET @Description = (
            SELECT CHOOSE(CAST(RAND()*(10)+1 AS INT), 'Description A', 'Description B', 'Description C', 'Description D', 'Description E', 'Description F', 'Description G', 'Description H', 'Description I', 'Description J')
        )
		WHILE @Description is NULL
		BEGIN
			SET @Description = (
            SELECT CHOOSE(CAST(RAND()*(10)+1 AS INT), 'Description A', 'Description B', 'Description C', 'Description D', 'Description E', 'Description F', 'Description G', 'Description H', 'Description I', 'Description J')
			)
		END
        SET @Price = CAST(RAND() * 100 + 10 AS DECIMAL(10, 2))
        SET @StockQuantity = CAST(RAND() * 50 AS INT)

        INSERT INTO Products (product_id, name, description, price, stock_quantity)
        VALUES (@newProductID, @ProductName, @Description, @Price, @StockQuantity);
		SET @newProductID = @newProductID + 1
        SET @nrOfRows = @nrOfRows - 1
    END
END


CREATE OR ALTER PROCEDURE insertDataIntoOrders
    @nrOfRows INT,
    @tableName VARCHAR(50)
AS
BEGIN
    DECLARE @OrderDate DATETIME
    DECLARE @CustomerID INT
    DECLARE @ProductID INT
    DECLARE @Quantity INT

    WHILE @nrOfRows > 0
    BEGIN
        SET @OrderDate = DATEADD(DAY, -CAST(RAND() * 365 AS INT), GETDATE())
        SET @CustomerID = CAST(RAND() * 10 + 1 AS INT)
        SET @ProductID = CAST(RAND() * 10 + 1 AS INT)
        SET @Quantity = CAST(RAND() * 5 + 1 AS INT)

        INSERT INTO Orders (order_date, customer_id, product_id, quantity)
        VALUES (@OrderDate, @CustomerID, @ProductID, @Quantity);

        SET @nrOfRows = @nrOfRows - 1
    END
END


CREATE OR ALTER PROCEDURE insertDataIntoEmployees
    @nrOfRows INT,
    @tableName VARCHAR(50)
AS
BEGIN
    DECLARE @FirstName VARCHAR(50)
    DECLARE @LastName VARCHAR(50)
    DECLARE @Position VARCHAR(50)
    DECLARE @HireDate DATE
	DECLARE @idmax INT = 10

    WHILE @nrOfRows > 0
    BEGIN
        SET @FirstName = (
            SELECT CHOOSE(CAST(RAND()*(10)+1 AS INT), 'John', 'Jane', 'Michael', 'Emily', 'David', 'Olivia', 'Daniel', 'Sophia', 'William', 'Evelyn')
        )
		WHILE @FirstName is NULL
		BEGIN
			SET @FirstName = (
				SELECT CHOOSE(CAST(RAND()*(10)+1 AS INT), 'John', 'Jane', 'Michael', 'Emily', 'David', 'Olivia', 'Daniel', 'Sophia', 'William', 'Evelyn')
			)
		END
        SET @LastName = (
            SELECT CHOOSE(CAST(RAND()*(10)+1 AS INT), 'Doe', 'Smith', 'Johnson', 'Brown', 'Lee', 'Garcia', 'Martinez', 'Rodriguez', 'Nguyen', 'Kim')
        )
		WHILE @LastName is NULL
		BEGIN
			SET @LastName = (
            SELECT CHOOSE(CAST(RAND()*(10)+1 AS INT), 'Doe', 'Smith', 'Johnson', 'Brown', 'Lee', 'Garcia', 'Martinez', 'Rodriguez', 'Nguyen', 'Kim')
			)
		END
        SET @Position = (
            SELECT CHOOSE(CAST(RAND()*(5)+1 AS INT), 'Manager', 'Developer', 'Accountant', 'Salesperson', 'HR Specialist')
        )
		WHILE @Position is NULL
		BEGIN
			SET @Position = (
            SELECT CHOOSE(CAST(RAND()*(5)+1 AS INT), 'Manager', 'Developer', 'Accountant', 'Salesperson', 'HR Specialist')
			)
		END
        SET @HireDate = DATEADD(DAY, -CAST(RAND() * 3650 AS INT), GETDATE())

        INSERT INTO Employees (employee_id, first_name, last_name, position, HireDate)
        VALUES (@idmax, @FirstName, @LastName, @Position, @HireDate);

		SET @idmax = @idmax + 1
        SET @nrOfRows = @nrOfRows - 1
    END
END


CREATE OR ALTER PROCEDURE insertDataIntoReviews
    @nrOfRows INT,
    @tableName VARCHAR(50)
AS
BEGIN
    DECLARE @CustomerID INT
    DECLARE @ProductID INT
    DECLARE @Rating INT
    DECLARE @Comment NVARCHAR(MAX)

    WHILE @nrOfRows > 0
    BEGIN
        SET @CustomerID = CAST(RAND() * 10 + 1 AS INT)
        SET @ProductID = CAST(RAND() * 10 + 1 AS INT)
        SET @Rating = CAST(RAND() * 5 + 1 AS INT)
        SET @Comment = (
            SELECT CHOOSE(CAST(RAND()*(5)+1 AS INT), 'Good product', 'Great service', 'Could be better', 'Excellent!', 'Not satisfied')
        )

        INSERT INTO Reviews (customer_id, product_id, rating, comment)
        VALUES (@CustomerID, @ProductID, @Rating, @Comment);

        SET @nrOfRows = @nrOfRows - 1
    END
END



CREATE OR ALTER PROC insertData
@testRunID INT,
@testID INT,
@tableID INT
AS
BEGIN
	DECLARE @startTime DATETIME = SYSDATETIME()

	DECLARE @tableName VARCHAR(50) = (
		SELECT [Name] FROM [Tables] WHERE TableID = @tableID
	)

	PRINT 'Insert data into table ' + @tableName

	DECLARE @nrOfRows INT = (
		SELECT [NoOfRows] FROM TestTables  
			WHERE TestID = @testID AND TableID = @tableID
	)
	
	if @tableName = 'Employees'
		EXEC insertDataintoEmployees @nrOfRows, @tableName

	else if @tableName = 'Products'
		EXEC insertDataIntoProducts @nrOfRows, @tableName
	
	else if @tableName = 'Reviews'
		EXEC insertDataIntoReviews @nrOfRows, @tableName
		
	DECLARE @endTime DATETIME = SYSDATETIME()

	-- we insert the performance
	INSERT INTO TestRunTables(TestRunID, TableID, StartAt, EndAt)
		VALUES (@testRunID, @tableID, @startTime, @endTime)

END
GO


CREATE OR ALTER PROCEDURE insertDataIntoAllTables
@testRunID INT,
@testID INT
AS
BEGIN
	DECLARE @tableID INT
	DECLARE cursorForInsert CURSOR LOCAL FOR
		SELECT TableID
		FROM TestTables TT
			INNER JOIN Tests T on TT.TestID = T.TestID
		WHERE T.TestID = @testID
		ORDER BY TT.Position ASC
	PRINT 'here'
	
	OPEN cursorForInsert
	FETCH cursorForInsert INTO @tableID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC insertData @testRunID, @testID, @tableID

		FETCH NEXT FROM cursorForInsert INTO @tableID
	END
	CLOSE cursorForInsert
END
GO


CREATE OR ALTER VIEW allEmployees
AS
	SELECT employee_id, first_name, last_name, position, HireDate
	FROM Employees
GO


CREATE OR ALTER VIEW PurchaseView AS
SELECT p.purchase_id, p.purchase_date, c.first_name, c.last_name
FROM Purchase p
INNER JOIN Customers c ON p.customer_id = c.customer_id;


CREATE OR ALTER VIEW CategoryStockSummary AS
SELECT c.category_name, SUM(p.stock_quantity) AS total_stock_quantity
FROM Categories c
INNER JOIN ProductCategories pc ON c.category_id = pc.category_id
INNER JOIN Products p ON pc.product_id = p.product_id
GROUP BY c.category_name;


CREATE OR ALTER PROC selectDataView
@viewID INT,
@testRunID INT
AS
BEGIN
	DECLARE @startTime DATETIME = SYSDATETIME()

	DECLARE @viewName VARCHAR(100) = (
		SELECT [Name] FROM [Views]
			WHERE ViewID = @viewID
	)

	PRINT 'Selecting from view ' + @viewName

	DECLARE @query NVARCHAR(200) = N'SELECT * FROM '  + @viewName
	EXEC sp_executesql @query

	-- ending time after test
	DECLARE @endTime DATETIME = SYSDATETIME()

	INSERT INTO TestRunViews(TestRunID, ViewID, StartAt, EndAt)
		VALUES(@testRunID, @viewID, @startTime, @endTime)

END
GO


CREATE OR ALTER PROC selectDataFromAllViews
@testRunID INT,
@testID INT
AS
BEGIN
	PRINT 'Select all view for test = ' + convert(VARCHAR, @testID)

	DECLARE @viewID INT

	DECLARE cursorForViews CURSOR LOCAL FOR
		SELECT TV.ViewID FROM TestViews TV
			INNER JOIN Tests T on T.TestID = TV.TestID
		WHERE TV.TestID = @testID

	OPEN cursorForViews
	FETCH cursorForViews INTO @viewID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- We select the view
		EXEC selectDataView @viewID, @testRunID
		FETCH NEXT FROM cursorForViews INTO @viewID
	END
	CLOSE cursorForViews
END
GO


CREATE OR ALTER PROC runTest
@testID INT,
@description VARCHAR(5000)
AS
BEGIN
	PRINT 'Running test with id: ' + CONVERT(VARCHAR, @testID) + ' with description: ' + @description

	INSERT INTO TestRuns([Description]) values (@description)

	DECLARE @testRunID INT = (SELECT MAX(TestRunID) FROM TestRuns)

	DECLARE @startTime DATETIME = SYSDATETIME()

	EXEC insertDataIntoAllTables @testRunID, @testID

	EXEC selectDataFromAllViews @testRunID, @testID

	DECLARE @endTIME DATETIME = SYSDATETIME()

	EXEC deleteDataFromAllTables @testID


	UPDATE [TestRuns] SET StartAt = @startTime, EndAt = @endTIME

	DECLARE @totalTime INT = DATEDIFF(SECOND, @startTime, @endTime)

	PRINT 'Test with id = ' + CONVERT(VARCHAR, @testID) + ' took ' + CONVERT(VARCHAR, @totalTime) + ' seconds to execute !'

END
GO


CREATE OR ALTER PROC runAllTests
AS
BEGIN
	DECLARE @testName VARCHAR(50)
	DECLARE @testID INT

	DECLARE cursorForTests CURSOR LOCAL FOR
		SELECT * FROM Tests

	OPEN cursorForTests
	FETCH cursorForTests INTO @testID, @testName
	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Running ' + @testName + ' with id: ' + CONVERT(VARCHAR, @testID)

		-- Now we run the test
		EXEC runTest @testID, ' perfect'

		FETCH NEXT FROM cursorForTests INTO @testID, @testName
		IF condition
        		BREAK;   
	END
	CLOSE cursorForTests
END
GO


INSERT INTO [Tables]([Name])
VALUES ('Employees'), ('Products'), ('Reviews')


INSERT INTO [Tests]([Name])
VALUES ('Test 1'), ('Test 2'),('Test 3')


INSERT INTO [TestTables]([TestID], [TableID], [NoOfRows], [Position])
VALUES
	(1,1,400,1),
	(1,2,400,2),
	(1,3,300,3),
	(1,4,200,4),
	(1,5,100,5),
	(2,2,300,1),
	(2,3,800,2),
	(2,1,600,3),
	(2,5,200,4),
	(2,4,500,5),
	(2,6,600,6)


INSERT INTO [Views]([Name])
VALUES
	('allEmployees'),
	('PurchaseView'),
	('CategoryStockSummary')


INSERT INTO [TestViews]([TestID], [ViewID])
VALUES
	(1,1),
	(2,1),
	(2,2),
	(2,3)



