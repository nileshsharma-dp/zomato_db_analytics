-- Zomato Data Analysis
USE zomato_db;

-- Drop Commands for future use
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS riders;
DROP TABLE IF EXISTS deliveries;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(25),
    reg_date DATE
);

CREATE TABLE restaurants (
	restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(40),
    city VARCHAR (15),
    opening_hours VARCHAR(65)
    );
    
CREATE TABLE orders (
	order_id INT PRIMARY KEY,
    customer_id INT,	
    restaurant_id INT,	
    order_item VARCHAR(40),
    order_date DATE,
    order_time TIME,
    order_status VARCHAR(20),	
    total_amount FLOAT
    );

-- Adding FK CONSTRAINT
ALTER TABLE orders
ADD CONSTRAINT fk_restaurants
FOREIGN KEY (restaurant_id)
REFERENCES restaurants(restaurant_id);

-- Adding FK CONSTRAINT
ALTER TABLE orders
ADD CONSTRAINT fk_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

CREATE TABLE riders (
	rider_id INT PRIMARY KEY,
    rider_name VARCHAR(30),
    sign_up DATE
    );
    

CREATE TABLE deliveries (
	delivery_id INT PRIMARY KEY,
    order_id INT,
	delivery_status VARCHAR(35),
	delivery_time TIME,
	rider_id INT,
    CONSTRAINT fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_riders FOREIGN KEY (rider_id) REFERENCES riders(rider_id)
    );

-- End of Schemas


	