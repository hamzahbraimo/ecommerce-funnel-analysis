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
    GROUP BY brand, category
)
SELECT * FROM count_views
WHERE ranking BETWEEN 1 AND 3;


-- 3. Top 25 users with the most expending
SELECT 
    user_id,
    ROUND(SUM(price), 2) AS total_spent,
    RANK() OVER (ORDER BY SUM(PRICE) DESC) AS ranking
FROM events
GROUP BY user_id
LIMIT 25;
