-- Create Database
CREATE DATABASE logistics_db;
USE logistics_db;

-- Customers Table: Stores customer information
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders Table: Stores order details for shipments
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_weight DECIMAL(10, 2),
    dimensions VARCHAR(50),
    destination_address TEXT,
    shipping_method ENUM('express', 'standard', 'economy') NOT NULL,
    status ENUM('pending', 'in_transit', 'delivered', 'cancelled') DEFAULT 'pending',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Shipments Table: Tracks shipment details
CREATE TABLE Shipments (
    shipment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    tracking_number VARCHAR(20) UNIQUE NOT NULL,
    pickup_date DATE,
    estimated_delivery_date DATE,
    current_location VARCHAR(100),
    status ENUM('pending', 'picked_up', 'in_transit', 'at_customs', 'out_for_delivery', 'delivered', 'failed') DEFAULT 'pending',
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    INDEX idx_tracking_number (tracking_number)
);

-- Tracking Updates Table: Stores customer-facing tracking history
CREATE TABLE Tracking_Updates (
    update_id INT PRIMARY KEY AUTO_INCREMENT,
    shipment_id INT,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    location VARCHAR(100),
    status_description TEXT,
    FOREIGN KEY (shipment_id) REFERENCES Shipments(shipment_id)
);

-- Shipment Logs Table: Stores internal system logs
CREATE TABLE Shipment_Logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    tracking_number VARCHAR(20) NOT NULL,
    log_type ENUM('info', 'warning', 'error', 'note') DEFAULT 'info',
    log_description TEXT NOT NULL,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tracking_number) REFERENCES Shipments(tracking_number)
);

-- Customer Queries Table: Logs customer inquiries
CREATE TABLE Customer_Queries (
    query_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_id INT NULL,
    query_text TEXT NOT NULL,
    response_text TEXT,
    query_status ENUM('open', 'resolved', 'escalated') DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- Admin Actions Table: Logs admin activities
CREATE TABLE Admin_Actions (
    action_id INT PRIMARY KEY AUTO_INCREMENT,
    admin_id INT NOT NULL,  -- Simplified; assumes admin ID is provided
    tracking_number VARCHAR(20) NULL,
    action_type ENUM('view', 'update_status', 'escalate', 'note') NOT NULL,
    action_description TEXT NOT NULL,
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tracking_number) REFERENCES Shipments(tracking_number)
);