COPY plans FROM '/data/plans.csv' DELIMITER ',' CSV HEADER;
COPY customers FROM '/data/customers.csv' DELIMITER ',' CSV HEADER;
COPY subscriptions FROM '/data/subscriptions.csv' DELIMITER ',' CSV HEADER;
COPY churn_events FROM '/data/churn_events.csv' DELIMITER ',' CSV HEADER;
COPY discounts FROM '/data/discounts.csv' DELIMITER ',' CSV HEADER;
COPY usage_events FROM '/data/usage_events.csv' DELIMITER ',' CSV HEADER;
COPY invoices FROM '/data/invoices.csv' DELIMITER ',' CSV HEADER;
COPY payments FROM '/data/payments.csv' DELIMITER ',' CSV HEADER;
