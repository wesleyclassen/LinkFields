-- Migration V1: Base Schema Creation
-- Objective: Establish the foundation for Telecom and API systems.

-- Customers (Used in both Telecom & User Management contexts)
CREATE TABLE Customers (
    Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Signup_Date DATE DEFAULT CURRENT_DATE,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Segment VARCHAR(50) DEFAULT 'Retail',
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Subscriptions (Telecom specific)
CREATE TABLE Subscriptions (
    Subscription_ID SERIAL PRIMARY KEY,
    Customer_Id INT REFERENCES Customers(Customer_ID) ON DELETE CASCADE,
    Plan_Type VARCHAR(20) CHECK (Plan_Type IN ('Basic', 'Premium', 'Enterprise')),
    Start_Date DATE NOT NULL,
    End_Date DATE,
    Status VARCHAR(20) DEFAULT 'Active'
);

-- Usage (Telecom specific)
CREATE TABLE Usage (
    Usage_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID) ON DELETE CASCADE,
    Date DATE NOT NULL,
    Data_Used_Mb DECIMAL(10, 2) DEFAULT 0.00,
    Call_Minutes INT DEFAULT 0
);

-- Users (API Task specific)
CREATE TABLE Users (
    User_ID SERIAL PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Password_Hash VARCHAR(255) NOT NULL,
    Is_Active BOOLEAN DEFAULT TRUE,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Updated_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders (API Task specific)
CREATE TABLE Orders (
    Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID) ON DELETE SET NULL,
    Status VARCHAR(20) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled')),
    Total_Amount DECIMAL(12, 2) DEFAULT 0.00,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Updated_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
