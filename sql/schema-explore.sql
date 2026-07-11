# explore the events table
DESC events;

# number of events by type
SELECT
    event_type,
    COUNT(*) AS event_count
FROM events
GROUP BY event_type
ORDER BY event_type;

# number of events by category
SELECT
    category,
    COUNT(*) AS event_count
FROM events
GROUP BY category
ORDER BY category;
