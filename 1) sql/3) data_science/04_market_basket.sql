-- MARKET BASKET ANALYSIS WITH PRODUCT NAMES
-- In this dataset every TransactionNumber is unique (each sales line has its own transaction number),
-- so pairing products by TransactionNumber never finds two products together.
-- A basket is therefore defined as all the products bought by the same customer on the same day.
-- Every product pair is stored in a materialized view, so its metrics can be explored (e.g. in the notebook)
-- without recomputing the self-join.
CREATE MATERIALIZED VIEW IF NOT EXISTS analytics.mv_product_pairs AS
WITH baskets AS (
    SELECT DISTINCT
        -- One basket per customer and day
        CustomerID,
        date,
        ProductID
    FROM analytics.fact_sales
    WHERE date IS NOT NULL
),

basket_sizes AS (
    SELECT
        CustomerID,
        date,
        COUNT(*) AS k
    FROM baskets
    GROUP BY CustomerID, date
),

totals AS (
    SELECT
        COUNT(*)         AS n_baskets,
        SUM(k)           AS n_items,
        -- A basket with k products holds k(k-1) ordered pairs: this is the room available for co-purchases
        SUM(k * (k - 1)) AS pair_slots
    FROM basket_sizes
),

product_support AS (
    -- Number of baskets that contain each product
    SELECT
        ProductID,
        COUNT(*) AS baskets_with_product
    FROM baskets
    GROUP BY ProductID
),

pairs AS (
    SELECT
        b1.ProductID AS product_a_id,
        b2.ProductID AS product_b_id,
        COUNT(*) AS times_bought_together
    FROM baskets b1
    -- Self-join inside each basket; b1 < b2 keeps every unordered pair once
    -- and never pairs a product with itself.
    JOIN baskets b2
        ON  b1.CustomerID = b2.CustomerID
        AND b1.date = b2.date
        AND b1.ProductID < b2.ProductID
    GROUP BY
        b1.ProductID,
        b2.ProductID
)

SELECT
    pr.product_a_id,
    p1.ProductName AS product_a,
    pr.product_b_id,
    p2.ProductName AS product_b,
    pr.times_bought_together,

    -- Support: share of all baskets that contain both products
    ROUND(pr.times_bought_together::numeric / t.n_baskets, 6) AS support,
    -- Confidence (A -> B): probability of buying B when A is in the basket
    ROUND(pr.times_bought_together::numeric / sa.baskets_with_product, 4) AS confidence_a_to_b,

    -- Expected co-purchases if products were combined at random, given the real basket sizes:
    -- share of A among basket items x share of B x the pair slots of all baskets.
    -- The classic lift formula assumes each product enters a basket independently, which does not hold
    -- when a visit has ~1.3 products (a 2-product basket always holds exactly one pair).
    ROUND(sa.baskets_with_product::numeric / t.n_items
          * sb.baskets_with_product / t.n_items * t.pair_slots, 2) AS expected_together,
    -- Lift: observed / expected. 1 = bought together by chance, > 1 = real affinity
    ROUND(pr.times_bought_together
          / (sa.baskets_with_product::numeric / t.n_items * sb.baskets_with_product / t.n_items * t.pair_slots), 4) AS lift

FROM pairs pr
CROSS JOIN totals t

JOIN product_support sa
    ON pr.product_a_id = sa.ProductID

JOIN product_support sb
    ON pr.product_b_id = sb.ProductID

JOIN analytics.dim_product p1
    ON pr.product_a_id = p1.ProductID

JOIN analytics.dim_product p2
    ON pr.product_b_id = p2.ProductID;


-- TOP 100 PAIRS BOUGHT TOGETHER
SELECT
    product_a,
    product_b,
    times_bought_together,
    support,
    confidence_a_to_b,
    lift
FROM analytics.mv_product_pairs
ORDER BY times_bought_together DESC
LIMIT 100;


-- STRONGEST ASSOCIATIONS
-- Pairs are filtered on the EXPECTED count, not the observed one: filtering on observed counts keeps
-- the pairs that were lucky and inflates their lift. With ~100k pairs tested, a high lift also needs a
-- multiple-comparison check before it is treated as a real affinity (see the notebook).
SELECT
    product_a,
    product_b,
    times_bought_together,
    expected_together,
    lift
FROM analytics.mv_product_pairs
WHERE expected_together >= 10
ORDER BY lift DESC
LIMIT 20;
