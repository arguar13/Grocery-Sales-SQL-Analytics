*Read this in other languages: [Español](README_es.md)*
# Grocery Store Analytics | SQL & Data Engineering Project (Data Science)

## Project Description

This project implements an end-to-end analytical and data engineering workflow on a Grocery Store Sales dataset using PostgreSQL and Python, simulating real-world tasks of a Data Scientist / Analytics Engineer.

It covers the full pipeline from data modeling and ETL processes to advanced analytics and Python-based exploration, generating BI-ready datasets for tools such as Tableau or Power BI.

## Key Components

- PostgreSQL-based data engineering (schema, star model, ETL)
- Business KPIs and analytical queries
- Customer segmentation (RFM) and cohort analysis
- Market basket analysis and product insights
- Inventory and demand analysis
- Data quality validation
- Python integration for querying and EDA
- CSV exports for BI usage

## Dataset

The project uses a simulated Grocery Sales relational database with 7 tables:

- categories
- cities
- countries
- customers
- employees
- products
- sales

It includes transactional, customer, product, and geographic data suitable for SQL analytics, retail BI, and behavioral analysis.

Source: *Grocery Sales Database* by Andrex Ibiza, MBA, [Kaggle](https://www.kaggle.com/datasets/andrexibiza/grocery-sales-dataset) (CC0: Public Domain). Simulated sales from 2018-01-01 to 2018-05-09: ~6.7M sales lines, 98,759 customers, 452 products and 23 employees.

## Project Structure

```
├── data/                                   Raw CSV files (sales.csv must be downloaded, see below)
├── 1) sql/
│   ├── 1) Creation of the database and tables/   Transactional tables (01-07) + CSV load (08)
│   ├── 2) data_engineering/                      Star schema and ETL (analytics schema)
│   └── 3) data_science/                          KPIs, RFM, cohorts, basket, inventory, DQ, BI views
├── 2) Results ready for tableau/           CSV exports for Tableau
├── 3) notebooks/groceries shop.ipynb       Python + PostgreSQL analysis
├── ERD.png                                 Entity-relationship diagram
└── requirements.txt
```

## How to Run

1. Create the database: `CREATE DATABASE groceries_db;`
2. Run `1) sql/1) Creation of the database and tables/01` to `07` (tables with primary and foreign keys).
3. Download `sales.csv` (~500 MB, too large for GitHub) from the
   [Grocery Sales Database on Kaggle](https://www.kaggle.com/datasets/andrexibiza/grocery-sales-dataset) into `data/`,
   then load the CSV files from the repository root with psql:
   `psql -U postgres -d groceries_db -f "1) sql/1) Creation of the database and tables/08_load_data.sql"`
4. Run the scripts in `1) sql/2) data_engineering/` in order (01 → 06).
5. Run the scripts in `1) sql/3) data_science/` in order (01 → 07).
6. Open the notebook. Credentials are read from environment variables (`PGUSER`, `PGPASSWORD`, `PGHOST`, `PGPORT`, `PGDATABASE`); if `PGPASSWORD` is not set, the password is requested at runtime.

```bash
pip install -r requirements.txt
```

## Data Notes and Assumptions

- **Revenue is derived**: the source `TotalPrice` column is always `0`, so the ETL computes
  `revenue = Quantity × Price × (1 − Discount)` using the product price.
- **Missing dates**: ~1% of the sales have no `SalesDate`. They are kept in the fact table (they count in
  totals) but are excluded from time-based analyses (monthly trends, cohorts, recency).
- **Visit (basket) definition**: every `TransactionNumber` holds a single product line, so a visit is defined as
  *all products bought by the same customer on the same day*. The same definition drives the average ticket,
  RFM frequency, the time between visits and the market basket.
- **Partial month**: the data ends on 2018-05-09, so monthly comparisons use the average revenue per day with sales.
- `customers.csv` stores missing middle initials as the text `NULL`; the load script converts them to real NULLs.

## PostgreSQL: Data Engineering Layer

This layer builds an analytics-ready warehouse using dimensional modeling.

### Execution Order (`1) sql/2) data_engineering/`)

1. `01_schema.sql`
2. `02_dimensions.sql`
3. `03_fact_sales.sql`
4. `04_indexes.sql`
5. `05_etl_full_load.sql`
6. `06_etl_incremental.sql`

### Main Responsibilities

- Star-schema design with `fact_sales` and dimensions (date, product, customer, etc.)
- ETL pipelines (full and incremental loads)
- Indexing and performance optimization
- Data preparation for analytical workloads

## Analytics Layer: SQL Scripts

Built on top of the warehouse to generate insights and BI views.

### Scripts (`1) sql/3) data_science/`)

1. `01_materialized_views.sql`
2. `02_kpis.sql`
3. `03_rfm_cohort.sql`
4. `04_market_basket.sql`
5. `05_inventory.sql`
6. `06_data_quality.sql`
7. `07_tableau_views.sql`

### Focus Areas

- Business KPI generation (revenue, sales trends, units sold)
- Customer analytics (RFM, cohorts, behavior)
- Product performance and demand analysis
- Market basket analysis (product affinity)
- Inventory insights
- Data quality validation
- BI-ready views and reporting layers

## Key Analytical Components

### Materialized Views and Views
- Monthly sales by category, daily KPIs, top products, employee and country sales
- `v_customer_rfm`: RFM scores and segment per customer
- `v_cohort_retention`: monthly cohort retention
- `mv_product_pairs`: support, confidence and lift for every product pair
- `v_tableau_*`: BI-ready views

### Customer Analytics
- RFM scoring and segmentation (Champions, Loyal, At Risk, ...)
- Cohort analysis with monthly retention rates
- Purchase behavior patterns

### Product Analytics
- Best and low-performing products
- Demand trends over time

### Market Basket Analysis
- Product co-purchase relationships (support, confidence and lift)
- Cross-selling and recommendation insights

### Data Quality
- Detection of duplicates
- Missing values
- Invalid or inconsistent records

## Python Integration

Python connects to PostgreSQL using SQLAlchemy and pandas to simulate real analytical workflows.

### Main Tasks

- Database connection and querying
- Aggregations pushed down to PostgreSQL (only results are loaded into pandas)
- Exploratory Data Analysis with charts (monthly revenue per day, categories)
- Customer and product analytics
- RFM segments, cohort retention and market basket lift
- Time between visits
- Data validation checks and reconciliation of the BI views

## Key Findings

- **Scale**: 6,758,125 sales lines, 98,759 customers, 452 products and 23 employees over 129 days; total revenue 4,332,446,453.51.
- **Visits**: 5,203,059 visits (customer-days) with an average ticket of 824.37 and 1.29 lines per visit.
- **Stable demand**: revenue per day with sales stays between 33.19M and 33.31M in every month; May only looks smaller because it has 9 days of data.
- **Customers**: Champions are 8.0% of customers and 13.5% of revenue; customers come back after a median of 2 days (41.3% the next day).
- **Market basket**: the co-purchases of all 101,926 product pairs match what chance predicts (observed / expected = 1.002). No pair survives a Bonferroni correction (best adjusted p = 0.51), so there is no evidence for bundle recommendations.
- **Data quality**: 67,526 undated sales (1.00%), no duplicates or orphan keys, and the BI views reconcile with `fact_sales`.

## Key Results

- End-to-end SQL data warehouse
- Star-schema dimensional model
- Advanced customer segmentation (RFM)
- Cohort-based retention analysis
- Market basket insights
- Inventory and demand analytics
- Data quality framework
- Python + PostgreSQL integrated workflow
- BI-ready analytical outputs

## Author

**Armando Guarnera**  
Data Scientist, Argentina