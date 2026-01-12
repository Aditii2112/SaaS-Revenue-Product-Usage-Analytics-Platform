CREATE INDEX idx_customers_signup_date ON customers(signup_date);

CREATE INDEX idx_subscriptions_customer ON subscriptions(customer_id);
CREATE INDEX idx_subscriptions_plan ON subscriptions(plan_id);
CREATE INDEX idx_subscriptions_start_date ON subscriptions(start_date);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

CREATE INDEX idx_churn_customer ON churn_events(customer_id);
CREATE INDEX idx_churn_date ON churn_events(churn_date);

CREATE INDEX idx_usage_customer ON usage_events(customer_id);
CREATE INDEX idx_usage_feature ON usage_events(feature_name);
CREATE INDEX idx_usage_time ON usage_events(event_timestamp);

CREATE INDEX idx_invoices_customer ON invoices(customer_id);
CREATE INDEX idx_invoices_date ON invoices(invoice_date);

CREATE INDEX idx_payments_invoice ON payments(invoice_id);
