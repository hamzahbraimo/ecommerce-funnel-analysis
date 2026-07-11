# 1. The most expensive brands per category
SELECT
    brand, 
    category,
    SUM(price) AS total,
    RANK() OVER (ORDER BY SUM(price) DESC) AS rank_preco
FROM events
GROUP BY brand, category
ORDER BY category, total DESC;