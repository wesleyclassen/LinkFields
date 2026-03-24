-- Migration V3: Seed Mock Data
-- Objective: Provide a testable environment for Technical BA assessment validation.

-- 1. Seed Customers
INSERT INTO Customers (Name, Email, Segment, Signup_Date) VALUES
('John Doe', 'john.doe@example.com', 'Retail', '2025-01-15'),
('Jane Smith', 'jane.smith@example.com', 'Enterprise', '2024-11-20'),
('Robert Brown', 'robert.brown@example.com', 'SMB', '2025-02-01'),
('Sarah Wilson', 'sarah.wilson@example.com', 'Retail', '2025-03-01'),
('Michael Lee', 'michael.lee@example.com', 'Enterprise', '2025-02-15');

-- 2. Seed Subscriptions
INSERT INTO Subscriptions (Customer_Id, Plan_Type, Start_Date, End_Date) VALUES
(1, 'Basic', '2025-01-15', NULL),
(2, 'Premium', '2024-11-20', NULL),
(3, 'Basic', '2025-02-01', '2025-03-01'), -- Cancelled/Short tenure
(4, 'Basic', '2025-03-01', NULL),
(5, 'Premium', '2025-02-15', NULL);

-- 3. Seed Usage (Generate some historical data for Churn/Upsell analysis)
-- High usage forupsell target (Sarah Wilson - Customer 4)
INSERT INTO Usage (Customer_ID, Date, Data_Used_Mb, Call_Minutes) VALUES
(4, '2025-03-10', 450.00, 120),
(4, '2025-03-15', 500.00, 150), -- Near 1GB limit (950MB total)

-- Declining usage for churn risk (Jane Smith - Customer 2)
(2, '2025-01-01', 5000.00, 600), -- High Jan usage
(2, '2025-02-01', 4000.00, 450), -- Medium Feb usage
(2, '2025-03-01', 500.00, 100),  -- Drastic decline in March

-- Regular usage (John Doe - Customer 1)
(1, '2025-01-20', 100.00, 30),
(1, '2025-02-20', 120.00, 40),
(1, '2025-03-20', 110.00, 35);

-- 4. Seed Users (API Task)
INSERT INTO Users (Username, Email, Password_Hash) VALUES
('admin', 'admin@linkfields.local', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'), -- Hash for 'password'
('analyst', 'analyst@linkfields.local', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');
