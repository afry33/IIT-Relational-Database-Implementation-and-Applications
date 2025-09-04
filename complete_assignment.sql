-- Create database
CREATE DATABASE IF NOT EXISTS OnlineBookstore;
USE OnlineBookstore;

-- Create tables
CREATE TABLE Authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    country VARCHAR(50),
    birth_date DATE
);

CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    author_id INT,
    isbn VARCHAR(20) UNIQUE,
    price DECIMAL(10, 2) NOT NULL,
    publication_date DATE,
    stock_quantity INT DEFAULT 0,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE SET NULL
);

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    registration_date DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE DEFAULT (CURRENT_DATE),
    total_amount DECIMAL(10, 2),
    status ENUM('Pending', 'Processing', 'Shipped', 'Delivered') DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Order_Details (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    book_id INT,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

-- Insert sample data
INSERT INTO Authors (first_name, last_name, country, birth_date) VALUES
('George', 'Orwell', 'United Kingdom', '1903-06-25'),
('J.K.', 'Rowling', 'United Kingdom', '1965-07-31'),
('Stephen', 'King', 'United States', '1947-09-21'),
('Jane', 'Austen', 'United Kingdom', '1775-12-16'),
('Ernest', 'Hemingway', 'United States', '1899-07-21'),
('Agatha', 'Christie', 'United Kingdom', '1890-09-15'),
('J.R.R.', 'Tolkien', 'United Kingdom', '1892-01-03'),
('Harper', 'Lee', 'United States', '1926-04-28'),
('F. Scott', 'Fitzgerald', 'United States', '1896-09-24'),
('Gabriel', 'García Márquez', 'Colombia', '1927-03-06'),
('Leo', 'Tolstoy', 'Russia', '1828-09-09'),
('Virginia', 'Woolf', 'United Kingdom', '1882-01-25'),
('Mark', 'Twain', 'United States', '1835-11-30'),
('Charles', 'Dickens', 'United Kingdom', '1812-02-07'),
('William', 'Shakespeare', 'United Kingdom', '1564-04-26'),
('George R.R.', 'Martin', 'United States', '1948-09-20');

INSERT INTO Books (title, author_id, isbn, price, publication_date, stock_quantity) VALUES
('1984', 1, '9780451524935', 7.99, '1949-06-08', 25),
('Animal Farm', 1, '9780451526342', 6.99, '1945-08-17', 20),
('Harry Potter and the Philosopher''s Stone', 2, '9780747532743', 10.99, '1997-06-26', 30),
('Harry Potter and the Chamber of Secrets', 2, '9780747538493', 10.99, '1998-07-02', 28),
('The Shining', 3, '9780307743657', 9.99, '1977-01-28', 15),
('It', 3, '9781501142970', 12.99, '1986-09-15', 18),
('Pride and Prejudice', 4, '9780141439518', 5.99, '1813-01-28', 22),
('Sense and Sensibility', 4, '9780141439662', 6.99, '1811-10-30', 19),
('The Old Man and the Sea', 5, '9780684801223', 8.99, '1952-09-01', 12),
('For Whom the Bell Tolls', 5, '9780684803357', 9.99, '1940-10-21', 14),
('Murder on the Orient Express', 6, '9780062693662', 7.99, '1934-01-01', 17),
('And Then There Were None', 6, '9780062073488', 8.99, '1939-11-06', 16),
('The Hobbit', 7, '9780547928227', 11.99, '1937-09-21', 24),
('The Lord of the Rings', 7, '9780544003415', 14.99, '1954-07-29', 20),
('To Kill a Mockingbird', 8, '9780061120084', 9.99, '1960-07-11', 21),
('Go Set a Watchman', 8, '9780062409850', 12.99, '2015-07-14', 13);

INSERT INTO Customers (first_name, last_name, email, registration_date) VALUES
('John', 'Doe', 'john.doe@email.com', '2023-01-15'),
('Jane', 'Smith', 'jane.smith@email.com', '2023-02-10'),
('Robert', 'Johnson', 'robert.j@email.com', '2023-02-18'),
('Sarah', 'Williams', 'sarah.w@email.com', '2023-03-05'),
('Michael', 'Brown', 'michael.b@email.com', '2023-03-12'),
('Emily', 'Davis', 'emily.d@email.com', '2023-04-02'),
('David', 'Miller', 'david.m@email.com', '2023-04-15'),
('Lisa', 'Wilson', 'lisa.w@email.com', '2023-05-01'),
('James', 'Taylor', 'james.t@email.com', '2023-05-10'),
('Mary', 'Anderson', 'mary.a@email.com', '2023-05-22'),
('William', 'Thomas', 'william.t@email.com', '2023-06-05'),
('Linda', 'Jackson', 'linda.j@email.com', '2023-06-18'),
('Richard', 'White', 'richard.w@email.com', '2023-07-03'),
('Patricia', 'Harris', 'patricia.h@email.com', '2023-07-15'),
('Charles', 'Martin', 'charles.m@email.com', '2023-08-01'),
('Susan', 'Thompson', 'susan.t@email.com', '2023-08-12');

-- Create stored procedure to generate orders
DELIMITER //
CREATE PROCEDURE GenerateSampleOrders()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE customer INT;
    DECLARE book INT;
    DECLARE quantity INT;
    DECLARE price DECIMAL(10,2);
    DECLARE order_date DATE;
    
    WHILE i <= 20 DO
        SET customer = FLOOR(1 + RAND() * 16);
        SET order_date = DATE_SUB(CURRENT_DATE, INTERVAL FLOOR(RAND() * 90) DAY);
        
        INSERT INTO Orders (customer_id, order_date, total_amount, status)
        VALUES (customer, order_date, 0, 
                ELT(FLOOR(1 + RAND() * 4), 'Pending', 'Processing', 'Shipped', 'Delivered'));
        
        SET @order_id = LAST_INSERT_ID();
        
        SET @j = 1;
        SET @order_total = 0;
        WHILE @j <= FLOOR(1 + RAND() * 3) DO
            SET book = FLOOR(1 + RAND() * 16);
            SET quantity = FLOOR(1 + RAND() * 3);
            SELECT Books.price INTO price FROM Books WHERE book_id = book;
            
            INSERT INTO Order_Details (order_id, book_id, quantity, price)
            VALUES (@order_id, book, quantity, price);
            
            SET @order_total = @order_total + (price * quantity);
            SET @j = @j + 1;
        END WHILE;
        
        UPDATE Orders SET total_amount = @order_total WHERE order_id = @order_id;
        SET i = i + 1;
    END WHILE;
END//
DELIMITER ;

-- Generate sample orders
CALL GenerateSampleOrders();

-- Create indexes
CREATE INDEX idx_books_author ON Books(author_id);
CREATE INDEX idx_books_price ON Books(price);
CREATE INDEX idx_orders_customer_date ON Orders(customer_id, order_date);
CREATE INDEX idx_order_details_order ON Order_Details(order_id);
CREATE INDEX idx_authors_name ON Authors(first_name, last_name);

-- Create views
CREATE VIEW BookDetails AS
SELECT 
    b.book_id,
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) AS author,
    a.country AS author_country,
    b.isbn,
    b.price,
    b.publication_date,
    b.stock_quantity
FROM Books b
JOIN Authors a ON b.author_id = a.author_id;

CREATE VIEW CustomerOrderSummary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    MAX(o.order_date) AS last_order_date
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, customer_name, c.email;

CREATE VIEW BestsellingBooks AS
SELECT 
    b.book_id,
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) AS author,
    SUM(od.quantity) AS total_sold,
    SUM(od.quantity * od.price) AS total_revenue
FROM Books b
JOIN Authors a ON b.author_id = a.author_id
JOIN Order_Details od ON b.book_id = od.book_id
GROUP BY b.book_id, b.title, author
ORDER BY total_sold DESC;

-- Create triggers
DELIMITER //
CREATE TRIGGER UpdateStockAfterOrder
AFTER INSERT ON Order_Details
FOR EACH ROW
BEGIN
    UPDATE Books 
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE book_id = NEW.book_id;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER PreventNegativeStock
BEFORE UPDATE ON Books
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock quantity cannot be negative';
    END IF;
END//
DELIMITER ;

CREATE TABLE OrdersArchive (
    order_id INT,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    status VARCHAR(20),
    archived_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER ArchiveDeletedOrders
BEFORE DELETE ON Orders
FOR EACH ROW
BEGIN
    INSERT INTO OrdersArchive (order_id, customer_id, order_date, total_amount, status)
    VALUES (OLD.order_id, OLD.customer_id, OLD.order_date, OLD.total_amount, OLD.status);
END//
DELIMITER ;

-- Create functions and procedures
DELIMITER //
CREATE FUNCTION GetAuthorAveragePrice(author_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE avg_price DECIMAL(10,2);
    
    SELECT AVG(price) INTO avg_price
    FROM Books
    WHERE author_id = author_id;
    
    RETURN avg_price;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE GetBooksByPriceRange(IN min_price DECIMAL(10,2), IN max_price DECIMAL(10,2))
BEGIN
    SELECT 
        b.book_id,
        b.title,
        CONCAT(a.first_name, ' ', a.last_name) AS author,
        b.price,
        b.stock_quantity
    FROM Books b
    JOIN Authors a ON b.author_id = a.author_id
    WHERE b.price BETWEEN min_price AND max_price
    ORDER BY b.price;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE PlaceOrder(
    IN customer_id INT,
    IN book_id INT,
    IN quantity INT
)
BEGIN
    DECLARE book_price DECIMAL(10,2);
    DECLARE current_stock INT;
    DECLARE new_order_id INT;
    
    SELECT stock_quantity, price INTO current_stock, book_price
    FROM Books WHERE book_id = book_id;
    
    IF current_stock < quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;
    
    INSERT INTO Orders (customer_id, total_amount, status)
    VALUES (customer_id, 0, 'Pending');
    
    SET new_order_id = LAST_INSERT_ID();
    
    INSERT INTO Order_Details (order_id, book_id, quantity, price)
    VALUES (new_order_id, book_id, quantity, book_price);
    
    UPDATE Orders 
    SET total_amount = quantity * book_price
    WHERE order_id = new_order_id;
    
    SELECT CONCAT('Order placed successfully. Order ID: ', new_order_id) AS message;
END//
DELIMITER ;

-- Display verification results
SELECT 'Database and Tables Created Successfully' AS Status;
SELECT COUNT(*) AS Author_Count FROM Authors;
SELECT COUNT(*) AS Book_Count FROM Books;
SELECT COUNT(*) AS Customer_Count FROM Customers;
SELECT COUNT(*) AS Order_Count FROM Orders;
SELECT COUNT(*) AS Order_Detail_Count FROM Order_Details;

SHOW TABLES;
