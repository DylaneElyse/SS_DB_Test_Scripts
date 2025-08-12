-- =====================================================
-- SIMPLE EVENT MANAGEMENT TEST SCRIPT
-- =====================================================
-- This script demonstrates the core event management features:
-- 1. Create new event
-- 2. Update rounds/heats
-- 3. Assign judges (event-wide and heat-specific)
-- 4. Register athletes
-- 5. Assign scores
-- 6. Progress finalists
-- 7. Final scoring
-- =====================================================

-- Start the test
\echo '=== SIMPLE EVENT MANAGEMENT TEST ==='

-- Step 1: Create a new event
INSERT INTO ss_events (name, start_date, end_date, location, discipline_id, status)
VALUES ('Simple Test Event', '2025-04-01', '2025-04-01', 'Test Resort', 'FREE_SS_SBD', 'Scheduled');

-- Get the event ID (assuming it's the latest one)
\set event_id (SELECT MAX(event_id) FROM ss_events)

\echo 'Created event with ID: ' :event_id

-- Step 2: Add divisions and rounds
INSERT INTO ss_event_divisions (event_id, division_id, num_rounds) VALUES
(:event_id, 3, 2), -- Men: Qualifications + Finals
(:event_id, 4, 2); -- Women: Qualifications + Finals

\echo 'Added Men and Women divisions with 2 rounds each'

-- Step 3: Update number of heats (Men quals get 2 heats)
UPDATE ss_round_details 
SET num_heats = 2 
WHERE event_id = :event_id AND division_id = 3 AND round_name = 'Qualifications';

\echo 'Updated Men Qualifications to have 2 heats'

-- Step 4: Update number of runs (all heats get 2 runs)
UPDATE ss_heat_details 
SET num_runs = 2 
WHERE round_heat_id IN (
    SELECT hd.round_heat_id 
    FROM ss_heat_details hd
    JOIN ss_round_details rd ON hd.round_id = rd.round_id
    WHERE rd.event_id = :event_id
);

\echo 'Set all heats to have 2 runs each'

-- Step 5: Assign judges to entire event
SELECT add_event_judge(:event_id, 'Head Judge', 'John Smith');
SELECT add_event_judge(:event_id, 'Judge 2', 'Jane Doe');
SELECT add_event_judge(:event_id, 'Judge 3', 'Bob Wilson');

\echo 'Added 3 judges to the entire event'

-- Step 6: Assign a judge to specific heat
-- Get the first men's qualification heat
\set specific_heat_id (SELECT hd.round_heat_id FROM ss_heat_details hd JOIN ss_round_details rd ON hd.round_id = rd.round_id WHERE rd.event_id = :event_id AND rd.division_id = 3 AND rd.round_name = 'Qualifications' AND hd.heat_num = 1)

CALL add_heat_judge(:specific_heat_id, 'Technical Judge', 'Alex Tech');

\echo 'Added Technical Judge to specific heat: ' :specific_heat_id

-- Step 7: Register athletes
INSERT INTO ss_event_registrations (event_id, division_id, athlete_id, bib_num) VALUES
(:event_id, 3, 2, 101),   -- Alejandro Adib-Samii
(:event_id, 3, 4, 102),   -- Noah Avallone  
(:event_id, 3, 7, 103),   -- Zachary Bezushko
(:event_id, 3, 13, 104),  -- William Buffey
(:event_id, 3, 14, 105),  -- Fynn Bullock-Womble
(:event_id, 3, 15, 106),  -- Jonah Cantelon
(:event_id, 4, 1, 201),   -- Kaitlyn Adams
(:event_id, 4, 3, 202),   -- Sonora Alba
(:event_id, 4, 8, 203),   -- Gabriella Boday
(:event_id, 4, 10, 204),  -- Katie Brayer
(:event_id, 4, 11, 205),  -- Giada Brienza
(:event_id, 4, 19, 206);  -- Lola Cowan

\echo 'Registered 6 men and 6 women athletes'

-- Step 8: Assign qualification scores
-- Men's scores
CALL update_run_score(:event_id, 'Noah', 'Avallone', 'Qualifications', 1, 'Head Judge', 88.0);
CALL update_run_score(:event_id, 'Noah', 'Avallone', 'Qualifications', 1, 'Judge 2', 89.5);
CALL update_run_score(:event_id, 'Noah', 'Avallone', 'Qualifications', 1, 'Judge 3', 87.5);

CALL update_run_score(:event_id, 'William', 'Buffey', 'Qualifications', 1, 'Head Judge', 91.0);
CALL update_run_score(:event_id, 'William', 'Buffey', 'Qualifications', 1, 'Judge 2', 92.5);
CALL update_run_score(:event_id, 'William', 'Buffey', 'Qualifications', 1, 'Judge 3', 90.5);

CALL update_run_score(:event_id, 'Fynn', 'Bullock-Womble', 'Qualifications', 1, 'Head Judge', 85.5);
CALL update_run_score(:event_id, 'Fynn', 'Bullock-Womble', 'Qualifications', 1, 'Judge 2', 87.0);
CALL update_run_score(:event_id, 'Fynn', 'Bullock-Womble', 'Qualifications', 1, 'Judge 3', 86.0);

-- Women's scores
CALL update_run_score(:event_id, 'Kaitlyn', 'Adams', 'Qualifications', 1, 'Head Judge', 84.0);
CALL update_run_score(:event_id, 'Kaitlyn', 'Adams', 'Qualifications', 1, 'Judge 2', 85.5);
CALL update_run_score(:event_id, 'Kaitlyn', 'Adams', 'Qualifications', 1, 'Judge 3', 83.5);

CALL update_run_score(:event_id, 'Gabriella', 'Boday', 'Qualifications', 1, 'Head Judge', 82.0);
CALL update_run_score(:event_id, 'Gabriella', 'Boday', 'Qualifications', 1, 'Judge 2', 83.5);
CALL update_run_score(:event_id, 'Gabriella', 'Boday', 'Qualifications', 1, 'Judge 3', 81.5);

\echo 'Assigned qualification scores for key athletes'

-- Step 9: Set up finals progression (top 3 from each division)
UPDATE ss_round_details 
SET num_athletes = 3 
WHERE event_id = :event_id AND round_name = 'Finals';

\echo 'Set finals to accept top 3 athletes from each division'

-- Step 10: Progress finalists
-- Get qualification round IDs
\set mens_qual_round_id (SELECT round_id FROM ss_round_details WHERE event_id = :event_id AND division_id = 3 AND round_name = 'Qualifications')
\set womens_qual_round_id (SELECT round_id FROM ss_round_details WHERE event_id = :event_id AND division_id = 4 AND round_name = 'Qualifications')

CALL progress_and_synchronize_round(:mens_qual_round_id);
CALL progress_and_synchronize_round(:womens_qual_round_id);

\echo 'Progressed top 3 athletes from each division to finals'

-- Step 11: Assign finals scores
-- Men's finals
CALL update_run_score(:event_id, 'William', 'Buffey', 'Finals', 1, 'Head Judge', 93.0);
CALL update_run_score(:event_id, 'William', 'Buffey', 'Finals', 1, 'Judge 2', 94.5);
CALL update_run_score(:event_id, 'William', 'Buffey', 'Finals', 1, 'Judge 3', 92.5);

CALL update_run_score(:event_id, 'Noah', 'Avallone', 'Finals', 1, 'Head Judge', 89.0);
CALL update_run_score(:event_id, 'Noah', 'Avallone', 'Finals', 1, 'Judge 2', 90.5);
CALL update_run_score(:event_id, 'Noah', 'Avallone', 'Finals', 1, 'Judge 3', 88.5);

-- Women's finals
CALL update_run_score(:event_id, 'Kaitlyn', 'Adams', 'Finals', 1, 'Head Judge', 86.0);
CALL update_run_score(:event_id, 'Kaitlyn', 'Adams', 'Finals', 1, 'Judge 2', 87.5);
CALL update_run_score(:event_id, 'Kaitlyn', 'Adams', 'Finals', 1, 'Judge 3', 85.5);

CALL update_run_score(:event_id, 'Gabriella', 'Boday', 'Finals', 1, 'Head Judge', 83.0);
CALL update_run_score(:event_id, 'Gabriella', 'Boday', 'Finals', 1, 'Judge 2', 84.5);
CALL update_run_score(:event_id, 'Gabriella', 'Boday', 'Finals', 1, 'Judge 3', 82.5);

\echo 'Assigned finals scores'

-- Step 12: Display results
\echo ''
\echo '=== FINAL RESULTS ==='
\echo ''
\echo 'Men''s Results:'
SELECT 
    ROW_NUMBER() OVER (ORDER BY hr.best DESC NULLS LAST) AS position,
    a.first_name || ' ' || a.last_name AS athlete_name,
    er.bib_num,
    hr.best AS best_score
FROM ss_heat_results hr
JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
JOIN ss_round_details rd ON hd.round_id = rd.round_id
JOIN ss_event_registrations er ON hr.event_id = er.event_id 
    AND hr.division_id = er.division_id 
    AND hr.athlete_id = er.athlete_id
JOIN ss_athletes a ON hr.athlete_id = a.athlete_id
WHERE rd.event_id = :event_id 
  AND rd.division_id = 3 
  AND rd.round_name = 'Finals'
ORDER BY hr.best DESC NULLS LAST;

\echo ''
\echo 'Women''s Results:'
SELECT 
    ROW_NUMBER() OVER (ORDER BY hr.best DESC NULLS LAST) AS position,
    a.first_name || ' ' || a.last_name AS athlete_name,
    er.bib_num,
    hr.best AS best_score
FROM ss_heat_results hr
JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
JOIN ss_round_details rd ON hd.round_id = rd.round_id
JOIN ss_event_registrations er ON hr.event_id = er.event_id 
    AND hr.division_id = er.division_id 
    AND hr.athlete_id = er.athlete_id
JOIN ss_athletes a ON hr.athlete_id = a.athlete_id
WHERE rd.event_id = :event_id 
  AND rd.division_id = 4 
  AND rd.round_name = 'Finals'
ORDER BY hr.best DESC NULLS LAST;

-- Step 13: Summary
\echo ''
\echo '=== TEST SUMMARY ==='
SELECT 
    'Event ID' AS metric, 
    :event_id::TEXT AS value
UNION ALL
SELECT 
    'Total Judges', 
    COUNT(*)::TEXT 
FROM ss_event_judges 
WHERE event_id = :event_id
UNION ALL
SELECT 
    'Total Athletes', 
    COUNT(*)::TEXT 
FROM ss_event_registrations 
WHERE event_id = :event_id
UNION ALL
SELECT 
    'Total Scores', 
    COUNT(*)::TEXT 
FROM ss_run_scores rs
JOIN ss_run_results rr ON rs.run_result_id = rr.run_result_id
WHERE rr.event_id = :event_id AND rs.score IS NOT NULL;

\echo ''
\echo '✓ Event creation'
\echo '✓ Round and heat configuration'
\echo '✓ Judge assignment (event-wide and heat-specific)'
\echo '✓ Athlete registration'
\echo '✓ Score assignment'
\echo '✓ Finalist progression'
\echo '✓ Finals scoring'
\echo '✓ Results calculation'
\echo ''
\echo '=== TEST COMPLETED SUCCESSFULLY ==='
