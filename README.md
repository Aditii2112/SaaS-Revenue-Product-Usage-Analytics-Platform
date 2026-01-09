# SaaS-Revenue-Product-Usage-Analytics-Platform
This project is an end-to-end SQL-driven analytics platform built to analyze revenue growth, customer churn, and product usage for a fictional SaaS company.

The goal is to demonstrate:

strong relational data modeling

advanced SQL analytics (MRR, churn, cohorts)

dashboard-ready data pipelines

real-world business insights used by product and leadership teams

The system closely mirrors how analytics is done inside modern SaaS companies.

#**Architecture**

Synthetic Data (Python)
        ↓
PostgreSQL (Normalized Schema)
        ↓
SQL Views (Analytics Layer)
        ↓
Dashboards 


# Key Design Principles

SQL-first analytics (no heavy ML)

Normalized schema for data integrity

Reusable SQL views for dashboards

Performance-aware design with indexes

Clear separation between raw data and analytics layer

# Database Schema

**Core Tables**

customers – company profile and signup metadata

plans – pricing tiers and plan limits

subscriptions – customer lifecycle and billing info

usage_events – granular product usage data

invoices – revenue records

payments – payment transactions

discounts – promotional discounts

churn_events – churn timing and reasons

# Why This Schema Works

Models real SaaS business logic

Supports time-series analysis

Enables cohort and funnel analytics

Scales well for large usage-event volumes

# Analytics Layer (SQL Views) 
Dashboards are built on top of curated SQL views instead of raw tables.

**Key Views**

v_monthly_mrr – Monthly Recurring Revenue trends

v_arr – Annual Recurring Revenue snapshot

v_monthly_churn – Churn rate over time

v_retention_cohorts – Customer retention cohorts

v_feature_usage – Feature adoption and engagement

v_revenue_by_plan – Revenue contribution by plan

v_company_kpis – Executive-level metrics

This approach reflects real analytics engineering practices.

# How to Run

Generate synthetic data:

python generate_data.py


Create tables in PostgreSQL:

\i create_tables.sql


Load CSVs using COPY

Create views:

\i views.sql


Connect dashboards to PostgreSQL
