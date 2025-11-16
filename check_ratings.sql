-- Check Employee Ratings Script
-- Run this in a separate terminal with: psql -U your_username -d nestey -f check_ratings.sql

-- 1. Show all employee goals with their ratings
SELECT 
    eg.goal_id,
    eg.objective,
    eg.goal_description,
    eg.employee_rating,
    eg.manager_rating,
    eg.status,
    s.strategy_name,
    er.review_phase,
    er.review_status
FROM employee_goals eg
JOIN employee_reviews er ON eg.review_id = er.review_id
LEFT JOIN strategies s ON eg.strategy_id = s.strategy_id
WHERE er.employee_id = 301
ORDER BY eg.goal_id;

-- 2. Show only goals that have employee ratings
SELECT 
    eg.goal_id,
    eg.objective,
    eg.employee_rating,
    s.strategy_name,
    er.review_phase
FROM employee_goals eg
JOIN employee_reviews er ON eg.review_id = er.review_id
LEFT JOIN strategies s ON eg.strategy_id = s.strategy_id
WHERE er.employee_id = 301 
AND eg.employee_rating IS NOT NULL
ORDER BY eg.employee_rating DESC, eg.goal_id;

-- 3. Count of ratings by value
SELECT 
    employee_rating,
    COUNT(*) as count
FROM employee_goals eg
JOIN employee_reviews er ON eg.review_id = er.review_id
WHERE er.employee_id = 301 
AND eg.employee_rating IS NOT NULL
GROUP BY employee_rating
ORDER BY employee_rating;

-- 4. Show rating scale reference
SELECT 
    rating_value,
    rating_description
FROM rating_scale
ORDER BY rating_value;

-- 5. Recent rating updates (if updated_at column exists)
-- Uncomment the next query if you have an updated_at timestamp column
/*
SELECT 
    eg.goal_id,
    eg.objective,
    eg.employee_rating,
    eg.updated_at
FROM employee_goals eg
JOIN employee_reviews er ON eg.review_id = er.review_id
WHERE er.employee_id = 301 
AND eg.employee_rating IS NOT NULL
ORDER BY eg.updated_at DESC
LIMIT 10;
*/