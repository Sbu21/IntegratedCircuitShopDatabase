INSERT INTO Customers (customer_id, first_name, last_name, address, email, phone)
VALUES
  (1, 'John', 'Doe', '123 Main St', 'john.doe@email.com', '555-123-4567'),
  (2, 'Jane', 'Smith', '456 Elm St', 'jane.smith@email.com', '555-987-6543'),
  (3, 'Bob', 'Johnson', '789 Oak St', 'bob.johnson@email.com', '555-234-5678');

INSERT INTO Products (product_id, name, description, price, stock_quantity)
VALUES
  (1, 'Microcontroller', 'An advanced microcontroller', 29.99, 100),
  (2, 'LED Display', 'High-resolution LED display', 49.99, 50),
  (3, 'Resistor Pack', 'Assorted resistor pack', 9.99, 200);

INSERT INTO Purchase (purchase_id, customer_id, purchase_date, total_amount)
VALUES
  (1, 1, '2023-11-01 10:00:00', 29.99),
  (2, 2, '2023-11-02 14:30:00', 99.98),
  (3, 3, '2023-11-03 09:15:00', 9.99);

INSERT INTO PurchasedItems (purchased_item_id, purchase_id, product_id, quantity)
VALUES
  (1, 1, 1, 2),
  (2, 2, 2, 3),
  (3, 3, 3, 5),
  (4, 4, 4, 1); - violates referential integrity constrains - no purchase_id 4

INSERT INTO Categories (category_id, category_name)
VALUES
  (1, 'Electronics'),
  (2, 'Components'),
  (3, 'Accessories');

INSERT INTO ProductCategories (product_category_id, product_id, category_id)
VALUES
  (1, 1, 1),
  (2, 2, 1),
  (3, 3, 2);

INSERT INTO StoreLocations (location_id, inventory_id, store_name, address)
VALUES
  (1, 1, 'Main Store', '123 Main St'),
  (2, 2, 'Downtown Store', '456 Elm St'),
  (3, 3, 'Suburb Store', '789 Oak St');

INSERT INTO Reviews (review_id, customer_id, product_id, rating, comment)
VALUES
  (1, 1, 1, 5, 'Great product!'),
  (2, 2, 2, 4, 'Good display quality'),
  (3, 3, 3, 3, 'Decent resistors');

INSERT INTO Inventory (inventory_id, product_id, stock_quantity)
VALUES
  (1, 1, 50),
  (2, 2, 25),
  (3, 3, 100);

UPDATE Customers
SET phone = '555-999-8888'
WHERE last_name LIKE '%Smith%' AND email IS NOT NULL;

UPDATE Products
SET price = price * 1.1
WHERE product_id IN (1, 3) AND stock_quantity >= 50;

DELETE FROM Reviews
WHERE NOT rating BETWEEN 3 AND 5;

DELETE FROM Purchase
WHERE purchase_id = 2;

/*a*/

SELECT *
FROM Products
WHERE price = 10.99
UNION ALL
SELECT *
FROM Products
WHERE price = 29.99;

SELECT DISTINCT *
FROM Products
WHERE price = 10.99 OR price = 29.99;

/*b*/

SELECT *
FROM Products
WHERE price = 10.99
INTERSECT	
SELECT *
FROM Products
WHERE name= 'Microcontroller';

SELECT p.name
FROM Products p
WHERE p.name IN ('Integrated Circuit', 'Microcontroller');

/*c*/

SELECT DISTINCT p.name
FROM Products p
EXCEPT
SELECT p.name
FROM Products p
WHERE p.name = 'Microcontroller';

SELECT *
FROM Products p
WHERE p.name NOT IN (SELECT name
FROM StoreLocations s
WHERE address = '789 Oak Street');

/*d*/

SELECT c.first_name, c.last_name
FROM Customers c
INNER JOIN Purchase p ON c.customer_id = p.customer_id
WHERE p.purchase_id = 1;

SELECT p.name, c.category_name
FROM Products AS p
LEFT JOIN ProductCategories AS pc ON p.product_id = pc.product_id
LEFT JOIN Categories AS c ON pc.category_id = c.category_id; /*Many to many*/

SELECT c.first_name, c.last_name, p.name, pu.purchase_date
FROM Customers c
RIGHT JOIN Purchase pu ON c.customer_id = pu.customer_id
RIGHT JOIN PurchasedItems pi ON pu.purchase_id = pi.purchase_id
RIGHT JOIN Products p ON pi.product_id = p.product_id;

SELECT p.name, p.description, pi.quantity, ir.stock_quantity, pur.purchase_id, pur.total_amount, sr.rating
FROM Products p
FULL JOIN PurchasedItems pi ON pi.product_id = p.product_id
FULL JOIN Inventory ir ON pi.product_id = ir.product_id
FULL JOIN Purchase pur ON pi.purchase_id = pur.purchase_id
FULL JOIN Reviews sr ON sr.product_id = p.product_id;

/*e*/

SELECT first_name, last_name
FROM Customers
WHERE customer_id IN (SELECT customer_id 
					  FROM Purchase 
					  WHERE total_amount > 2
					  );

SELECT first_name, last_name
FROM Customers
WHERE customer_id IN (SELECT customer_id 
					  FROM Purchase
					  WHERE purchase_id IN (SELECT purchase_id 
										   FROM ProductCategories 
										   WHERE category_id IN (SELECT DISTINCT category_id 
																 FROM Reviews 
																 WHERE rating = 5
																 )
											)
						);

/*f*/

SELECT first_name, last_name
FROM Customers c
WHERE EXISTS (SELECT 1 
	      FROM Purchase p 
	      WHERE p.customer_id = c.customer_id);

SELECT c.first_name, c.last_name
FROM Customers c
WHERE EXISTS (
    SELECT pu.purchase_id
    FROM Purchase pu
    WHERE pu.customer_id = c.customer_id
    AND pu.total_amount < 100
);

/*g*/

SELECT subquery.customer_id, subquery.avg_purchase_amount
FROM (
    SELECT p.customer_id, AVG(p.total_amount) AS avg_purchase_amount
    FROM Purchase AS p
    GROUP BY p.customer_id
    HAVING COUNT(p.purchase_id) = 1
) AS subquery;

SELECT p.product_id, p.name, p.price
FROM Products AS p
JOIN (
    SELECT pc.product_id, AVG(p.price) AS avg_category_price
    FROM ProductCategories AS pc
    JOIN Products AS p ON pc.product_id = p.product_id
    GROUP BY pc.product_id, pc.category_id
) AS subquery ON p.product_id = subquery.product_id
WHERE p.price = subquery.avg_category_price;

/*h*/

SELECT c.category_name, AVG(p.price) AS avg_price
FROM Categories AS c
JOIN ProductCategories AS pc ON c.category_id = pc.category_id
JOIN Products AS p ON pc.product_id = p.product_id
GROUP BY c.category_name;

SELECT p.customer_id, COUNT(p.purchase_id) AS purchase_count
FROM Purchase AS p
GROUP BY p.customer_id
HAVING COUNT(p.purchase_id) < 2;

SELECT c.category_name, SUM(p.stock_quantity) AS total_stock_quantity
FROM Categories AS c
JOIN ProductCategories AS pc ON c.category_id = pc.category_id
JOIN Products AS p ON pc.product_id = p.product_id
GROUP BY c.category_name
HAVING SUM(p.stock_quantity) < 500;

SELECT c.category_name, MIN(p.price) AS min_price, MAX(p.price) AS max_price
FROM Categories AS c
JOIN ProductCategories AS pc ON c.category_id = pc.category_id
JOIN Products AS p ON pc.product_id = p.product_id
GROUP BY c.category_name
HAVING MAX(p.price) - MIN(p.price) < 50;

/*i*/

SELECT customer_id, first_name, last_name
FROM Customers
WHERE customer_id = ANY (
    SELECT DISTINCT p1.customer_id
    FROM Purchase p1
    WHERE p1.total_amount = ALL (
        SELECT p2.total_amount
        FROM Purchase p2
        WHERE p2.customer_id = Customers.customer_id
    )
);

SELECT product_id, name, price
FROM Products
WHERE price < ALL (
    SELECT price
    FROM Products
    WHERE product_id IN (
        SELECT product_id
        FROM ProductCategories
        WHERE category_id = 1
    )
);

SELECT customer_id, first_name, last_name
FROM Customers
WHERE customer_id = ANY (
    SELECT DISTINCT p1.customer_id
    FROM Purchase p1
    WHERE p1.total_amount > ALL (
        SELECT p2.total_amount
        FROM Purchase p2
        WHERE p2.customer_id IN (
            SELECT customer_id
            FROM Customers
            WHERE customer_id != p1.customer_id
        )
    )
);

SELECT product_id, name, price
FROM Products
WHERE price > ALL (
    SELECT price
    FROM Products
    WHERE product_id NOT IN (
        SELECT product_id
        FROM ProductCategories
        WHERE category_id < 3
    )
);



