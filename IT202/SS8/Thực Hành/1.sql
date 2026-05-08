CREATE DATABASE SalesDB;
USE SalesDB;


CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    gender CHAR(1) CHECK (gender IN ('M','F')),
    birth_date DATE
);


CREATE TABLE Category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL
);


CREATE TABLE Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    price DECIMAL(12,2),
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);


CREATE TABLE Order_Detail (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);


INSERT INTO Customer (full_name,email,gender,birth_date) VALUES
('Nguyen Van A','a@example.com','M','2000-01-01'),
('Tran Thi B','b@example.com','F','1998-05-10'),
('Le Van C','c@example.com','M','1995-07-20'),
('Pham Thi D','d@example.com','F','2002-03-15'),
('Hoang Van E','e@example.com','M','1999-12-30');

INSERT INTO Category (category_name) VALUES
('Electronics'),('Books'),('Fashion');

INSERT INTO Product (product_name,price,category_id) VALUES
('Laptop',20000000,1),
('Smartphone',15000000,1),
('Novel',120000,2),
('Textbook',350000,2),
('T-Shirt',200000,3);

INSERT INTO Orders (customer_id,order_date) VALUES
(1,'2025-01-10'),(2,'2025-02-05'),(3,'2025-03-12');

INSERT INTO Order_Detail (order_id,product_id,quantity) VALUES
(1,1,1),(1,3,2),(2,2,1),(3,4,1);




SELECT full_name, email,
       CASE WHEN gender='M' THEN 'Nam' ELSE 'Nữ' END AS gender_text
FROM Customer;


SELECT full_name, YEAR(CURDATE())-YEAR(birth_date) AS age
FROM Customer
ORDER BY age ASC
LIMIT 3;


SELECT o.order_id, c.full_name, o.order_date
FROM Orders o
INNER JOIN Customer c ON o.customer_id = c.customer_id;


SELECT cat.category_name, COUNT(*) AS product_count
FROM Product p
INNER JOIN Category cat ON p.category_id = cat.category_id
GROUP BY cat.category_name
HAVING COUNT(*) >= 2;


SELECT product_name, price
FROM Product
WHERE price > (SELECT AVG(price) FROM Product);


SELECT full_name, email
FROM Customer
WHERE customer_id NOT IN (SELECT customer_id FROM Orders);


SELECT c.category_name, SUM(p.price*od.quantity) AS revenue
FROM Order_Detail od
JOIN Product p ON od.product_id = p.product_id
JOIN Category c ON p.category_id = c.category_id
GROUP BY c.category_name
HAVING SUM(p.price*od.quantity) > 
       1.2*(SELECT AVG(total) FROM (
             SELECT SUM(p2.price*od2.quantity) AS total
             FROM Order_Detail od2
             JOIN Product p2 ON od2.product_id = p2.product_id
             GROUP BY p2.category_id
           ) t);


SELECT p.product_name, p.price, p.category_id
FROM Product p
WHERE p.price = (
    SELECT MAX(p2.price)
    FROM Product p2
    WHERE p2.category_id = p.category_id
);


SELECT full_name
FROM Customer
WHERE customer_id IN (
    SELECT o.customer_id
    FROM Orders o
    WHERE o.order_id IN (
        SELECT od.order_id
        FROM Order_Detail od
        JOIN Product p ON od.product_id = p.product_id
        JOIN Category c ON p.category_id = c.category_id
        WHERE c.category_name = 'Electronics'
    )
);
