"""
load_data.py
Loads Olist CSV files into a SQLite database (olist.db)
Run this script once before executing the SQL queries.
"""

import pandas as pd
import sqlite3
import os

DB_PATH = "olist.db"
DATA_PATH = "data"

# ── Tables to load ──────────────────────────────────────────
tables = {
    "orders":       "olist_orders_dataset.csv",
    "order_items":  "olist_order_items_dataset.csv",
    "products":     "olist_products_dataset.csv",
    "customers":    "olist_customers_dataset.csv",
    "reviews":      "olist_order_reviews_dataset.csv",
    "category_map": "product_category_name_translation.csv",
}

# ── Load ────────────────────────────────────────────────────
conn = sqlite3.connect(DB_PATH)

for table_name, filename in tables.items():
    filepath = os.path.join(DATA_PATH, filename)
    df = pd.read_csv(filepath)
    df.to_sql(table_name, conn, if_exists="replace", index=False)
    print(f"✅ Loaded '{table_name}' — {len(df):,} rows")

conn.close()
print(f"\n🎉 Database created: {DB_PATH}")
print("You can now run the SQL queries in analysis.sql")
