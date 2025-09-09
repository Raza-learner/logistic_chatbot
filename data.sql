-- data.sql
INSERT IGNORE INTO Customers (name, email, phone, address) VALUES
('John Doe', 'john.doe@example.com', '+12025550123', '123 Main St, New York, NY 10001'),
('Alice Smith', 'alice.smith@example.com', '+12025550124', '456 Oak Ave, Miami, FL 33101'),
('Bob Johnson', 'bob.johnson@example.com', '+12025550125', '789 Pine Rd, London, UK'),
('Eve Davis', 'eve.davis@example.com', '+12025550126', '101 Maple St, Toronto, Canada'),
('Charlie Brown', 'charlie.brown@example.com', '+12025550127', '202 Elm St, Tokyo, Japan'),
('Dana White', 'dana.white@example.com', '+12025550128', '303 Birch Ave, Sydney, Australia'),
('Frank Green', 'frank.green@example.com', '+12025550129', '404 Cedar Rd, Paris, France'),
('Grace Lee', 'grace.lee@example.com', '+12025550130', '505 Walnut St, Berlin, Germany'),
('Henry Kim', 'henry.kim@example.com', '+12025550131', '606 Chestnut Ave, Seoul, Korea'),
('Ivy Chen', 'ivy.chen@example.com', '+12025550132', '707 Oak St, Shanghai, China'),
('Jack Miller', 'jack.miller@example.com', '+12025550133', '808 Pine Rd, Mumbai, India'),
('Kara Lopez', 'kara.lopez@example.com', '+12025550134', '909 Maple Ave, Mexico City, Mexico');

INSERT IGNORE INTO Orders (customer_id, order_number, order_date, total_weight, dimensions, destination_address, shipping_method, status) VALUES
(1, 'ORD12345', '2025-09-01 10:00:00', 5.00, '20x15x10 cm', '456 Queen St, Toronto, Canada', 'express', 'in_transit'),
(2, 'ORD12346', '2025-09-02 12:00:00', 2.50, '10x10x5 cm', '123 King St, Tokyo, Japan', 'standard', 'pending'),
(3, 'ORD12347', '2025-09-02 15:00:00', 7.00, '30x20x15 cm', '789 Elm St, Miami, FL 33101', 'economy', 'delivered'),
(4, 'ORD12348', '2025-09-03 09:00:00', 4.00, '15x10x8 cm', '101 Pine St, Sydney, Australia', 'express', 'in_transit'),
(5, 'ORD12349', '2025-09-03 11:00:00', 6.50, '25x20x12 cm', '202 Oak Ave, Paris, France', 'standard', 'pending'),
(6, 'ORD12350', '2025-09-04 14:00:00', 3.00, '12x8x6 cm', '303 Maple Rd, Berlin, Germany', 'economy', 'delivered'),
(7, 'ORD12351', '2025-09-04 16:00:00', 8.00, '35x25x15 cm', '404 Elm St, Seoul, Korea', 'express', 'in_transit'),
(8, 'ORD12352', '2025-09-05 10:00:00', 1.50, '8x6x4 cm', '505 Birch Ave, Shanghai, China', 'standard', 'pending'),
(9, 'ORD12353', '2025-09-05 13:00:00', 9.00, '40x30x20 cm', '606 Cedar Rd, Mumbai, India', 'economy', 'delivered'),
(10, 'ORD12354', '2025-09-06 15:00:00', 5.50, '22x16x11 cm', '707 Walnut St, Mexico City, Mexico', 'express', 'in_transit'),
(11, 'ORD12355', '2025-09-06 17:00:00', 4.50, '18x12x9 cm', '808 Chestnut Ave, New York, NY 10001', 'standard', 'pending'),
(12, 'ORD12356', '2025-09-07 09:00:00', 7.50, '28x22x14 cm', '909 Pine Rd, London, UK', 'economy', 'delivered');

INSERT IGNORE INTO Shipments (order_id, tracking_number, pickup_date, estimated_delivery_date, current_location, status) VALUES
(1, 'TRK78901', '2025-09-02', '2025-09-05', 'Chicago, IL', 'in_transit'),
(2, 'TRK78902', NULL, '2025-09-10', 'Miami, FL', 'pending'),
(3, 'TRK78903', '2025-09-02', '2025-09-03', 'Miami, FL', 'delivered'),
(4, 'TRK78904', '2025-09-03', '2025-09-06', 'Los Angeles, CA', 'in_transit'),
(5, 'TRK78905', NULL, '2025-09-11', 'New York, NY', 'pending'),
(6, 'TRK78906', '2025-09-04', '2025-09-05', 'Toronto, Canada', 'delivered'),
(7, 'TRK78907', '2025-09-04', '2025-09-07', 'London, UK', 'in_transit'),
(8, 'TRK78908', NULL, '2025-09-12', 'Paris, France', 'pending'),
(9, 'TRK78909', '2025-09-05', '2025-09-06', 'Berlin, Germany', 'delivered'),
(10, 'TRK78910', '2025-09-06', '2025-09-09', 'Seoul, Korea', 'in_transit'),
(11, 'TRK78911', NULL, '2025-09-13', 'Shanghai, China', 'pending'),
(12, 'TRK78912', '2025-09-07', '2025-09-08', 'Mumbai, India', 'delivered');

INSERT IGNORE INTO Tracking_Updates (shipment_id, update_time, location, status_description) VALUES
(1, '2025-09-02 14:00:00', 'New York, NY', 'Package picked up from sender'),
(1, '2025-09-03 08:00:00', 'Chicago, IL', 'Package in transit to destination'),
(3, '2025-09-03 10:00:00', 'Miami, FL', 'Package delivered to recipient'),
(4, '2025-09-03 15:00:00', 'Los Angeles, CA', 'Package picked up'),
(5, '2025-09-04 09:00:00', 'New York, NY', 'Awaiting pickup'),
(6, '2025-09-04 12:00:00', 'Toronto, Canada', 'Delivered'),
(7, '2025-09-05 10:00:00', 'London, UK', 'In transit'),
(8, '2025-09-05 14:00:00', 'Paris, France', 'Pending'),
(9, '2025-09-06 08:00:00', 'Berlin, Germany', 'Delivered'),
(10, '2025-09-06 11:00:00', 'Seoul, Korea', 'In transit'),
(11, '2025-09-07 09:00:00', 'Shanghai, China', 'Pending'),
(12, '2025-09-07 13:00:00', 'Mumbai, India', 'Delivered');

INSERT IGNORE INTO Customer_Queries (customer_id, order_id, query_text, response_text, query_status) VALUES
(1, 1, 'Where is my package TRK78901?', 'Your package is in transit in Chicago, IL, expected delivery by Sep 5.', 'resolved'),
(2, 2, 'Can I change the delivery address for ORD12346?', 'Please provide the new address.', 'open'),
(3, 3, 'My package arrived damaged.', 'Please upload a photo of the damage.', 'escalated'),
(4, 4, 'When will my package TRK78904 arrive?', 'Expected delivery by Sep 6.', 'resolved'),
(5, 5, 'What is the cost for express shipping?', 'Express shipping costs $120 for your package.', 'resolved'),
(6, 6, 'Can I cancel ORD12350?', 'Cancellation not possible as it’s delivered.', 'resolved'),
(7, 7, 'Track TRK78907', 'Your package is in transit in London, UK.', 'resolved'),
(8, 8, 'Need pickup for ORD12352', 'Please confirm pickup address.', 'open'),
(9, 9, 'Is TRK78909 delivered?', 'Yes, delivered on Sep 6.', 'resolved'),
(10, 10, 'Customs fees for TRK78910?', 'Estimated 5-10% duty based on item value.', 'open'),
(11, 11, 'When will TRK78911 ship?', 'Awaiting pickup, scheduled for Sep 13.', 'resolved'),
(12, 12, 'Return ORD12356', 'Please provide return reason.', 'open');

 INSERT INTO Shipment_Logs (tracking_number, log_type, log_description, log_time) VALUES
     -- TRK78901
     ('TRK78901', 'info', 'Package scanned at origin facility', '2025-09-01 08:30:00'),
     ('TRK78901', 'info', 'Package assigned to carrier', '2025-09-02 13:00:00'),
     ('TRK78901', 'warning', 'Minor delay due to sorting issue', '2025-09-02 17:00:00'),
     ('TRK78901', 'info', 'Package departed sorting facility', '2025-09-03 07:30:00'),
     ('TRK78901', 'note', 'Customer contacted regarding delivery', '2025-09-03 11:00:00'),
     -- TRK78904
     ('TRK78904', 'info', 'Package scanned at Miami facility', '2025-09-04 10:00:00'),
     ('TRK78904', 'info', 'Assigned to international carrier', '2025-09-04 14:00:00'),
     ('TRK78904', 'error', 'Customs documentation issue detected', '2025-09-04 16:00:00'),
     ('TRK78904', 'info', 'Issue resolved, package cleared', '2025-09-05 08:00:00'),
     ('TRK78904', 'note', 'Scheduled for international transit', '2025-09-05 11:00:00'),
     -- TRK78905
     ('TRK78905', 'info', 'Package received at warehouse', '2025-09-05 12:00:00'),
     ('TRK78905', 'warning', 'Awaiting pickup confirmation', '2025-09-05 14:00:00'),
     ('TRK78905', 'info', 'Package weight verified', '2025-09-05 15:00:00'),
     ('TRK78905', 'note', 'Pending customer address verification', '2025-09-05 16:00:00'),
     ('TRK78905', 'info', 'Ready for pickup scheduling', '2025-09-06 09:00:00');

INSERT IGNORE INTO Returns (order_id, customer_id, return_reason, return_status, return_label) VALUES
(3, 3, 'Received damaged item', 'requested', 'RET45678'),
(6, 6, 'Wrong item delivered', 'approved', 'RET45679'),
(9, 9, 'Changed mind', 'requested', 'RET45680');