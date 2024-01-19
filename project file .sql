-- Table 'customers'
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(100), -- Encrypted/hashed password
    full_name VARCHAR(100),
    customer_email VARCHAR(100) UNIQUE,
    account_balance DECIMAL(20, 2) DEFAULT 0.0,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table 'orders'
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    trader_id INT,
    stock_symbol VARCHAR(10),
    order_type ENUM('BUY', 'SELL'),
    quantity INT CHECK (quantity > 0),
    customer_id INT,
    price DECIMAL(10, 2),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Table 'transaction_history'
CREATE TABLE transaction_history (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_id INT,
    transaction_type ENUM('DEBIT', 'CREDIT'),
    amount DECIMAL(20, 2),
    transaction_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table 'portfolio'
CREATE TABLE portfolio (
    portfolio_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    stock_symbol VARCHAR(10),
    quantity INT,
    CONSTRAINT fk_customer_portfolio FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Inserting Trader Rohit buy order
INSERT INTO orders (trader_id, stock_symbol, order_type, quantity, price)
VALUES (103001, 'rohit', 'BUY', 100, 50);

-- Inserting Trader virat sell order
INSERT INTO orders (trader_id, stock_symbol, order_type, quantity, price)
VALUES (103002, 'virat', 'SELL', 50, NULL); -- Currect Market price 

-- Updating quantities after trade execution
UPDATE orders
SET quantity = quantity - 50
WHERE order_id = 103002;

UPDATE orders
SET quantity = quantity - 50
WHERE order_id = 103001;

-- Logging the trade execution
INSERT INTO trade_logs (order_id, action, timestamp)
VALUES (Rohit, 'EXECUTION', NOW());

INSERT INTO trade_logs (order_id, action, timestamp)
VALUES (Virat, 'EXECUTION', NOW());


-- Selecting open sell orders for Stock tata for example
SELECT * FROM orders
WHERE stock_symbol = 'Tata Power'
  AND order_type = 'SELL'
  AND price <= 50
  AND quantity > 0
ORDER BY timestamp ASC
LIMIT 1;

-- Updating market data
UPDATE market_data
SET last_trade_price = 50,
    last_trade_timestamp = NOW()
WHERE stock_symbol = 'Tata';

-- Monitoring open orders exceeding specified thresholds
SELECT * FROM orders
WHERE quantity > 100
  AND order_type = 'BUY';

-- Sample customer registration
INSERT INTO customers (username, password, full_name)
VALUES ('Gill10', 'hashed_password', 'subman gill');

-- Modify the orders table to link orders to specific customers.
ALTER TABLE orders
ADD COLUMN customer_id INT,
ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- When placing an order
-- Associating orders with customers
INSERT INTO orders (customer_id, trader_id, stock_symbol, order_type, quantity, price)
VALUES (103001, 101, 'Tata', 'BUY', 100, 50);

-- After trade execution, update account balances, Updating account balance after trade execution
UPDATE customers
SET account_balance = account_balance - (50 * 50) -- Deducting buy cost
WHERE customer_id = 103001;

UPDATE customers
SET account_balance = account_balance + (50 * 50) -- Adding sell revenue
WHERE customer_id = 103002;

-- customer account details
SELECT * FROM customers WHERE customer_id = 1;

-- Logging transaction history after trade execution
INSERT INTO transaction_history (customer_id, order_id, transaction_type, amount)
VALUES (1, Rohit, 'DEBIT', 50 * 50);

INSERT INTO transaction_history (customer_id, order_id, transaction_type, amount)
VALUES (2, Virat, 'CREDIT', 50 * 50);

-- Updating portfolio after trade execution
-- Assuming Trader Virat already had Stock Tata in the portfolio
-- Update the quantity or insert a new row as needed
UPDATE portfolio
SET quantity = quantity + 50
WHERE customer_id = 1 AND stock_symbol = 'Tata power';

-- Trigger to update account balance after trade execution
DELIMITER //

CREATE TRIGGER after_trade_execution
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE trade_amount DECIMAL(20, 2);

    IF NEW.order_type = 'BUY' THEN
        SET trade_amount = -(NEW.quantity * NEW.price);
    ELSE
        SET trade_amount = NEW.quantity * NEW.price;
    END IF;

    UPDATE customers
    SET account_balance = account_balance + trade_amount
    WHERE customer_id = NEW.customer_id;

    INSERT INTO transaction_history (customer_id, order_id, transaction_type, amount)
    VALUES (NEW.customer_id, NEW.order_id, IF(NEW.order_type = 'BUY', 'DEBIT', 'CREDIT'), ABS(trade_amount));
END;
//

DELIMITER ;

-- Trigger to update portfolio after trade execution
DELIMITER //

CREATE TRIGGER after_trade_execution_update_portfolio
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.order_type = 'BUY' THEN
        -- Update or insert new record into portfolio
        INSERT INTO portfolio (customer_id, stock_symbol, quantity)
        VALUES (NEW.customer_id, NEW.stock_symbol, NEW.quantity)
        ON DUPLICATE KEY UPDATE quantity = quantity + NEW.quantity;
    END IF;
END;
//

DELIMITER ;
This trigger also fires after an order is inserted into the orders table.
It checks if the order type is a buy order and updates the portfolio accordingly.
If the customer already holds the stock, it updates the quantity; otherwise, it inserts a new record.


-- Normalized Tables
CREATE TABLE Products (
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(50),
    Category VARCHAR(50),
    Price DECIMAL(10,2)
);

CREATE TABLE Suppliers (
    Supplier_ID INT PRIMARY KEY,
    Supplier_Name VARCHAR(50),
    Supplier_Address VARCHAR(100)
);

CREATE TABLE Inventory (
    Product_ID INT,
    Supplier_ID INT,
    Quantity_in_Stock INT,
    PRIMARY KEY (Product_ID, Supplier_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID),
    FOREIGN KEY (Supplier_ID) REFERENCES Suppliers(Supplier_ID)
);

