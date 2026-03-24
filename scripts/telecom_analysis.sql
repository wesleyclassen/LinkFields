-- Part 1: SQL Case Study Solutions

/*
Use Case 1: Sales Report Bottleneck
Objective: extract monthly revenue by customer segment and plan type with optimized performance.
Assumption: A 'Plan_Pricing' table exists or pricing is known. We will use a CTE for pricing.
           We also assume a 'Segment' column exists in Customers.
*/

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

/*
Performance Note:
- Index on Usage(Customer_ID, Date) is critical.
- Index on Subscriptions(Customer_Id, Start_Date, End_Date) helps in filtering valid subscriptions.
*/

/*
Use Case 2: Churn Prediction
Objective: Flag customers with declining usage or short subscription length.
*/

WITH UsageTrends AS (
    SELECT
        Customer_ID,
        DATE_TRUNC('month', Date) as Month,
        SUM(Data_Used_Mb) as Total_Data,
        SUM(Call_Minutes) as Total_Minutes,
        LAG(SUM(Data_Used_Mb)) OVER (PARTITION BY Customer_ID ORDER BY DATE_TRUNC('month', Date)) as Prev_Data
    FROM Usage
    GROUP BY Customer_ID, Month
),
ChurnFlags AS (
    SELECT
        ut.Customer_ID,
        ut.Month,
        CASE
            WHEN ut.Total_Data < (ut.Prev_Data * 0.7) THEN 'Declining Usage'
            WHEN s.End_Date - s.Start_Date < INTERVAL '90 days' THEN 'Short Tenure'
            ELSE 'Stable'
        END as Churn_Risk
    FROM UsageTrends ut
    JOIN Subscriptions s ON ut.Customer_ID = s.Customer_Id
)
SELECT * FROM ChurnFlags WHERE Churn_Risk != 'Stable';

/*
Use Case 3: Upsell Opportunities
Objective: Identify customers nearing their plan limits.
Assumption: Basic = 1000MB, Premium = 5000MB limit.
*/

SELECT
    c.Name,
    s.Plan_Type,
    SUM(u.Data_Used_Mb) as Used_Mb,
    CASE
        WHEN s.Plan_Type = 'Basic' THEN 1000
        WHEN s.Plan_Type = 'Premium' THEN 5000
    END as Limit_Mb
FROM Customers c
JOIN Subscriptions s ON c.Customer_ID = s.Customer_Id
JOIN Usage u ON c.Customer_ID = u.Customer_ID
WHERE u.Date > CURRENT_DATE - INTERVAL '30 days'
GROUP BY c.Name, s.Plan_Type
HAVING SUM(u.Data_Used_Mb) > (0.9 * CASE WHEN s.Plan_Type = 'Basic' THEN 1000 WHEN s.Plan_Type = 'Premium' THEN 5000 END);
