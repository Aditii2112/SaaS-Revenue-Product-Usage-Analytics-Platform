--View 1: Monthly MRR
CREATE VIEW v_monthly_mrr AS
SELECT
    date_trunc('month', s.start_date) AS month,
    SUM(p.price_monthly) AS mrr
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE s.status = 'active'
  AND s.billing_cycle = 'monthly'
GROUP BY 1;


--View 2: ARR Snapshot
CREATE VIEW v_arr AS
SELECT
    SUM(
        CASE
            WHEN s.billing_cycle = 'monthly' THEN p.price_monthly * 12
            ELSE p.price_annual
        END
    ) AS arr
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE s.status = 'active';

--View 3: Monthly Churn Rate
CREATE VIEW v_monthly_churn AS
WITH churned AS (
    SELECT
        date_trunc('month', churn_date) AS month,
        COUNT(DISTINCT customer_id) AS churned_customers
    FROM churn_events
    GROUP BY 1
),
active AS (
    SELECT
        date_trunc('month', start_date) AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM subscriptions
    GROUP BY 1
)
SELECT
    a.month,
    COALESCE(c.churned_customers, 0) AS churned_customers,
    a.active_customers,
    ROUND(
        COALESCE(c.churned_customers, 0)::NUMERIC / a.active_customers,
        4
    ) AS churn_rate
FROM active a
LEFT JOIN churned c ON a.month = c.month;


--View 4: Retention Cohorts
CREATE VIEW v_retention_cohorts AS
WITH cohorts AS (
    SELECT
        customer_id,
        date_trunc('month', signup_date) AS cohort_month
    FROM customers
),
activity AS (
    SELECT
        c.cohort_month,
        date_trunc('month', u.event_timestamp) AS activity_month,
        COUNT(DISTINCT u.customer_id) AS active_customers
    FROM cohorts c
    JOIN usage_events u ON c.customer_id = u.customer_id
    GROUP BY 1, 2
)
SELECT * FROM activity;

--View 5: Feature Usage Summary
CREATE VIEW v_feature_usage AS
SELECT
    feature_name,
    COUNT(DISTINCT customer_id) AS active_customers,
    COUNT(*) AS total_events
FROM usage_events
GROUP BY feature_name;

--View 6: Plan Upgrade Funnel
CREATE VIEW v_plan_changes AS
SELECT
    customer_id,
    COUNT(DISTINCT plan_id) AS number_of_plans
FROM subscriptions
GROUP BY customer_id;

--View 7: Revenue by Plan
CREATE VIEW v_revenue_by_plan AS
SELECT
    p.plan_name,
    SUM(i.amount) AS total_revenue
FROM invoices i
JOIN subscriptions s ON i.customer_id = s.customer_id
JOIN plans p ON s.plan_id = p.plan_id
GROUP BY p.plan_name;

--View 8: Executive KPI Snapshot
CREATE VIEW v_company_kpis AS
SELECT
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM subscriptions WHERE status = 'active') AS active_subscriptions,
    (SELECT COUNT(*) FROM churn_events) AS churned_customers,
    (SELECT SUM(amount) FROM invoices) AS total_revenue;

-- Test View 1
SELECT * FROM v_plan_changes LIMIT 5;

-- Test View 2  
SELECT * FROM v_revenue_by_plan;

-- Test View 3
SELECT * FROM v_company_kpis;