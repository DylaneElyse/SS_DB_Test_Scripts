-- =====================================================
-- MODULAR EVENT MANAGEMENT TEST SCRIPT
-- =====================================================
-- This script is designed to be run incrementally.
-- Each section can be executed independently.
-- Uncomment the sections you want to run.
-- =====================================================

-- =====================================================
-- SECTION 1: CREATE NEW EVENT
-- =====================================================
-- Run this first to create a new event

INSERT INTO ss_events (name, start_date, end_date, location, discipline_id, status)
VALUES ('Modular Test Event', '2025-05-01', '2025-05-01', 'Modular Resort', 'FREE_SS_SBD', 'Scheduled');

-- Get the event ID for reference
SELECT 
    event_id,
    name,
    start_date,
    location,
    discipline_id,
    status
FROM ss_events 
WHERE name = 'Modular Test Event'
ORDER BY event_id DESC 
LIMIT 1;


-- =====================================================
-- SECTION 2: SET UP DIVISIONS AND ROUNDS
-- =====================================================
-- Replace XXX with your actual event_id from Section 1

-- Set your event ID here:
\set event_id XXX

INSERT INTO ss_event_divisions (event_id, division_id, num_rounds) VALUES
(303, 3, 2), -- Men: Qualifications + Finals
(303, 4, 2); -- Women: Qualifications + Finals

-- Verify the setup
SELECT 
    e.name,
    d.division_name,
    rd.round_name,
    rd.round_num,
    rd.num_heats,
    rd.num_athletes
FROM ss_events e
JOIN ss_round_details rd ON e.event_id = rd.event_id
JOIN ss_division d ON rd.division_id = d.division_id
WHERE e.event_id = 303
ORDER BY rd.division_id, rd.round_num DESC;


-- =====================================================
-- SECTION 3: UPDATE HEAT CONFIGURATION
-- =====================================================
-- Run after Section 2

-- Set your event ID here:
\set event_id XXX

-- Update men's qualifications to have 2 heats
UPDATE ss_round_details 
SET num_heats = 2 
WHERE event_id = 303 AND division_id = 3 AND round_name = 'Qualifications';

-- Set all heats to have 2 runs
UPDATE ss_heat_details 
SET num_runs = 2 
WHERE round_heat_id IN (
    SELECT hd.round_heat_id 
    FROM ss_heat_details hd
    JOIN ss_round_details rd ON hd.round_id = rd.round_id
    WHERE rd.event_id = 303
);

-- Verify heat configuration
SELECT 
    e.name,
    d.division_name,
    rd.round_name,
    rd.round_num,
    hd.heat_num,
    hd.num_runs,
    COUNT(hr.athlete_id) AS athletes_in_heat
FROM ss_events e
JOIN ss_round_details rd ON e.event_id = rd.event_id
JOIN ss_division d ON rd.division_id = d.division_id
JOIN ss_heat_details hd ON rd.round_id = hd.round_id
LEFT JOIN ss_heat_results hr ON hd.round_heat_id = hr.round_heat_id
WHERE e.event_id = 303
GROUP BY e.name, d.division_name, rd.round_name, rd.round_num, rd.division_id, hd.heat_num, hd.num_runs
ORDER BY rd.division_id, rd.round_num DESC, hd.heat_num;


-- =====================================================
-- SECTION 4: ASSIGN JUDGES TO ENTIRE EVENT
-- =====================================================
-- Run after Section 3

-- Set your event ID here:
\set event_id XXX

-- Add judges to the entire event
SELECT add_event_judge(303, 'Judge 2', 'Mike Chen');
SELECT add_event_judge(303, 'Judge 3', 'Emma Rodriguez');

-- Verify judge assignments
SELECT 
    e.name AS event_name,
    ej.header AS judge_role,
    ej.name AS judge_name,
    ej.passcode,
    COUNT(DISTINCT hj.round_heat_id) AS heats_assigned
FROM ss_events e
JOIN ss_event_judges ej ON e.event_id = ej.event_id
LEFT JOIN ss_heat_judges hj ON ej.personnel_id = hj.personnel_id
WHERE e.event_id = 303
GROUP BY ej.personnel_id, e.name, ej.header, ej.name, ej.passcode
ORDER BY ej.personnel_id;


-- =====================================================
-- SECTION 5: ASSIGN JUDGE TO SPECIFIC HEAT
-- =====================================================
-- Run after Section 4

-- Set your event ID here:
\set event_id XXX

-- Get a specific heat ID and add a specialized judge
DO $$
DECLARE
    v_event_id INTEGER := 303; -- Replace with your event_id
    v_specific_heat_id INTEGER;
BEGIN
    -- Get men's qualifications heat 1
    SELECT hd.round_heat_id INTO v_specific_heat_id
    FROM ss_heat_details hd
    JOIN ss_round_details rd ON hd.round_id = rd.round_id
    WHERE rd.event_id = v_event_id 
      AND rd.division_id = 3 
      AND rd.round_name = 'Qualifications'
      AND hd.heat_num = 1;
    
    -- Add specialized judge
    CALL add_heat_judge(v_specific_heat_id, 'Technical Judge', 'Alex Martinez');
    
    RAISE NOTICE 'Added Technical Judge to heat ID: %', v_specific_heat_id;
END $$;

-- Verify all judge assignments
SELECT 
    e.name AS event_name,
    ej.header AS judge_role,
    ej.name AS judge_name,
    COUNT(DISTINCT hj.round_heat_id) AS heats_assigned
FROM ss_events e
JOIN ss_event_judges ej ON e.event_id = ej.event_id
LEFT JOIN ss_heat_judges hj ON ej.personnel_id = hj.personnel_id
WHERE e.event_id = 303
GROUP BY ej.personnel_id, e.name, ej.header, ej.name
ORDER BY ej.personnel_id;


-- =====================================================
-- SECTION 6: INSERT ATHLETES (REQUIRED FIRST)
-- =====================================================
-- Run after Section 5 - Insert athletes before registering them

-- Register athletes
INSERT INTO ss_event_registrations (event_id, division_id, athlete_id, bib_num) VALUES
(303, 3, 2, 101),   -- Alejandro Adib-Samii
(303, 3, 4, 102),   -- Noah Avallone  
(303, 3, 7, 103),   -- Zachary Bezushko
(303, 3, 13, 104),  -- William Buffey
(303, 3, 14, 105),  -- Fynn Bullock-Womble
(303, 3, 15, 106),  -- Jonah Cantelon
(303, 4, 1, 201),   -- Kaitlyn Adams
(303, 4, 3, 202),   -- Sonora Alba
(303, 4, 8, 203),   -- Gabriella Boday
(303, 4, 10, 204),  -- Katie Brayer
(303, 4, 11, 205),  -- Giada Brienza
(303, 4, 19, 206);  -- Lola Cowan

-- Verify registrations and heat placements
SELECT 
    a.first_name || ' ' || a.last_name AS athlete_name,
    d.division_name,
    er.bib_num,
    rd.round_name,
    hd.heat_num,
    hr.seeding
FROM ss_event_registrations er
JOIN ss_athletes a ON er.athlete_id = a.athlete_id
JOIN ss_division d ON er.division_id = d.division_id
JOIN ss_heat_results hr ON er.event_id = hr.event_id 
    AND er.division_id = hr.division_id 
    AND er.athlete_id = hr.athlete_id
JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
JOIN ss_round_details rd ON hd.round_id = rd.round_id
WHERE er.event_id = 303
ORDER BY er.division_id, rd.round_num DESC, hd.heat_num, hr.seeding;


-- =====================================================
-- SECTION 7: ASSIGN QUALIFICATION SCORES - ALL 6 MEN
-- =====================================================
-- Run after Section 6

-- Set your event ID here:
\set event_id XXX

-- =====================================================
-- MEN'S QUALIFICATION SCORES - ALL 6 ATHLETES
-- =====================================================

-- Alejandro Adib-Samii (ID: 2, Bib: 101) - Run 1
CALL update_run_score(303, 'Alejandro', 'Adib-Samii', 'Qualifications', 1, 'Judge 2', 75.5);
CALL update_run_score(303, 'Alejandro', 'Adib-Samii', 'Qualifications', 1, 'Judge 3', 77.0);
CALL update_run_score(303, 'Alejandro', 'Adib-Samii', 'Qualifications', 1, 'Technical Judge', 76.5);

-- Alejandro Adib-Samii - Run 2
CALL update_run_score(303, 'Alejandro', 'Adib-Samii', 'Qualifications', 2, 'Judge 2', 82.0);
CALL update_run_score(303, 'Alejandro', 'Adib-Samii', 'Qualifications', 2, 'Judge 3', 83.5);
CALL update_run_score(303, 'Alejandro', 'Adib-Samii', 'Qualifications', 2, 'Technical Judge', 81.5);

-- Noah Avallone (ID: 4, Bib: 102) - Run 1
CALL update_run_score(303, 'Noah', 'Avallone', 'Qualifications', 1, 'Judge 2', 88.0);
CALL update_run_score(303, 'Noah', 'Avallone', 'Qualifications', 1, 'Judge 3', 89.5);
CALL update_run_score(303, 'Noah', 'Avallone', 'Qualifications', 1, 'Technical Judge', 87.5);

-- Noah Avallone - Run 2
CALL update_run_score(303, 'Noah', 'Avallone', 'Qualifications', 2, 'Judge 2', 85.5);
CALL update_run_score(303, 'Noah', 'Avallone', 'Qualifications', 2, 'Judge 3', 87.0);
CALL update_run_score(303, 'Noah', 'Avallone', 'Qualifications', 2, 'Technical Judge', 86.0);

-- Zachary Bezushko (ID: 7, Bib: 103) - Run 1
CALL update_run_score(303, 'Zachary', 'Bezushko', 'Qualifications', 1, 'Judge 2', 79.0);
CALL update_run_score(303, 'Zachary', 'Bezushko', 'Qualifications', 1, 'Judge 3', 80.5);
CALL update_run_score(303, 'Zachary', 'Bezushko', 'Qualifications', 1, 'Technical Judge', 78.5);

-- Zachary Bezushko - Run 2
CALL update_run_score(303, 'Zachary', 'Bezushko', 'Qualifications', 2, 'Judge 2', 84.0);
CALL update_run_score(303, 'Zachary', 'Bezushko', 'Qualifications', 2, 'Judge 3', 85.5);
CALL update_run_score(303, 'Zachary', 'Bezushko', 'Qualifications', 2, 'Technical Judge', 83.0);

-- William Buffey (ID: 13, Bib: 104) - Run 1
CALL update_run_score(303, 'William', 'Buffey', 'Qualifications', 1, 'Judge 2', 91.0);
CALL update_run_score(303, 'William', 'Buffey', 'Qualifications', 1, 'Judge 3', 92.5);
CALL update_run_score(303, 'William', 'Buffey', 'Qualifications', 1, 'Technical Judge', 90.5);

-- William Buffey - Run 2
CALL update_run_score(303, 'William', 'Buffey', 'Qualifications', 2, 'Judge 2', 89.5);
CALL update_run_score(303, 'William', 'Buffey', 'Qualifications', 2, 'Judge 3', 91.0);
CALL update_run_score(303, 'William', 'Buffey', 'Qualifications', 2, 'Technical Judge', 88.5);

-- Fynn Bullock-Womble (ID: 14, Bib: 105) - Run 1
CALL update_run_score(303, 'Fynn', 'Bullock-Womble', 'Qualifications', 1, 'Judge 2', 85.5);
CALL update_run_score(303, 'Fynn', 'Bullock-Womble', 'Qualifications', 1, 'Judge 3', 87.0);
CALL update_run_score(303, 'Fynn', 'Bullock-Womble', 'Qualifications', 1, 'Technical Judge', 86.0);

-- Fynn Bullock-Womble - Run 2
CALL update_run_score(303, 'Fynn', 'Bullock-Womble', 'Qualifications', 2, 'Judge 2', 83.0);
CALL update_run_score(303, 'Fynn', 'Bullock-Womble', 'Qualifications', 2, 'Judge 3', 84.5);
CALL update_run_score(303, 'Fynn', 'Bullock-Womble', 'Qualifications', 2, 'Technical Judge', 82.5);

-- Jonah Cantelon (ID: 15, Bib: 106) - Run 1
CALL update_run_score(303, 'Jonah', 'Cantelon', 'Qualifications', 1, 'Judge 2', 77.5);
CALL update_run_score(303, 'Jonah', 'Cantelon', 'Qualifications', 1, 'Judge 3', 79.0);
CALL update_run_score(303, 'Jonah', 'Cantelon', 'Qualifications', 1, 'Technical Judge', 78.0);

-- Jonah Cantelon - Run 2
CALL update_run_score(303, 'Jonah', 'Cantelon', 'Qualifications', 2, 'Judge 2', 81.0);
CALL update_run_score(303, 'Jonah', 'Cantelon', 'Qualifications', 2, 'Judge 3', 82.5);
CALL update_run_score(303, 'Jonah', 'Cantelon', 'Qualifications', 2, 'Technical Judge', 80.5);

-- =====================================================
-- WOMEN'S QUALIFICATION SCORES
-- =====================================================

-- Kaitlyn Adams (ID: 1, Bib: 201) - Run 1
CALL update_run_score(303, 'Kaitlyn', 'Adams', 'Qualifications', 1, 'Judge 2', 84.0);
CALL update_run_score(303, 'Kaitlyn', 'Adams', 'Qualifications', 1, 'Judge 3', 85.5);
-- CALL update_run_score(303, 'Kaitlyn', 'Adams', 'Qualifications', 1, 'Technical Judge', 83.5);

-- Kaitlyn Adams - Run 2
CALL update_run_score(303, 'Kaitlyn', 'Adams', 'Qualifications', 2, 'Judge 2', 87.0);
CALL update_run_score(303, 'Kaitlyn', 'Adams', 'Qualifications', 2, 'Judge 3', 88.5);
-- CALL update_run_score(303, 'Kaitlyn', 'Adams', 'Qualifications', 2, 'Technical Judge', 86.5);

-- Gabriella Boday (ID: 8, Bib: 203) - Run 1
CALL update_run_score(303, 'Gabriella', 'Boday', 'Qualifications', 1, 'Judge 2', 82.0);
CALL update_run_score(303, 'Gabriella', 'Boday', 'Qualifications', 1, 'Judge 3', 83.5);
-- CALL update_run_score(303, 'Gabriella', 'Boday', 'Qualifications', 1, 'Technical Judge', 81.5);

-- Gabriella Boday - Run 2
CALL update_run_score(303, 'Gabriella', 'Boday', 'Qualifications', 2, 'Judge 2', 85.0);
CALL update_run_score(303, 'Gabriella', 'Boday', 'Qualifications', 2, 'Judge 3', 86.5);
-- CALL update_run_score(303, 'Gabriella', 'Boday', 'Qualifications', 2, 'Technical Judge', 84.5);

-- View qualification results
SELECT 
    a.first_name || ' ' || a.last_name AS athlete_name,
    d.division_name,
    er.bib_num,
    hr.best AS best_score,
    ROW_NUMBER() OVER (PARTITION BY hr.division_id ORDER BY hr.best DESC NULLS LAST) AS rank
FROM ss_heat_results hr
JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
JOIN ss_round_details rd ON hd.round_id = rd.round_id
JOIN ss_event_registrations er ON hr.event_id = er.event_id 
    AND hr.division_id = er.division_id 
    AND hr.athlete_id = er.athlete_id
JOIN ss_athletes a ON hr.athlete_id = a.athlete_id
JOIN ss_division d ON hr.division_id = d.division_id
WHERE rd.event_id = 303 
  AND rd.round_name = 'Qualifications'
ORDER BY hr.division_id, hr.best DESC NULLS LAST;


-- =====================================================
-- SECTION 8: SET UP FINALS PROGRESSION
-- =====================================================
-- Run after Section 7

-- Set your event ID here:
\set event_id XXX

-- Set number of athletes to progress to finals
UPDATE ss_round_details 
SET num_athletes = 3 
WHERE event_id = 303 AND round_name = 'Finals' AND division_id = 4;

UPDATE ss_round_details 
SET num_athletes = 4 
WHERE event_id = 303 AND round_name = 'Finals' AND division_id = 3;


-- Verify finals setup
SELECT 
    e.name,
    d.division_name,
    rd.round_name,
    rd.num_athletes AS athletes_to_progress
FROM ss_events e
JOIN ss_round_details rd ON e.event_id = rd.event_id
JOIN ss_division d ON rd.division_id = d.division_id
WHERE e.event_id = 303 AND rd.round_name = 'Finals'
ORDER BY rd.division_id;


-- =====================================================
-- SECTION 9: PROGRESS FINALISTS
-- =====================================================
-- Run after Section 8

-- Set your event ID here:
\set event_id XXX

-- Progress finalists
DO $$
DECLARE
    v_event_id INTEGER := 303; -- Replace with your event_id
    v_mens_qual_round_id INTEGER;
    v_womens_qual_round_id INTEGER;
BEGIN
    -- Clean up any leftover temporary tables from previous runs
    DROP TABLE IF EXISTS expected_athletes;
    DROP TABLE IF EXISTS actual_athletes;
    
    -- Get qualification round IDs
    SELECT round_id INTO v_mens_qual_round_id 
    FROM ss_round_details 
    WHERE event_id = v_event_id AND division_id = 3 AND round_name = 'Qualifications';
    
    SELECT round_id INTO v_womens_qual_round_id 
    FROM ss_round_details 
    WHERE event_id = v_event_id AND division_id = 4 AND round_name = 'Qualifications';
    
    -- Progress finalists
    CALL progress_and_synchronize_round(v_mens_qual_round_id);
    CALL progress_and_synchronize_round(v_womens_qual_round_id);
    
    RAISE NOTICE 'Finalists have been progressed to finals';
END $$;

-- View finalists
SELECT 
    a.first_name || ' ' || a.last_name AS athlete_name,
    d.division_name,
    er.bib_num,
    hr.seeding AS finals_seed
FROM ss_heat_results hr
JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
JOIN ss_round_details rd ON hd.round_id = rd.round_id
JOIN ss_event_registrations er ON hr.event_id = er.event_id 
    AND hr.division_id = er.division_id 
    AND hr.athlete_id = er.athlete_id
JOIN ss_athletes a ON hr.athlete_id = a.athlete_id
JOIN ss_division d ON hr.division_id = d.division_id
WHERE rd.event_id = 303 
  AND rd.round_name = 'Finals'
ORDER BY hr.division_id, hr.seeding;


-- =====================================================
-- SECTION 10: ASSIGN FINALS SCORES
-- =====================================================
-- Run after Section 9
/*
-- Set your event ID here:
\set event_id XXX

-- Men's finals scores (only for athletes who progressed)
CALL update_run_score(303, 'William', 'Buffey', 'Finals', 1, 'Head Judge', 93.0);
CALL update_run_score(303, 'William', 'Buffey', 'Finals', 1, 'Judge 2', 94.5);
CALL update_run_score(303, 'William', 'Buffey', 'Finals', 1, 'Judge 3', 92.5);

CALL update_run_score(303, 'Noah', 'Avallone', 'Finals', 1, 'Head Judge', 89.0);
CALL update_run_score(303, 'Noah', 'Avallone', 'Finals', 1, 'Judge 2', 90.5);
CALL update_run_score(303, 'Noah', 'Avallone', 'Finals', 1, 'Judge 3', 88.5);

CALL update_run_score(303, 'Fynn', 'Bullock-Womble', 'Finals', 1, 'Head Judge', 84.0);
CALL update_run_score(303, 'Fynn', 'Bullock-Womble', 'Finals', 1, 'Judge 2', 85.5);
CALL update_run_score(303, 'Fynn', 'Bullock-Womble', 'Finals', 1, 'Judge 3', 83.5);

-- Women's finals scores (only for athletes who progressed)
CALL update_run_score(303, 'Kaitlyn', 'Adams', 'Finals', 1, 'Head Judge', 86.0);
CALL update_run_score(303, 'Kaitlyn', 'Adams', 'Finals', 1, 'Judge 2', 87.5);
CALL update_run_score(303, 'Kaitlyn', 'Adams', 'Finals', 1, 'Judge 3', 85.5);

CALL update_run_score(303, 'Gabriella', 'Boday', 'Finals', 1, 'Head Judge', 83.0);
CALL update_run_score(303, 'Gabriella', 'Boday', 'Finals', 1, 'Judge 2', 84.5);
CALL update_run_score(303, 'Gabriella', 'Boday', 'Finals', 1, 'Judge 3', 82.5);
*/

-- =====================================================
-- SECTION 11: VIEW FINAL RESULTS
-- =====================================================
-- Run after Section 10 to see results
/*
-- Set your event ID here:
\set event_id XXX

-- Men's Final Results
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
WHERE rd.event_id = 303 
  AND rd.division_id = 3 
  AND rd.round_name = 'Finals'
ORDER BY hr.best DESC NULLS LAST;

-- Women's Final Results
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
WHERE rd.event_id = 303 
  AND rd.division_id = 4 
  AND rd.round_name = 'Finals'
ORDER BY hr.best DESC NULLS LAST;
*/

-- =====================================================
-- SECTION 12: EVENT SUMMARY
-- =====================================================
-- Run anytime to get event statistics
/*
-- Set your event ID here:
\set event_id XXX

SELECT 
    'Event ID' AS metric, 
    303::TEXT AS value
UNION ALL
SELECT 
    'Total Judges', 
    COUNT(*)::TEXT 
FROM ss_event_judges 
WHERE event_id = 303
UNION ALL
SELECT 
    'Total Athletes', 
    COUNT(*)::TEXT 
FROM ss_event_registrations 
WHERE event_id = 303
UNION ALL
SELECT 
    'Total Scores', 
    COUNT(*)::TEXT 
FROM ss_run_scores rs
JOIN ss_run_results rr ON rs.run_result_id = rr.run_result_id
WHERE rr.event_id = 303 AND rs.score IS NOT NULL;
*/

-- =====================================================
-- USAGE INSTRUCTIONS:
-- =====================================================
-- 1. Uncomment Section 1 and run it first
-- 2. Note the event_id from the result
-- 3. Replace all XXX placeholders with your actual event_id
-- 4. Uncomment and run each subsequent section in order
-- 5. You can run sections multiple times or skip sections as needed
-- 6. Use Section 12 anytime to check event statistics
-- =====================================================
