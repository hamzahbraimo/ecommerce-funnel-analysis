-- === VIEWS ===
-- 1. Users who spent more than $500
CREATE OR REPLACE VIEW vw_users_spent AS
SELECT
    user_id,
    ROUND(SUM(price), 2) total_spent
FROM events
GROUP BY user_id
HAVING total_spent >= 500;

SELECT * FROM vw_users_spent;


-- 2. Total views per brand (more than 1000)
CREATE OR REPLACE VIEW vw_brand_views AS
SELECT
    brand,
    COUNT(*) AS total_views
FROM events
WHERE brand != 'Unknown'
    AND event_type = 'view'
GROUP BY brand
HAVING total_views >= 1000
ORDER BY brand;

SELECT * FROM vw_brand_views;


-- 3. Average price per category ranked
CREATE OR REPLACE VIEW vw_avg_per_category AS
SELECT
    category,
    ROUND(AVG(price), 2) AS avg_price,
    DENSE_RANK() OVER(ORDER BY AVG(price) DESC) AS ranking
FROM events
GROUP BY category;

SELECT * FROM vw_avg_per_category;


-- 4. Last viewed product by user in a session
CREATE OR REPLACE VIEW vw_last_brand_seen AS
SELECT 
    t.user_id,
    t.user_session,
    t.last_viewed_brand,
    t.last_time_viewed
FROM (
    SELECT
        user_id,
        user_session,
        brand AS last_viewed_brand,
        event_time AS last_time_viewed,
        DENSE_RANK() OVER (
            PARTITION BY user_id, user_session
            ORDER BY event_time DESC
        ) AS rnk
    FROM events
    WHERE event_type = 'view'
) AS t
WHERE t.rnk = 1;

SELECT * FROM vw_last_brand_seen;


-- 5. Total purchased per category
CREATE OR REPLACE VIEW vw_total_per_cat AS
SELECT
    category,
    ROUND(SUM(price), 2) AS total_purchased
FROM events
WHERE event_type = 'purchase'
GROUP BY category;

SELECT * FROM vw_total_per_cat;