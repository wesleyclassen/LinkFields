# Part 1: SQL Case Study Solutions

**Assessment:** Technical Business Analyst  
**Focus:** SQL Optimization, Performance, and Business Analytics  
**Date:** March 24, 2026

---

## Introduction

This document contains the SQL solutions for the Part 1 assessment, focusing on translating business problems into efficient, scalable, and correct SQL solutions within a telecom context.

---

## 1. Table Structures

The solutions assume the following database schema:

### Customers
- `Customer_ID` (Primary Key)
- `Name`
- `Signup_Date`
- `Email`
- `Segment` (Enterprise, Retail, SMB)

### Subscriptions
- `Subscription_ID` (Primary Key)
- `Customer_Id` (Foreign Key)
- `Plan_Type` (Basic, Premium)
- `Start_Date`
- `End_Date`

### Usage
- `Usage_ID` (Primary Key)
- `Customer_ID` (Foreign Key)
- `Date`
- `Data_Used_Mb`
- `Call_Minutes`

---

## 2. SQL Solutions

### Use Case 1: Sales Report Bottleneck
**Problem:** Slow performance when generating monthly revenue reports by customer segment and plan type.

#### SQL Query:
```sql
-- Optimization: Using CTEs to pre-aggregate usage and then joining.
-- This reduces the number of rows being joined if usage is high-volume.
WITH MonthlyRevenue AS (
    SELECT
        c.Customer_ID,
        c.Segment,
        s.Plan_Type,
        DATE_TRUNC('month', u.Date) AS Report_Month,
        -- Assuming fixed monthly revenue per plan type for this example
        CASE
            WHEN s.Plan_Type = 'Basic' THEN 10
            WHEN s.Plan_Type = 'Premium' THEN 30
            ELSE 20
        END as Revenue
    FROM Customers c
    JOIN Subscriptions s ON c.Customer_ID = s.Customer_Id
    JOIN Usage u ON c.Customer_ID = u.Customer_ID
    WHERE u.Date >= s.Start_Date AND (u.Date <= s.End_Date OR s.End_Date IS NULL)
    GROUP BY c.Customer_ID, c.Segment, s.Plan_Type, Report_Month
)
SELECT
    Segment,
    Plan_Type,
    Report_Month,
    SUM(Revenue) as Total_Revenue
FROM MonthlyRevenue
GROUP BY Segment, Plan_Type, Report_Month
ORDER BY Report_Month DESC, Total_Revenue DESC;
```

#### Approach & Logic:
1.  **Pre-Aggregation:** By using a Common Table Expression (CTE), we aggregate usage data by customer and month before performing the final summation. This prevents the join from becoming a bottleneck when dealing with millions of usage records.
2.  **Revenue Calculation:** We assign revenue based on the `Plan_Type` at the time of usage.
3.  **Indexing Strategy:** To ensure high performance, B-Tree indexes should be applied to `Usage(Customer_ID, Date)` and `Subscriptions(Customer_Id, Start_Date, End_Date)`.

---

### Use Case 2: Churn Prediction
**Problem:** Identify customer segments at high risk of cancelling based on declining usage or short subscription length.

#### SQL Query:
```sql
WITH UsageTrends AS (
    SELECT
        Customer_ID,
        DATE_TRUNC('month', Date) as Month,
        SUM(Data_Used_Mb) as Total_Data,
        SUM(Call_Minutes) as Total_Minutes,
        -- Compare current month usage with the previous month
        LAG(SUM(Data_Used_Mb)) OVER (PARTITION BY Customer_ID ORDER BY DATE_TRUNC('month', Date)) as Prev_Data
    FROM Usage
    GROUP BY Customer_ID, Month
),
ChurnFlags AS (
    SELECT
        ut.Customer_ID,
        ut.Month,
        CASE
            -- Flag 1: Declining usage (current < 70% of previous)
            WHEN ut.Total_Data < (ut.Prev_Data * 0.7) THEN 'Declining Usage'
            -- Flag 2: Short tenure (< 90 days)
            WHEN s.End_Date - s.Start_Date < INTERVAL '90 days' THEN 'Short Tenure'
            ELSE 'Stable'
        END as Churn_Risk
    FROM UsageTrends ut
    JOIN Subscriptions s ON ut.Customer_ID = s.Customer_Id
)
SELECT * FROM ChurnFlags WHERE Churn_Risk != 'Stable';
```

#### Approach & Logic:
1.  **Window Functions:** Utilizes the `LAG()` function to perform month-over-month usage comparisons without self-joining the table.
2.  **Multi-Factor Analysis:** Combines usage patterns (declining data consumption) with tenure data (short-term subscriptions) to create a more robust churn risk profile.
3.  **Efficiency:** Uses a single pass over the aggregated data to identify multiple risk factors.

---

### Use Case 3: Upsell Opportunities
**Problem:** Identify customers nearing their plan limits who may benefit from an upgrade.

#### SQL Query:
```sql
SELECT
    c.Name,
    s.Plan_Type,
    SUM(u.Data_Used_Mb) as Used_Mb,
    CASE
        WHEN s.Plan_Type = 'Basic' THEN 1000 -- Assumption: 1GB limit
        WHEN s.Plan_Type = 'Premium' THEN 5000 -- Assumption: 5GB limit
    END as Limit_Mb
FROM Customers c
JOIN Subscriptions s ON c.Customer_ID = s.Customer_Id
JOIN Usage u ON c.Customer_ID = u.Customer_ID
WHERE u.Date > CURRENT_DATE - INTERVAL '30 days' -- Last 30 days
GROUP BY c.Name, s.Plan_Type
-- Filter for those exceeding 90% of their limit
HAVING SUM(u.Data_Used_Mb) > (0.9 * 
    CASE 
        WHEN s.Plan_Type = 'Basic' THEN 1000 
        WHEN s.Plan_Type = 'Premium' THEN 5000 
    END
);
```

#### Approach & Logic:
1.  **Recent Usage Analysis:** Focuses on the last 30 days of data to provide timely insights.
2.  **Threshold Filtering:** The `HAVING` clause uses 90% as the "near-limit" threshold to identify high-conversion upsell candidates.
3.  **Business Insights:** Grouping by customer and highlighting those just under thresholds allows the sales team to prioritize outreach.

---

## 3. Performance Considerations

To ensure these queries scale to millions of rows:
1.  **Indexing:** Create composite indexes on `Usage(Customer_ID, Date)` and `Subscriptions(Customer_Id, Plan_Type)`.
2.  **Partitioning:** For very large usage tables, consider partitioning by `Date` (monthly) to improve range query performance.
3.  **Vacuum & Analyze:** Regular maintenance of the PostgreSQL environment is assumed to keep query planner statistics accurate.
