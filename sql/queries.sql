--Monthly Recurring Revenue (MRR)

SELECT
    date_trunc('month', s.start_date) AS month,
    SUM(p.price_monthly) AS mrr
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE s.status = 'active'
  AND s.billing_cycle = 'monthly'
GROUP BY 1
ORDER BY 1;

--Annual Recurring Revenue (ARR)
SELECT
    SUM(
        CASE
            WHEN billing_cycle = 'monthly' THEN p.price_monthly * 12
            ELSE p.price_annual
        END
    ) AS arr
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE s.status = 'active';

--Revenue by Plan Tier

SELECT
    p.tier,
    SUM(i.amount) AS total_revenue
FROM invoices i
JOIN subscriptions s ON i.customer_id = s.customer_id
JOIN plans p ON s.plan_id = p.plan_id
GROUP BY p.tier
ORDER BY total_revenue DESC;

--Monthly Churn Rate
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
    churned_customers,
    active_customers,
    ROUND(churned_customers::NUMERIC / active_customers, 3) AS churn_rate
FROM active a
LEFT JOIN churned c ON a.month = c.month
ORDER BY a.month;


--Churn by Plan
SELECT
    p.plan_name,
    COUNT(c.customer_id) AS churned_customers
FROM churn_events c
JOIN subscriptions s ON c.customer_id = s.customer_id
JOIN plans p ON s.plan_id = p.plan_id
GROUP BY p.plan_name
ORDER BY churned_customers DESC;

--Customer Retention Cohorts

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
SELECT
    cohort_month,
    activity_month,
    active_customers
FROM activity
ORDER BY cohort_month, activity_month;

--Feature Adoption Ranking
SELECT
    feature_name,
    COUNT(DISTINCT customer_id) AS active_customers,
    COUNT(*) AS total_events
FROM usage_events
GROUP BY feature_name
ORDER BY active_customers DESC;

--Feature Usage vs Churn

SELECT
    u.feature_name,
    COUNT(DISTINCT u.customer_id) AS total_users,
    COUNT(DISTINCT c.customer_id) AS churned_users
FROM usage_events u
LEFT JOIN churn_events c
    ON u.customer_id = c.customer_id
GROUP BY u.feature_name
ORDER BY churned_users DESC;

--Customers Who Changed Plans (Upgrade/Downgrade Funnel)
SELECT
    customer_id,
    COUNT(DISTINCT plan_id) AS number_of_plans
FROM subscriptions
GROUP BY customer_id
HAVING COUNT(DISTINCT plan_id) > 1;

--Time to Churn (Customer Lifetime)
SELECT
    c.customer_id,
    churn_date - signup_date AS days_to_churn
FROM churn_events c
JOIN customers cu ON c.customer_id = cu.customer_id
ORDER BY days_to_churn;


--Discount Usage Impact
SELECT
    d.discount_percent,
    COUNT(DISTINCT s.customer_id) AS customers,
    SUM(i.amount) AS discounted_revenue
FROM discounts d
JOIN subscriptions s ON d.subscription_id = s.subscription_id
JOIN invoices i ON s.customer_id = i.customer_id
GROUP BY d.discount_percent
ORDER BY d.discount_percent;

--One-Row Company Health Snapshot
SELECT
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM subscriptions WHERE status = 'active') AS active_subscriptions,
    (SELECT COUNT(*) FROM churn_events) AS churned_customers,
    (SELECT SUM(amount) FROM invoices) AS total_revenue;
