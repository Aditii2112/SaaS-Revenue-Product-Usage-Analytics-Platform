import random
import pandas as pd
from faker import Faker
from datetime import timedelta

fake = Faker()
random.seed(42)

# ----------------------------
# CONFIG
# ----------------------------
NUM_CUSTOMERS = 1000
USAGE_EVENTS_PER_CUSTOMER = (50, 400)
START_DATE = pd.Timestamp("2023-01-01")
END_DATE = pd.Timestamp("2025-01-01")

# ----------------------------
# PLANS
# ----------------------------
plans = [
    {"plan_id": 1, "plan_name": "Free", "price_monthly": 0, "price_annual": 0, "tier": "Free", "max_users": 5},
    {"plan_id": 2, "plan_name": "Starter", "price_monthly": 29, "price_annual": 290, "tier": "Basic", "max_users": 10},
    {"plan_id": 3, "plan_name": "Pro", "price_monthly": 79, "price_annual": 790, "tier": "Growth", "max_users": 50},
    {"plan_id": 4, "plan_name": "Business", "price_monthly": 199, "price_annual": 1990, "tier": "Enterprise", "max_users": 200},
]

df_plans = pd.DataFrame(plans)

# ----------------------------
# CUSTOMERS
# ----------------------------
industries = ["Technology", "Finance", "Healthcare", "Education", "Retail"]
company_sizes = ["Small", "Mid", "Large"]
countries = ["USA", "Canada", "UK", "India"]

customers = []
for cid in range(1, NUM_CUSTOMERS + 1):
    customers.append({
        "customer_id": cid,
        "company_name": fake.company(),
        "industry": random.choice(industries),
        "country": random.choice(countries),
        "company_size": random.choice(company_sizes),
        "signup_date": fake.date_between(start_date=START_DATE, end_date=END_DATE)
    })

df_customers = pd.DataFrame(customers)

# ----------------------------
# SUBSCRIPTIONS
# ----------------------------
subscriptions = []
churn_events = []
discounts = []

subscription_id = 1
discount_id = 1
churn_id = 1

for _, customer in df_customers.iterrows():
    size = customer["company_size"]

    if size == "Small":
        plan_id = random.choices([1, 2, 3], weights=[0.3, 0.5, 0.2])[0]
    elif size == "Mid":
        plan_id = random.choices([2, 3, 4], weights=[0.4, 0.4, 0.2])[0]
    else:
        plan_id = random.choices([3, 4], weights=[0.4, 0.6])[0]

    billing_cycle = random.choices(["monthly", "annual"], weights=[0.7, 0.3])[0]
    start_date = pd.to_datetime(customer["signup_date"])

    churn_prob = {1: 0.35, 2: 0.25, 3: 0.12, 4: 0.05}[plan_id]
    churned = random.random() < churn_prob

    end_date = None
    status = "active"

    if churned:
        churn_date = start_date + timedelta(days=random.randint(60, 500))
        if churn_date < END_DATE:
            end_date = churn_date
            status = "canceled"
            churn_events.append({
                "churn_id": churn_id,
                "customer_id": customer["customer_id"],
                "churn_date": churn_date,
                "churn_reason": random.choice(
                    ["Too expensive", "Low usage", "Missing features", "Switched competitor"]
                )
            })
            churn_id += 1

    subscriptions.append({
        "subscription_id": subscription_id,
        "customer_id": customer["customer_id"],
        "plan_id": plan_id,
        "start_date": start_date,
        "end_date": end_date,
        "status": status,
        "billing_cycle": billing_cycle
    })

    # Discounts (20% chance)
    if random.random() < 0.2 and plan_id != 1:
        discounts.append({
            "discount_id": discount_id,
            "subscription_id": subscription_id,
            "discount_percent": random.choice([10, 20, 30]),
            "start_date": start_date,
            "end_date": start_date + timedelta(days=90)
        })
        discount_id += 1

    subscription_id += 1

df_subscriptions = pd.DataFrame(subscriptions)
df_churn = pd.DataFrame(churn_events)
df_discounts = pd.DataFrame(discounts)

# ----------------------------
# USAGE EVENTS
# ----------------------------
features = ["core", "analytics", "export", "api", "automation"]
usage_events = []
event_id = 1

for _, sub in df_subscriptions.iterrows():
    if sub["status"] == "canceled":
        last_date = sub["end_date"]
    else:
        last_date = END_DATE

    num_events = random.randint(*USAGE_EVENTS_PER_CUSTOMER)
    usage_multiplier = {1: 0.5, 2: 1, 3: 2, 4: 3}[sub["plan_id"]]

    for _ in range(int(num_events * usage_multiplier)):
        usage_events.append({
            "event_id": event_id,
            "customer_id": sub["customer_id"],
            "feature_name": random.choice(features),
            "event_timestamp": fake.date_time_between(
                start_date=sub["start_date"],
                end_date=last_date
            ),
            "usage_count": random.randint(1, 5)
        })
        event_id += 1

df_usage = pd.DataFrame(usage_events)

# ----------------------------
# INVOICES & PAYMENTS
# ----------------------------
invoices = []
payments = []

invoice_id = 1
payment_id = 1

for _, sub in df_subscriptions.iterrows():
    plan = df_plans[df_plans.plan_id == sub["plan_id"]].iloc[0]
    price = plan["price_monthly"] if sub["billing_cycle"] == "monthly" else plan["price_annual"]

    billing_gap = 30 if sub["billing_cycle"] == "monthly" else 365
    current_date = sub["start_date"]

    while current_date < (sub["end_date"] or END_DATE):
        invoices.append({
            "invoice_id": invoice_id,
            "customer_id": sub["customer_id"],
            "invoice_date": current_date,
            "amount": price,
            "status": "paid"
        })

        payments.append({
            "payment_id": payment_id,
            "invoice_id": invoice_id,
            "payment_date": current_date + timedelta(days=random.randint(0, 5)),
            "amount": price,
            "payment_method": random.choice(["credit_card", "bank_transfer"])
        })

        invoice_id += 1
        payment_id += 1
        current_date += timedelta(days=billing_gap)

df_invoices = pd.DataFrame(invoices)
df_payments = pd.DataFrame(payments)

# ----------------------------
# SAVE FILES
# ----------------------------
df_plans.to_csv("data/plans.csv", index=False)
df_customers.to_csv("data/customers.csv", index=False)
df_subscriptions.to_csv("data/subscriptions.csv", index=False)
df_usage.to_csv("data/usage_events.csv", index=False)
df_invoices.to_csv("data/invoices.csv", index=False)
df_payments.to_csv("data/payments.csv", index=False)
df_discounts.to_csv("data/discounts.csv", index=False)
df_churn.to_csv("data/churn_events.csv", index=False)

print("✅ SaaS data generation completed successfully!")
