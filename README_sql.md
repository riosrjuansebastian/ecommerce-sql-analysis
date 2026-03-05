# 🗄️ E-Commerce SQL Analysis — Olist Dataset

**Tools:** SQL · SQLite · Python (data loading)  
**Author:** Sebastian Rios · [LinkedIn](https://linkedin.com/in/juansebastianrios)  
**Related project:** [E-Commerce EDA with Python & Power BI](https://github.com/juansrios/ecommerce-sales-analysis)

---

## Business Problem

Using the same Olist e-commerce dataset (100,000+ orders), this project answers 10 key business questions using SQL — progressing from basic aggregations to advanced window functions and CTEs.

---

## Query Index

| # | Business Question | SQL Concepts |
|---|-------------------|--------------|
| 1 | Order distribution by status | SELECT, GROUP BY, Window |
| 2 | Top 10 revenue categories | JOIN, GROUP BY, ORDER BY |
| 3 | Monthly revenue trend | STRFTIME, JOIN, GROUP BY |
| 4 | Top states by volume & ticket | Multi-JOIN, GROUP BY |
| 5 | Delivery time vs review score | JULIANDAY, JOIN, GROUP BY |
| 6 | Categories with low satisfaction | Multi-JOIN, HAVING |
| 7 | On-time vs late deliveries | CASE WHEN, Window |
| 8 | Revenue ranking by category | CTE, RANK(), Running total |
| 9 | Month-over-month growth | CTE, LAG(), Growth % |
| 10 | Customer value segmentation | CTE, CASE WHEN, RFM logic |

---

## Project Structure

```
📁 ecommerce-sql-analysis/
├── 📄 analysis.sql       ← 10 business queries
├── 🐍 load_data.py       ← Loads CSVs into SQLite
├── 📄 README.md
└── 📁 data/
    └── dataset_source.txt
```

---

## How to Run

```bash
# 1. Clone the repo
git clone https://github.com/juansrios/ecommerce-sql-analysis

# 2. Install dependencies
pip install pandas

# 3. Download dataset from Kaggle and place CSVs in /data
# https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

# 4. Create the SQLite database
python load_data.py

# 5. Open analysis.sql in VS Code with SQLite Viewer extension
#    Open olist.db → run queries individually
```

---

## Key Findings

| Finding | Query |
|---------|-------|
| Health & Beauty is the #1 revenue category | Q2 |
| Orders delivered in under 10 days get 5-star reviews 57% of the time | Q5 |
| ~8% of delivered orders arrive after the estimated date | Q7 |
| Top 3 categories account for ~25% of total revenue | Q8 |
| SP and RJ represent 50%+ of order volume | Q4 |

---

## Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

*Part of my data analysis portfolio — [view all projects](https://github.com/juansrios)*
