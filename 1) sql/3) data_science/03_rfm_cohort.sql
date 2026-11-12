-- RFM ANALYSIS (Recency, Frequency, Monetary) per customer
-- Saved as a view so the notebook and the BI tools share one definition.
-- Recency is measured against the last date in the data, not CURRENT_DATE: the dataset is historical.
CREATE OR REPLACE VIEW analytics.v_customer_rfm AS
WITH last_date AS (
    SELECT MAX(date) AS max_date 
    FROM analytics.fact_sales
),

rfm AS (
SELECT
    CustomerID,
    -- Recency: days between the customer's last purchase and the last date in the data
    last_date.max_date - MAX(f.date) AS recency_days,
    -- Frequency: number of visits per customer.
    -- Every TransactionNumber holds a single product line, so a visit is defined as a customer-day
    -- (the same definition used for the average ticket and the market basket).
    COUNT(DISTINCT f.date) AS frequency,
    -- Monetary: total revenue per customer
    SUM(f.revenue) AS monetary

FROM analytics.fact_sales f
-- last_date has a single row, so the cross join just puts max_date on every row
CROSS JOIN last_date
GROUP BY CustomerID, last_date.max_date
),

rfm_scores AS (
SELECT
    CustomerID,
    recency_days,
    frequency,
    monetary,

    -- Quintile scores, 1 = best: most recent, most frequent and highest-spending customers.
    -- NTILE splits ties arbitrarily, so customers with the same value can get adjacent scores.
    NTILE(5) OVER (ORDER BY recency_days ASC)  AS r_score,
    NTILE(5) OVER (ORDER BY frequency DESC)   AS f_score,
    NTILE(5) OVER (ORDER BY monetary DESC)    AS m_score

FROM rfm
)

SELECT
    CustomerID,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    -- RFM code, e.g. '112'
    CONCAT(r_score, f_score, m_score) AS rfm_code,

    -- Business segments built from the scores (remember: 1 = best)
    CASE
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Champions'
        WHEN r_score <= 3 AND f_score <= 2                  THEN 'Loyal Customers'
        WHEN r_score <= 2 AND f_score >= 4                  THEN 'New / Promising'
        WHEN r_score >= 4 AND f_score <= 2                  THEN 'At Risk'
        WHEN r_score >= 4 AND f_score >= 4                  THEN 'Hibernating'
        ELSE 'Need Attention'
    END AS rfm_segment

FROM rfm_scores;

SELECT *
FROM analytics.v_customer_rfm
ORDER BY monetary DESC;


-- COHORT ANALYSIS (monthly retention)
CREATE OR REPLACE VIEW analytics.v_cohort_retention AS
WITH first_purchase AS (
    SELECT
        CustomerID,
        -- Cohort = month of the customer's first purchase
        DATE_TRUNC('month', MIN(date))::date AS cohort_month
    FROM analytics.fact_sales
    -- Sales without a date cannot be placed in a cohort
    WHERE date IS NOT NULL
    GROUP BY CustomerID
),

monthly_orders AS (
    -- One row per customer and active month
    SELECT DISTINCT
        CustomerID,
        DATE_TRUNC('month', date)::date AS order_month
    FROM analytics.fact_sales
    WHERE date IS NOT NULL
),

cohort_activity AS (
    SELECT
        fp.cohort_month,
        mo.order_month,
        -- Months elapsed since the first purchase (0 = acquisition month)
        (EXTRACT(YEAR FROM AGE(mo.order_month, fp.cohort_month)) * 12
         + EXTRACT(MONTH FROM AGE(mo.order_month, fp.cohort_month)))::int AS month_number,
        COUNT(DISTINCT mo.CustomerID) AS customers
    FROM first_purchase fp
    JOIN monthly_orders mo
         ON fp.CustomerID = mo.CustomerID
    GROUP BY
        fp.cohort_month,
        mo.order_month
)

SELECT
    cohort_month,
    order_month,
    month_number,
    customers,
    -- Cohort size = customers active in the acquisition month (month_number = 0)
    FIRST_VALUE(customers) OVER (PARTITION BY cohort_month ORDER BY month_number) AS cohort_size,
    -- Retention rate: share of the cohort that bought again N months later
    ROUND(100.0 * customers
          / FIRST_VALUE(customers) OVER (PARTITION BY cohort_month ORDER BY month_number), 2) AS retention_pct
FROM cohort_activity;

SELECT *
FROM analytics.v_cohort_retention
ORDER BY
    cohort_month,
    order_month;