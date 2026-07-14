-- 1. The most expensive brands per category
WITH total_por_brand AS (
    SELECT DISTINCT
        brand,
        category,
        price,
        DENSE_RANK() OVER(PARTITION BY category ORDER BY price DESC) AS ranking
    FROM events
    WHERE brand != 'Unknown'
)
SELECT * FROM total_por_brand
WHERE ranking = 1;


-- 2. The top 3 most viewed products per category
WITH count_views AS (
    SELECT
        brand,
        category,
        COUNT(brand) AS nr_views,
        DENSE_RANK() OVER(PARTITION BY category ORDER BY COUNT(brand) DESC) AS ranking
    FROM events
    WHERE brand != 'Unknown'
        AND event_type = 'view'
    GROUP BY brand, category
)
SELECT * FROM count_views
WHERE ranking BETWEEN 1 AND 3;


-- 3. Top 25 users with the most expending
WITH users AS (
    SELECT 
        user_id,
        ROUND(SUM(price), 2) AS total_spent,
        RANK() OVER (ORDER BY SUM(PRICE) DESC) AS ranking
    FROM events
    GROUP BY user_id
)
SELECT * FROM users
LIMIT 25;


-- 4. First viewed product per user in a session
WITH users_views AS (
    SELECT
        user_id,
        user_session,
        CONCAT(brand, " (", category, ")") AS first_viewed_product,
        ROW_NUMBER() OVER(PARTITION BY user_id, user_session) AS number 
    FROM events
    WHERE event_type = 'view'
)
SELECT
    user_id,
    user_session,
    first_viewed_product
FROM users_views
WHERE number = 1;


-- 5. Last event per session
WITH events AS (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY user_session ORDER BY event_time DESC) AS number   
    FROM events
)
SELECT * FROM events 
WHERE number = 1;
