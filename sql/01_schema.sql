CREATE TABLE plans (
    plan_id INT PRIMARY KEY,
    plan_name TEXT,
    price_monthly NUMERIC,
    price_annual NUMERIC,
    tier TEXT,
    max_users INT
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    company_name TEXT,
    industry TEXT,
    country TEXT,
    company_size TEXT,
    signup_date DATE
);

CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    plan_id INT REFERENCES plans(plan_id),
    start_date DATE,
    end_date DATE,
    status TEXT,
    billing_cycle TEXT
);

CREATE TABLE churn_events (
    churn_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    churn_date DATE,
    churn_reason TEXT
);

CREATE TABLE discounts (
    discount_id INT PRIMARY KEY,
    subscription_id INT REFERENCES subscriptions(subscription_id),
    discount_percent INT,
    start_date DATE,
    end_date DATE
);

CREATE TABLE usage_events (
    event_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    feature_name TEXT,
    event_timestamp TIMESTAMP,
    usage_count INT
);

CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    invoice_date DATE,
    amount NUMERIC,
    status TEXT
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    invoice_id INT REFERENCES invoices(invoice_id),
    payment_date DATE,
    amount NUMERIC,
    payment_method TEXT
);
