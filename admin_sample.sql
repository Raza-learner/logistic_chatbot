INSERT INTO customers (first_name, last_name, email, phone, address) VALUES
('John', 'Doe', 'john.doe@example.com', '555-0101', '123 Main St, New York, NY 10001'),
('Jane', 'Smith', 'jane.smith@example.com', '555-0102', '456 Oak Ave, Los Angeles, CA 90001'),
('Alice', 'Johnson', 'alice.johnson@example.com', '555-0103', '789 Pine Rd, Chicago, IL 60601'),
('Bob', 'Williams', 'bob.williams@example.com', '555-0104', '321 Elm St, Houston, TX 77001'),
('Emma', 'Brown', 'emma.brown@example.com', '555-0105', '654 Cedar Ln, Miami, FL 33101');

-- Inserting dummy shipment data
INSERT INTO shipments (tracking_id, customer_id, package_status, origin, destination, weight, estimated_delivery) VALUES
('TRK123456789', 1, 'In Transit', 'New York, NY', 'Boston, MA', 5.25, '2025-09-15'),
('TRK987654321', 2, 'Delivered', 'Los Angeles, CA', 'San Francisco, CA', 3.10, '2025-09-07'),
('TRK456789123', 3, 'Pending', 'Chicago, IL', 'Dallas, TX', 7.80, '2025-09-20'),
('TRK789123456', 4, 'Delayed', 'Houston, TX', 'Seattle, WA', 4.50, '2025-09-12'),
('TRK321654987', 5, 'Cancelled', 'Miami, FL', 'Atlanta, GA', 2.75, NULL);

-- Inserting dummy warehouse data
INSERT INTO warehouse (shipment_id, warehouse_location, stock_status) VALUES
(1, 'New York Warehouse', 'In Stock'),
(2, 'Los Angeles Warehouse', 'Out of Stock'),
(3, 'Chicago Warehouse', 'Low Stock'),
(4, 'Houston Warehouse', 'In Stock'),
(5, 'Miami Warehouse', 'Out of Stock');

-- Inserting dummy admin task data
INSERT INTO admin_tasks (admin_id, task_description, task_status, completed_at) VALUES
(1, 'Verify shipment TRK123456789 routing', 'In Progress', NULL),
(2, 'Update customer details for John Doe', 'Completed', '2025-09-08 10:30:00'),
(1, 'Resolve delay for TRK789123456', 'Pending', NULL),
(3, 'Generate weekly delivery report', 'In Progress', NULL),
(2, 'Coordinate restock for Chicago Warehouse', 'Completed', '2025-09-07 15:45:00');

INSERT INTO tracking_logs (tracking_id, log_time, log_description, location, status_update) VALUES
('TRK123456789', '2025-09-06 08:00:00', 'Package received at warehouse', 'New York Warehouse', 'Received'),
('TRK123456789', '2025-09-06 12:00:00', 'Package sorted for transit', 'New York Warehouse', 'Sorted'),
('TRK123456789', '2025-09-07 06:00:00', 'Package departed warehouse', 'New York, NY', 'In Transit'),
('TRK123456789', '2025-09-07 14:00:00', 'Package arrived at sorting facility', 'Hartford, CT', 'In Transit'),
('TRK123456789', '2025-09-08 09:00:00', 'Package in transit to destination', 'Boston, MA', 'In Transit'),
('TRK123456789', '2025-09-08 15:00:00', 'Package out for delivery', 'Boston, MA', 'Out for Delivery'),
('TRK987654321', '2025-09-05 07:00:00', 'Package received at warehouse', 'Los Angeles Warehouse', 'Received'),
('TRK987654321', '2025-09-05 11:00:00', 'Package sorted for transit', 'Los Angeles Warehouse', 'Sorted'),
('TRK987654321', '2025-09-06 05:00:00', 'Package departed warehouse', 'Los Angeles, CA', 'In Transit'),
('TRK987654321', '2025-09-06 13:00:00', 'Package arrived at sorting facility', 'San Francisco, CA', 'In Transit'),
('TRK987654321', '2025-09-07 08:00:00', 'Package delivered to customer', 'San Francisco, CA', 'Delivered'),
('TRK456789123', '2025-09-07 09:00:00', 'Package received at warehouse', 'Chicago Warehouse', 'Received'),
('TRK456789123', '2025-09-07 14:00:00', 'Package sorted for transit', 'Chicago Warehouse', 'Sorted'),
('TRK456789123', '2025-09-08 07:00:00', 'Package awaiting dispatch', 'Chicago, IL', 'Pending'),
('TRK456789123', '2025-09-08 12:00:00', 'Package ready for transit', 'Chicago, IL', 'Pending'),
('TRK456789123', '2025-09-09 06:00:00', 'Package scheduled for dispatch', 'Chicago, IL', 'Pending'),
('TRK789123456', '2025-09-06 10:00:00', 'Package received at warehouse', 'Houston Warehouse', 'Received'),
('TRK789123456', '2025-09-06 15:00:00', 'Package sorted for transit', 'Houston Warehouse', 'Sorted'),
('TRK789123456', '2025-09-07 08:00:00', 'Package departed warehouse', 'Houston, TX', 'In Transit'),
('TRK789123456', '2025-09-07 16:00:00', 'Delay due to weather conditions', 'Dallas, TX', 'Delayed'),
('TRK789123456', '2025-09-08 10:00:00', 'Package rerouted to alternate facility', 'Austin, TX', 'Delayed'),
('TRK321654987', '2025-09-05 09:00:00', 'Package received at warehouse', 'Miami Warehouse', 'Received'),
('TRK321654987', '2025-09-05 14:00:00', 'Package sorted for transit', 'Miami Warehouse', 'Sorted'),
('TRK321654987', '2025-09-06 08:00:00', 'Package cancelled by customer', 'Miami, FL', 'Cancelled'),
('TRK321654987', '2025-09-06 10:00:00', 'Package returned to warehouse', 'Miami Warehouse', 'Cancelled'),
('TRK321654987', '2025-09-07 09:00:00', 'Refund processed for cancellation', 'Miami, FL', 'Cancelled');
