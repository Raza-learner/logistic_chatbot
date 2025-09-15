-- Insert Customers
INSERT INTO Customers (name, email, phone, address) VALUES
('John Doe', 'john.doe@example.com', '+12025550123', '123 Main St, New York, NY 10001'),
('Alice Smith', 'alice.smith@example.com', '+12025550124', '456 Oak Ave, Miami, FL 33101'),
('Bob Johnson', 'bob.johnson@example.com', '+12025550125', '789 Pine Rd, London, UK');

-- Insert Orders
INSERT INTO Orders (customer_id, order_number, order_date, total_weight, dimensions, destination_address, shipping_method, status) VALUES
(1, 'ORD12345', '2025-09-01 10:00:00', 5.00, '20x15x10 cm', '456 Queen St, Toronto, Canada', 'express', 'in_transit'),
(2, 'ORD12346', '2025-09-02 12:00:00', 2.50, '10x10x5 cm', '123 King St, Tokyo, Japan', 'standard', 'pending'),
(3, 'ORD12347', '2025-09-02 15:00:00', 7.00, '30x20x15 cm', '789 Elm St, Miami, FL 33101', 'economy', 'delivered'),
(2, 'ORD12348', '2025-09-04 09:00:00', 3.50, '15x10x8 cm', '321 Maple St, Sydney, Australia', 'express', 'in_transit'),
(3, 'ORD12349', '2025-09-05 11:00:00', 6.00, '25x20x12 cm', '654 Birch Rd, Berlin, Germany', 'standard', 'pending');

-- Insert Shipments
INSERT INTO Shipments (order_id, tracking_number, pickup_date, estimated_delivery_date, current_location, status) VALUES
(1, 'TRK78901', '2025-09-02', '2025-09-05', 'Chicago, IL', 'in_transit'),
(2, 'TRK78902', NULL, '2025-09-10', 'Miami, FL', 'pending'),
(3, 'TRK78903', '2025-09-02', '2025-09-03', 'Miami, FL', 'delivered'),
(4, 'TRK78904', '2025-09-04', '2025-09-07', 'Los Angeles, CA', 'in_transit'),
(5, 'TRK78905', NULL, '2025-09-12', 'Miami, FL', 'pending');

-- Insert Tracking Updates
INSERT INTO Tracking_Updates (shipment_id, update_time, location, status_description) VALUES
(1, '2025-09-01 09:00:00', 'New York, NY', 'Order received at warehouse'),
(1, '2025-09-02 14:00:00', 'New York, NY', 'Package picked up from sender'),
(1, '2025-09-02 18:00:00', 'Philadelphia, PA', 'In transit to sorting facility'),
(1, '2025-09-03 08:00:00', 'Chicago, IL', 'Package in transit to destination'),
(1, '2025-09-03 12:00:00', 'Chicago, IL', 'At local distribution center'),
(1, '2025-09-04 09:00:00', 'Toronto, Canada', 'Package arrived at destination hub'),
(3, '2025-09-03 10:00:00', 'Miami, FL', 'Package delivered to recipient'),
(4, '2025-09-04 10:00:00', 'Miami, FL', 'Order received at warehouse'),
(4, '2025-09-04 15:00:00', 'Los Angeles, CA', 'Package picked up from sender'),
(4, '2025-09-05 06:00:00', 'Los Angeles, CA', 'Package in transit to destination'),
(4, '2025-09-05 12:00:00', 'Dallas, TX', 'At sorting facility'),
(5, '2025-09-05 12:00:00', 'Miami, FL', 'Order received at warehouse');

-- Insert Shipment Logs
INSERT INTO Shipment_Logs (tracking_number, log_type, log_description, log_time) VALUES
('TRK78901', 'info', 'Package scanned at origin facility', '2025-09-01 08:30:00'),
('TRK78901', 'info', 'Package assigned to carrier', '2025-09-02 13:00:00'),
('TRK78901', 'warning', 'Minor delay due to sorting issue', '2025-09-02 17:00:00'),
('TRK78901', 'info', 'Package departed sorting facility', '2025-09-03 07:30:00'),
('TRK78901', 'note', 'Customer contacted regarding delivery', '2025-09-03 11:00:00'),
('TRK78904', 'info', 'Package scanned at Miami facility', '2025-09-04 10:00:00'),
('TRK78904', 'info', 'Assigned to international carrier', '2025-09-04 14:00:00'),
('TRK78904', 'error', 'Customs documentation issue detected', '2025-09-04 16:00:00'),
('TRK78904', 'info', 'Issue resolved, package cleared', '2025-09-05 08:00:00'),
('TRK78904', 'note', 'Scheduled for international transit', '2025-09-05 11:00:00'),
('TRK78905', 'info', 'Package received at warehouse', '2025-09-05 12:00:00'),
('TRK78905', 'warning', 'Awaiting pickup confirmation', '2025-09-05 14:00:00'),
('TRK78905', 'info', 'Package weight verified', '2025-09-05 15:00:00'),
('TRK78905', 'note', 'Pending customer address verification', '2025-09-05 16:00:00'),
('TRK78905', 'info', 'Ready for pickup scheduling', '2025-09-06 09:00:00');

-- Insert Customer Queries
INSERT INTO Customer_Queries (customer_id, order_id, query_text, response_text, query_status) VALUES
(1, 1, 'Where is my package TRK78901?', 'Your package is in transit in Chicago, IL, expected delivery by Sep 5.', 'resolved'),
(2, 2, 'Can I change the delivery address for ORD12346?', 'Please provide the new address.', 'open'),
(3, 3, 'My package arrived damaged.', 'Please upload a photo of the damage.', 'escalated');

-- Insert Admin Actions
INSERT INTO Admin_Actions (admin_id, tracking_number, action_type, action_description, action_time) VALUES
(1, 'TRK78901', 'view', 'Viewed shipment details', '2025-09-03 09:00:00'),
(1, 'TRK78901', 'update_status', 'Updated status to in_transit', '2025-09-03 09:05:00'),
(1, 'TRK78904', 'escalate', 'Escalated customs issue to supervisor', '2025-09-04 16:30:00'),
(1, NULL, 'note', 'Reviewed pending shipments report', '2025-09-05 10:00:00'),
(1, 'TRK78905', 'view', 'Checked package status', '2025-09-06 09:30:00');