# SQL Analysis

## Overview

This folder contains the SQL analysis performed on a CRM sales dataset using **PostgreSQL** and **DBeaver**.

The objective of the analysis was to transform raw CRM data into **actionable business insights** by examining the commercial process from multiple perspectives: opportunity lifecycle, sales funnel, products, customer accounts, sectors, and sales agents.

The analysis was designed to answer not only **what is happening**, but also **where performance gaps occur and where management should focus its resources**.

---

## Business Questions

The analysis was structured around the following key business questions:

1. **How does the sales pipeline perform across different stages?**
2. **How long does an opportunity take to move through the sales lifecycle?**
3. **Where is revenue being lost?**
4. **Which products drive the largest performance gaps?**
5. **Which customer sectors have the highest revenue leakage?**
6. **Which accounts generate the greatest commercial value and opportunity potential?**
7. **Which sales agents show the largest performance gaps?**
8. **Where should management prioritize sales resources to accelerate revenue growth?**

---

## Analytical Workflow

The SQL analysis follows a structured progression from data exploration to management recommendations:

```text
CRM Data
   ↓
Data Exploration & Validation
   ↓
Opportunity Lifecycle
   ↓
Sales Funnel
   ↓
Product Performance
   ↓
Sector Performance
   ↓
Account Analysis
   ↓
Sales Agent Performance
   ↓
Product × Sector Analysis
   ↓
Management Recommendations
```

---

# 01 — Data Exploration

The first step was to explore and validate the CRM dataset before performing the business analysis.

The analysis included:

* Dataset structure and available fields
* Number of opportunities
* Sales pipeline stages
* Product distribution
* Account distribution
* Sales agent distribution
* Sector distribution
* Data quality checks
* Missing and inconsistent values
* Date fields validation

The objective was to understand the structure and quality of the data and establish a reliable foundation for the following analyses.

---

# 02 — Opportunity Lifecycle Analysis

This analysis focuses on the **lifecycle of sales opportunities**, from initial engagement to the final outcome.

The analysis examines the relationship between:

* `engage_date`
* `close_date`
* `deal_stage`

Key areas of analysis include:

* Opportunity lifecycle duration
* Time between engagement and closure
* Differences in lifecycle across Won and Lost opportunities
* Open opportunities still in the pipeline
* Distribution of opportunities over time

### Business Objective

Understanding the opportunity lifecycle helps identify potential inefficiencies in the sales process.

Longer or significantly different sales cycles may indicate areas where opportunities require additional attention, follow-up, or process improvement.

---

# 03 — Sales Funnel Analysis

This analysis evaluates the performance of the commercial funnel across:

* **Won**
* **Lost**
* **Engaging**

Key metrics include:

* Opportunity volume
* Opportunity share by stage
* Win rate
* Lost rate
* Realized revenue
* Lost revenue potential
* Open pipeline potential

### Key Finding

The analysis identified approximately **€5M in lost revenue potential** across the sales pipeline.

This represents a significant opportunity for revenue growth through improved conversion.

The key business implication is that growth does not necessarily require generating more pipeline. A significant opportunity exists in **converting opportunities that are already entering the sales funnel**.

---

# 04 — Product Analysis

The product analysis evaluates commercial performance across the product portfolio.

Products were compared using:

* Opportunity volume
* Won opportunities
* Lost opportunities
* Win rate
* Realized revenue
* Lost revenue potential

### Key Findings

The analysis identified two distinct types of performance problems.

### MG Advanced — Volume Problem

MG Advanced generates a high number of opportunities but also experiences a significant number of losses.

The main opportunity is therefore to **improve conversion across a large opportunity base**.

### GTX Pro & GTX Plus Pro — Value Problem

GTX Pro and GTX Plus Pro have a stronger impact on potential revenue because individual opportunities carry greater commercial value.

The focus should therefore be on **protecting and converting high-value opportunities**.

This distinction allows management to avoid applying the same commercial strategy across the entire product portfolio.

---

# 05 — Sector Analysis

The sector analysis evaluates sales performance across customer sectors.

The analysis considers:

* Opportunity volume
* Won opportunities
* Lost opportunities
* Win rate
* Realized revenue
* Lost revenue potential

### Key Finding

**Retail, Technology, and Medical** emerged as the sectors with the highest revenue leakage.

These sectors therefore represent priority areas for further commercial investigation and targeted sales actions.

---

# 06 — Account Analysis

This analysis focuses on the **customer/account level** to understand how individual accounts contribute to the overall sales pipeline.

The analysis evaluates accounts based on factors such as:

* Number of opportunities
* Won opportunities
* Lost opportunities
* Win rate
* Realized revenue
* Lost revenue potential
* Sales activity

### Business Objective

The objective is to identify accounts that represent significant commercial value or potential and understand differences in customer-level performance.

This analysis allows the business to distinguish between:

* High-value accounts
* High-potential accounts
* Accounts with significant lost revenue
* Accounts with weaker conversion performance

The account-level analysis provides an additional layer of detail for prioritizing commercial actions.

---

# 07 — Sales Agent Analysis

The final performance analysis evaluates sales agents across multiple dimensions.

Sales agents were assessed using:

* Win rate
* Opportunity volume
* Won opportunities
* Lost opportunities
* Lost revenue potential
* Product mix

Rather than relying on a single KPI, the analysis combines multiple performance indicators to identify different types of sales-agent challenges.

### Business Objective

The goal is not simply to identify the lowest-performing sales agents.

Instead, the objective is to understand **why performance differs** and identify where targeted support, coaching, or resource allocation could have the greatest commercial impact.

---

# 08 — Product × Sector Analysis

The analysis was extended by combining **Product** and **Sector** dimensions.

This allows performance gaps to be analyzed at a more granular level and helps identify specific commercial combinations where revenue leakage is concentrated.

### Priority Combinations

The analysis identified the following combinations as priority areas:

* **MG Advanced × Medical**
* **MG Advanced × Retail**
* **MG Advanced × Technology**

These combinations combine significant opportunity volume with weaker conversion performance and therefore represent potential areas for targeted intervention.

---

# Key SQL Techniques

The analysis uses a range of PostgreSQL and SQL techniques, including:

* `SELECT`
* `WHERE`
* `GROUP BY`
* `ORDER BY`
* `CASE WHEN`
* `COUNT()`
* `SUM()`
* `AVG()`
* `ROUND()`
* `NULLIF()`
* `JOIN`
* `CTE`
* Aggregate calculations
* Percentage calculations
* Conversion-rate calculations
* Date calculations
* Conditional business logic

---

# Key Business Insights

The overall SQL analysis identified several important findings:

* Approximately **€5M of revenue potential is lost** across the sales pipeline.
* **MG Advanced** represents primarily a **volume-driven conversion problem**.
* **GTX Pro and GTX Plus Pro** represent a **value-driven performance problem**.
* **Retail, Technology, and Medical** show the highest levels of revenue leakage.
* **MG Advanced × Medical, Retail, and Technology** represent priority Product × Sector combinations.
* Account-level analysis helps identify customers with high commercial value or significant revenue leakage.
* Sales-agent performance should be assessed using multiple dimensions rather than win rate alone.
  
---

# Tools

* **PostgreSQL** — Database and SQL environment
* **DBeaver** — SQL development and data exploration
* **SQL** — Data analysis and business logic
* **Power BI** — Visualization and management dashboard
* **DAX** — Interactive KPIs and dynamic analysis

