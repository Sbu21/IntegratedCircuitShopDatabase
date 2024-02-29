CREATE DATABASE IntegratedCircuitsShop;
GO
USE IntegratedCircuitsShop;
GO
CREATE TABLE Customers
(
customer_id INT PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR(50),
address VARCHAR(255),
email VARCHAR(100),
phone VARCHAR(20),
);

CREATE TABLE Products
(
product_id INT PRIMARY KEY,
name VARCHAR(100),
description VARCHAR(MAX),
price DECIMAL(10,2),
stock_quantity INT
);

CREATE TABLE Purchase
(
purchase_id INT PRIMARY KEY,
customer_id INT,
purchase_date DATETIME,
total_amount DECIMAL(10, 2),
FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE PurchasedItems
(
purchased_item_id INT PRIMARY KEY,
purchase_id INT,
product_id INT,
quantity INT,
FOREIGN KEY (purchase_id) REFERENCES Purchase(purchase_id),
FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Categories
(
category_id INT PRIMARY KEY,
category_name VARCHAR(50)
);

CREATE TABLE ProductCategories
(
product_category_id INT PRIMARY KEY,
product_id INT,
category_id INT,
FOREIGN KEY (product_id) REFERENCES Products(product_id),
FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

CREATE TABLE Reviews
(
review_id INT PRIMARY KEY,
customer_id INT,
product_id INT,
rating INT,
comment VARCHAR(MAX),
FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Inventory
(
inventory_id INT PRIMARY KEY,
product_id INT,
stock_quantity INT
FOREIGN KEY (product_id) REFERENCES Products(product_id) 
);

CREATE TABLE StoreLocations
(
location_id INT PRIMARY KEY,
inventory_id INT,
store_name VARCHAR(100),
address VARCHAR(255),
FOREIGN KEY (inventory_id) REFERENCES Inventory(inventory_id)
);
