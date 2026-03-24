# Technical Business Analyst Assessment: LinkFields

**Candidate:** Wesley Classen  
**Date:** March 24, 2026  
**Focus:** SQL Optimization, API Orchestration, and System Design

---

## Assessment Overview

This repository contains a comprehensive response to the LinkFields Technical Business Analyst Assessment. The solution is architected to demonstrate:
- **Data Strategy:** High-performance SQL for telecom analytics.
- **API Excellence:** Swagger-first design and RESTful principles.
- **DevOps Ready:** Containerized environment for immediate stakeholder review.

---

## Technology Stack

- **Engine:** PostgreSQL 15 (Relational Data & Analytics)
- **API Documentation:** OpenAPI 3.0.3 (Swagger)
- **Environment:** Docker & Docker Compose
- **Tools:** SQL (Window Functions & CTEs)

---

## Part 1: SQL Case Study Solutions

The SQL solutions are located in [`scripts/telecom_analysis.sql`](scripts/telecom_analysis.sql).

### Use Case 1: Sales Report Bottleneck
- **Objective:** Extract monthly revenue by customer segment and plan type.
- **Strategy:** Utilized Aggregated CTEs to pre-summarize usage data before joining with the Customer master. This minimizes the memory footprint of join operations on large datasets.
- **Assumption:** Monthly revenue is derived from a fixed cost per `Plan_Type`.
- **Optimization:** Added B-Tree indexes on `Customer_ID` and `Date` in the `Usage` table to speed up temporal aggregations.

### Use Case 2: Churn Prediction
- **Logic:** Implements a 3-Month Rolling Average comparison using `LAG()` window functions.
- **Threshold:** Flags any customer whose current month data usage is < 70% of their previous month's usage, or who has a subscription length of less than 90 days.
- **Business Value:** Provides an actionable "At-Risk" list for proactive retention campaigns.

### Use Case 3: Upsell Opportunities
- **Logic:** Identifies users who have consumed more than 90% of their plan's data limit within the last 30 days.
- **Assumption:** 'Basic' plans have a 1GB limit, while 'Premium' plans have a 5GB limit.

---

## Part 2: API Case Studies (Selected Tasks)

### Task 3: Database Integration
- I have implemented a normalized schema in [`init-db/01_schema.sql`](init-db/01_schema.sql) to support User Management and Order tracking.
- **Constraint Logic:** Enforces unique email/username constraints and foreign key integrity.

### Task 5: API Design (Swagger-First Approach)
- The **Order Management API** was designed using the Swagger-First approach.
- **Spec Location:** [`swagger/spec.yaml`](swagger/spec.yaml)
- **Endpoints:**
  - `POST /orders`: Create new customer orders.
  - `GET /orders`: Retrieve order history.
  - `PATCH /orders/{id}/status`: Transition orders through various states (Pending, Shipped, Delivered, Cancelled).

---

## Step-by-Step Setup Instructions

### 1. Prerequisites
Ensure you have the following installed:
- [Docker & Docker Compose](https://docs.docker.com/get-docker/)
- [Git](https://git-scm.com/)

### 2. Installation
```bash
# Clone the repository
git clone https://github.com/wesleyclassen/LinkFields.git
cd LinkFields

# Launch the environment
docker-compose up -d
```

### 3. Accessing the Assessment Assets
- **Interactive API Docs:** Navigate to [http://localhost:8080](http://localhost:8080) to view the Order Management API specification.
- **Database Access:** Connect to the PostgreSQL instance:
  - **Host:** `localhost` | **Port:** `5432`
  - **User:** `admin` | **Password:** `password123` | **DB:** `telecom_db`
- **Run Analytics:** Execute the scripts in `scripts/telecom_analysis.sql` using any SQL client (e.g., DBeaver, pgAdmin).

---

## Strategic Assumptions

1. **Data Volume:** Queries are designed for tables exceeding 10M rows, prioritizing indexed lookups over full table scans.
2. **Revenue Model:** Monthly revenue is calculated based on active subscriptions during the reporting period, assuming a flat fee per plan type.
3. **Telecom Context:** "Usage" is tracked at a daily granularity for both data (MB) and voice (Minutes).
