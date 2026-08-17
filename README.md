Healthcare Patient Analytics - SQL and Power BI

Project Overview

This project analyzes 55,500 patient admission records to find insights on hospital performance, billing trends, and patient demographics. The data was cleaned and queried using SQL, then visualized in an interactive 4-page Power BI dashboard.

Tools Used

MySQL - data cleaning, joins, CTEs, subqueries, window functions
Power BI - data modeling, DAX measures, drillthrough, AI visual

Dataset

The 55,500 patient records were split into two related tables.
patients.csv holds demographic and clinical information.
admissions.csv holds hospital visit and billing details.
Source - Kaggle Healthcare Dataset.

SQL Analysis

The file healthcare_sql_practice.sql includes the following.
INNER JOIN and LEFT JOIN across the patients and admissions tables.
Aggregations using GROUP BY and HAVING.
Subqueries, including correlated subqueries.
CTEs for multi step calculations.
Window functions such as RANK, DENSE_RANK, and running counts.
CASE based segmentation for age groups and billing tiers.

Power BI Dashboard

The dashboard has 4 pages.
Overview - KPI cards, billing trends, hospital and demographic breakdown.
Hospital Performance - a ranked hospital leaderboard built using DAX RANKX.
Financial Analysis - a drillthrough page showing hospital level financial detail.
Patient Demographics - an AI powered Decomposition Tree analysis.

Key Insights

Revenue is spread fairly evenly across the top 15 to 20 hospitals, showing no single dominant hospital and a well balanced patient network.
Admission types such as Elective, Emergency, and Urgent are almost evenly split, each around 18,000 to 19,000 cases.
Chronic conditions such as Hypertension, Diabetes, and Arthritis account for a large share of billing across the top hospitals.


healthcare_sql_practice.sql contains all SQL queries.
Healthcare_Analytics_Dashboard.pbix is the Power BI file.
The screenshots folder contains images of each dashboard page.
