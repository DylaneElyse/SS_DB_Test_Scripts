-- Check what athletes exist in the database
SELECT 
    athlete_id,
    first_name,
    last_name,
    gender
FROM ss_athletes 
WHERE athlete_id IN (1, 2, 3, 4, 7, 8, 10, 11, 13, 14, 15, 19)
ORDER BY athlete_id;

-- If no results, check if any athletes exist at all
SELECT COUNT(*) as total_athletes FROM ss_athletes;

-- Show first 20 athletes if they exist
SELECT 
    athlete_id,
    first_name,
    last_name,
    gender
FROM ss_athletes 
ORDER BY athlete_id
LIMIT 20;
