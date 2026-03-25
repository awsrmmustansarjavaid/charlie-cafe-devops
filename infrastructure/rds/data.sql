-- ==========================================================
-- ☕ Charlie Cafe — SAMPLE DATA
-- Purpose: Insert test data
-- Safe: YES (uses INSERT IGNORE)
-- ==========================================================

USE cafe_db;

-- =============================
-- EMPLOYEES
-- =============================
INSERT IGNORE INTO employees
(cognito_user_id,name,job_title,salary,start_date)
VALUES
('emp-001','Ahmed','Barista',800,'2024-01-01'),
('emp-002','Hassan','Cashier',750,'2024-02-01');

-- =============================
-- ATTENDANCE
-- =============================
INSERT IGNORE INTO attendance
(employee_id,attendance_date,checkin_time,checkout_time)
VALUES
(1,CURDATE(),'09:00:00','17:00:00'),
(2,CURDATE(),'09:15:00','17:00:00');

-- =============================
-- LEAVES
-- =============================
INSERT IGNORE INTO leaves
(employee_id,leave_date,leave_type)
VALUES
(1,'2026-03-01','Sick Leave');

-- =============================
-- HOLIDAYS
-- =============================
INSERT IGNORE INTO holidays
(holiday_date,description)
VALUES
('2026-12-25','Christmas'),
('2026-01-01','New Year');

-- =============================
-- ORDERS
-- =============================
INSERT IGNORE INTO orders
(table_number,customer_name,item,quantity,total_cost,total_amount,payment_status,status)
VALUES
(1,'Ali Khan','Espresso',2,4.00,8.00,'PAID','COMPLETED'),
(2,'Sara Ahmed','Cappuccino',1,3.50,5.00,'PAID','COMPLETED'),
(3,'Omar Ali','Latte',1,3.00,5.00,'PENDING','RECEIVED');