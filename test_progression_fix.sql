-- Test the fixed progression procedure for event 303

-- First, let's see the current qualification results
SELECT 
    ROW_NUMBER() OVER (ORDER BY hr.best DESC NULLS LAST) AS rank,
    a.first_name || ' ' || a.last_name AS athlete_name,
    er.bib_num,
    hr.best AS best_score,
    hd.heat_num,
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY hr.best DESC NULLS LAST) <= 4 
        THEN '✓ SHOULD QUALIFY' 
        ELSE 'Should be eliminated' 
    END AS expected_status
FROM ss_heat_results hr
JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
JOIN ss_round_details rd ON hd.round_id = rd.round_id
JOIN ss_event_registrations er ON hr.event_id = er.event_id 
    AND hr.division_id = er.division_id 
    AND hr.athlete_id = er.athlete_id
JOIN ss_athletes a ON hr.athlete_id = a.athlete_id
WHERE rd.event_id = 303 
  AND rd.division_id = 3 
  AND rd.round_name = 'Qualifications'
ORDER BY hr.best DESC NULLS LAST;

-- Now run the progression
DO $$
DECLARE
    v_mens_qual_round_id INTEGER;
BEGIN
    -- Get men's qualification round ID
    SELECT round_id INTO v_mens_qual_round_id 
    FROM ss_round_details 
    WHERE event_id = 303 AND division_id = 3 AND round_name = 'Qualifications';
    
    RAISE NOTICE 'Running progression for men''s qualifications (round ID: %)', v_mens_qual_round_id;
    
    -- Progress finalists
    CALL progress_and_synchronize_round(v_mens_qual_round_id);
    
    RAISE NOTICE 'Progression complete!';
END $$;

-- Check the results - should now have 4 men in finals
SELECT 
    'FINALS RESULTS' as status,
    a.first_name || ' ' || a.last_name AS athlete_name,
    er.bib_num,
    hr.seeding AS finals_seed
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
ORDER BY hr.seeding;

-- Verify we have exactly 4 finalists
SELECT 
    'VERIFICATION' as check_type,
    COUNT(*) as total_finalists,
    CASE 
        WHEN COUNT(*) = 4 THEN '✓ CORRECT - 4 finalists'
        ELSE '✗ ERROR - Should be 4 finalists'
    END as result
FROM ss_heat_results hr
JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
JOIN ss_round_details rd ON hd.round_id = rd.round_id
WHERE rd.event_id = 303 
  AND rd.division_id = 3 
  AND rd.round_name = 'Finals';
