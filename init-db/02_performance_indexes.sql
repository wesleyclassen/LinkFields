-- Migration V2: Performance & Optimization
-- Objective: Enhance query execution speed for high-volume analytics.

-- Optimize Usage queries (Churn and Upsell logic)
CREATE INDEX idx_usage_customer_date ON Usage(Customer_ID, Date);
CREATE INDEX idx_usage_date ON Usage(Date);

-- Optimize Subscription lookups
CREATE INDEX idx_subs_customer_status ON Subscriptions(Customer_Id, Status);
CREATE INDEX idx_subs_dates ON Subscriptions(Start_Date, End_Date);

-- Optimize Order management
CREATE INDEX idx_orders_customer_status ON Orders(Customer_ID, Status);

-- Optimize User management
CREATE INDEX idx_users_email ON Users(Email);
