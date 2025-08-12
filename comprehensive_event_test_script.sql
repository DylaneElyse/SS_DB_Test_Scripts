-- =====================================================
-- COMPREHENSIVE EVENT MANAGEMENT TEST SCRIPT
-- =====================================================
-- This script demonstrates a complete event lifecycle:
-- 1. Creating a new event
-- 2. Updating rounds and heats
-- 3. Assigning judges (event-wide and heat-specific)
-- 4. Registering athletes
-- 5. Assigning scores
-- 6. Progressing finalists
-- 7. Final round scoring
-- =====================================================

-- Clear any existing test data and start fresh
DO $$
BEGIN
    RAISE NOTICE '=== STARTING COMPREHENSIVE EVENT TEST ===';
    RAISE NOTICE 'Timestamp: %', NOW();
END $$;

-- =====================================================
-- STEP 1: CREATE A NEW EVENT
-- =====================================================
DO $$
DECLARE
    v_new_event_id INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '--- STEP 1: CREATING NEW EVENT ---';
    
    -- Insert new event
    INSERT INTO ss_events (name, start_date, end_date, location, discipline_id, status)
    VALUES ('Test Championship - Slopestyle', '2025-03-15', '2025-03-16', 'Test Mountain Resort', 'FREE_SS_SBD', 'Scheduled')
    RETURNING event_id INTO v_new_event_id;
    
    RAISE NOTICE 'Created new event with ID: %', v_new_event_id;
    
    -- Store event_id for later use
    CREATE TEMP TABLE IF NOT EXISTS test_event_info (event_id INTEGER);
    DELETE FROM test_event_info;
    INSERT INTO test_event_info VALUES (v_new_event_id);
    
    RAISE NOTICE 'Event "%s" created successfully', 'Test Championship - Slopestyle';
END $$;

-- =====================================================
-- STEP 2: SET UP EVENT DIVISIONS AND ROUNDS
-- =====================================================
DO $$
DECLARE
    v_event_id INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '--- STEP 2: SETTING UP EVENT DIVISIONS ---';
    
    SELECT event_id INTO v_event_id FROM test_event_info;
    
    -- Add divisions (Men and Women) with different round structures
    INSERT INTO ss_event_divisions (event_id, division_id, num_rounds) VALUES
    (v_event_id, 3, 2), -- Men: Qualifications + Finals
    (v_event_id, 4, 2); -- Women: Qualifications + Finals
    
    RAISE NOTICE 'Added divisions for event %:', v_event_id;
    RAISE NOTICE '- Men (Division 3): 2 rounds (Qualifications + Finals)';
    RAISE NOTICE '- Women (Division 4): 2 rounds (Qualifications + Finals)';
END $$;

-- =====================================================
-- STEP 3: UPDATE NUMBER OF HEATS FOR QUALIFICATIONS
-- =====================================================
DO $$
DECLARE
    v_event_id INTEGER;
    v_mens_qual_round_id INTEGER;
    v_womens_qual_round_id INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '--- STEP 3: UPDATING NUMBER OF HEATS ---';
    
    SELECT event_id INTO v_event_id FROM test_event_info;
    
    -- Get the qualification round IDs
    SELECT round_id INTO v_mens_qual_round_id 
    FROM ss_round_details 
    WHERE event_id = v_event_id AND division_id = 3 AND round_name = 'Qualifications';
    
    SELECT round_id INTO v_womens_qual_round_id 
    FROM ss_round_details 
    WHERE event_id = v_event_id AND division_id = 4 AND round_name = 'Qualifications';
    
    -- Update men's qualifications to have 2 heats
    UPDATE ss_round_details 
    SET num_heats = 2 
    WHERE round_id = v_mens_qual_round_id;
    
    -- Keep women's qualifications at 1 heat (default)
    RAISE NOTICE 'Updated heats configuration:';
    RAISE NOTICE '- Men Qualifications: 2 heats';
    RAISE NOTICE '- Women Qualifications: 1 heat';
    RAISE NOTICE '- Finals for both: 1 heat each';
END $$;

-- =====================================================
-- STEP 4: UPDATE NUMBER OF RUNS PER HEAT
-- =====================================================
DO $$
DECLARE
    v_event_id INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '--- STEP 4: UPDATING NUMBER OF RUNS ---';
    
    SELECT event_id INTO v_event_id FROM test_event_info;
    
    -- Set all heats to have 2 runs (typical for slopestyle)
    UPDATE ss_heat_details 
    SET num_runs = 2 
    WHERE round_heat_id IN (
        SELECT hd.round_heat_id 
        FROM ss_heat_details hd
        JOIN ss_round_details rd ON hd.round_id = rd.round_id
        WHERE rd.event_id = v_event_id
    );
    
    RAISE NOTICE 'Updated all heats to have 2 runs each';
END $$;

-- =====================================================
-- STEP 5: ASSIGN JUDGES TO THE ENTIRE EVENT
-- =====================================================
DO $$
DECLARE
    v_event_id INTEGER;
    v_judge_id INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '--- STEP 5: ASSIGNING EVENT-WIDE JUDGES ---';
    
    SELECT event_id INTO v_event_id FROM test_event_info;
    
    -- Add 5 judges to the entire event
    SELECT add_event_judge(v_event_id, 'Head Judge', 'Sarah Johnson') INTO v_judge_id;
    RAISE NOTICE 'Added Head Judge (ID: %)', v_judge_id;
    
    SELECT add_event_judge(v_event_id, 'Judge 2', 'Mike Chen') INTO v_judge_id;
    RAISE NOTICE 'Added Judge 2 (ID: %)', v_judge_id;
    
    SELECT add_event_judge(v_event_id, 'Judge 3', 'Emma Rodriguez') INTO v_judge_id;
    RAISE NOTICE 'Added Judge 3 (ID: %)', v_judge_id;
    
    SELECT add_event_judge(v_event_id, 'Judge 4', 'David Kim') INTO v_judge_id;
    RAISE NOTICE 'Added Judge 4 (ID: %)', v_judge_id;
    
    SELECT add_event_judge(v_event_id, 'Judge 5', 'Lisa Thompson') INTO v_judge_id;
    RAISE NOTICE 'Added Judge 5 (ID: %)', v_judge_id;
    
    RAISE NOTICE 'All 5 judges have been assigned to all heats in the event';
END $$;

-- =====================================================
-- STEP 6: ASSIGN A JUDGE TO A SPECIFIC ROUND/HEAT
-- =====================================================
DO $$
DECLARE
    v_event_id INTEGER;
    v_specific_heat_id INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '--- STEP 6: ASSIGNING JUDGE TO SPECIFIC HEAT ---';
    
    SELECT event_id INTO v_event_id FROM test_event_info;
    
    -- Get a specific heat ID (men's qualifications heat 1)
    SELECT hd.round_heat_id INTO v_specific_heat_id
    FROM ss_heat_details hd
    JOIN ss_round_details rd ON hd.round_id = rd.round_id
    WHERE rd.event_id = v_event_id 
      AND rd.division_id = 3 
      AND rd.round_name = 'Qualifications'
      AND hd.heat_num = 1;
    
    -- Add a specialized judge to this specific heat
    CALL add_heat_judge(v_specific_heat_id, 'Technical Judge', 'Alex Martinez');
    
    RAISE NOTICE 'Added Technical Judge specifically to Men Qualifications Heat 1 (Heat ID: %)', v_specific_heat_id;
END $$;

-- =====================================================
-- STEP 7: REGISTER ATHLETES TO THE EVENT
-- =====================================================
DO $$
DECLARE
    v_event_id INTEGER;
    v_athlete_count INTEGER := 0;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '--- STEP 7: REGISTERING ATHLETES ---';
    
    SELECT event_id INTO v_event_id FROM test_event_info;
    
    -- Register men athletes (using existing athlete IDs from the database)
    INSERT INTO ss_event_registrations (event_id, division_id, athlete_id, bib_num) VALUES
    (v_event_id, 3, 2, 101),   -- Alejandro Adib-Samii
    (v_event_id, 3, 4, 102),   -- Noah Avallone  
    (v_event_id, 3, 7, 103),   -- Zachary Bezushko
    (v_event_id, 3, 13, 104),  -- William Buffey
    (v_event_id, 3, 14, 105),  -- Fynn Bullock-Womble
    (v_event_id, 3, 15, 106),  -- Jonah Cantelon
    (v_event_id, 3, 18, 107),  -- Harry Coleman
    (v_event_id, 3, 21, 108),  -- Brock Crouch
    (v_event_id, 3, 27, 109),  -- Charles Emile Dicaire
    (v_event_id, 3, 32, 110);  -- Lys Fedorowycz
    
    v_athlete_count := v_athlete_count + 10;
    
    -- Register women athletes
    INSERT INTO ss_event_registrations (event_id, division_id, athlete_id, bib_num) VALUES
    (v_event_id, 4, 1, 201),   -- Kaitlyn Adams
    (v_event_id, 4, 3, 202),   -- Sonora Alba
    (v_event_id, 4, 8, 203),   -- Gabriella Boday
    (v_event_id, 4, 10, 204),  -- Katie Brayer
    (v_event_id, 4, 11, 205),  -- Giada Brienza
    (v_event_id, 4, 19, 206),  -- Lola Cowan
    (v_event_id, 4, 26, 207),  -- Brooke DHondt
    (v_event_id, 4, 30, 208),  -- Sascha Elvy
    (v_event_id, 4, 35, 209),  -- Rebecca Flynn
    (v_event_id, 4, 39, 210);  -- Felicity Geremia
    
    v_athlete_count := v_athlete_count + 10;
    
    RAISE NOTICE 'Registered % athletes total:', v_athlete_count;
    RAISE NOTICE '- Men: 10 athletes (Bib #101-110)';
    RAISE NOTICE '- Women: 10 athletes (Bib #201-210)';
    RAISE NOTICE 'Athletes have been automatically placed in qualification heats';
END $$;

-- =====================================================
-- STEP 8: ASSIGN SCORES TO QUALIFICATION RUNS
-- =====================================================
DO $$
DECLARE
    v_event_id INTEGER;
    v_score_count INTEGER := 0;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '--- STEP 8: ASSIGNING QUALIFICATION SCORES ---';
    
    SELECT event_id INTO v_event_id FROM test_event_info;
    
    -- Men's Qualification Scores (Sample scores for demonstration)
    -- Alejandro Adib-Samii - Run 1
    CALL update_run_score(v_event_id, 'Alejandro', 'Adib-Samii', 'Qualifications', 1, 'Head Judge', 75.5);
    CALL update_run_score(v_event_id, 'Alejandro', 'Adib-Samii', 'Qualifications', 1, 'Judge 2', 78.0);
    CALL update_run_score(v_event_id, 'Alejandro', 'Adib-Samii', 'Qualifications', 1, 'Judge 3', 76.5);
    CALL update_run_score(v_event_id, 'Alejandro', 'Adib-Samii', 'Qualifications', 1, 'Judge 4', 77.0);
    CALL update_run_score(v_event_id, 'Alejandro', 'Adib-Samii', 'Qualifications', 1, 'Judge 5', 75.0);
    
    -- Alejandro Adib-Samii - Run 2
    CALL update_run_score(v_event_id, 'Alejandro', 'Adib-Samii', 'Qualifications', 2, 'Head Judge', 82.0);
    CALL update_run_score(v_event_id, 'Alejandro', 'Adib-Samii', 'Qualifications', 2, 'Judge 2', 84.5);
    CALL update_run_score(v_event_id, 'Alejandro', 'Adib-Samii', 'Qualifications', 2, 'Judge 3', 83.0);
    CALL update_run_score(v_event_id, 'Alejandro', 'Adib-Samii', 'Qualifications', 2, 'Judge 4', 81.5);
    CALL update_run_score(v_event_id, 'Alejandro', 'Adib-Samii', 'Qualifications', 2, 'Judge 5', 83.5);
    
    -- Noah Avallone - Run 1
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Qualifications', 1, 'Head Judge', 88.0);
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Qualifications', 1, 'Judge 2', 89.5);
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Qualifications', 1, 'Judge 3', 87.5);
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Qualifications', 1, 'Judge 4', 88.5);
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Qualifications', 1, 'Judge 5', 87.0);
    
    -- Noah Avallone - Run 2
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Qualifications', 2, 'Head Judge', 85.0);
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Qualifications', 2, 'Judge 2', 86.0);
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Qualifications', 2, 'Judge 3', 84.5);
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Qualifications', 2, 'Judge 4', 85.5);
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Qualifications', 2, 'Judge 5', 86.5);
    
    -- Zachary Bezushko - Run 1
    CALL update_run_score(v_event_id, 'Zachary', 'Bezushko', 'Qualifications', 1, 'Head Judge', 79.0);
    CALL update_run_score(v_event_id, 'Zachary', 'Bezushko', 'Qualifications', 1, 'Judge 2', 80.5);
    CALL update_run_score(v_event_id, 'Zachary', 'Bezushko', 'Qualifications', 1, 'Judge 3', 78.5);
    CALL update_run_score(v_event_id, 'Zachary', 'Bezushko', 'Qualifications', 1, 'Judge 4', 79.5);
    CALL update_run_score(v_event_id, 'Zachary', 'Bezushko', 'Qualifications', 1, 'Judge 5', 80.0);
    
    -- Add scores for more men (abbreviated for space)
    CALL update_run_score(v_event_id, 'William', 'Buffey', 'Qualifications', 1, 'Head Judge', 91.0);
    CALL update_run_score(v_event_id, 'William', 'Buffey', 'Qualifications', 1, 'Judge 2', 92.5);
    CALL update_run_score(v_event_id, 'William', 'Buffey', 'Qualifications', 1, 'Judge 3', 90.5);
    
    CALL update_run_score(v_event_id, 'Fynn', 'Bullock-Womble', 'Qualifications', 1, 'Head Judge', 85.5);
    CALL update_run_score(v_event_id, 'Fynn', 'Bullock-Womble', 'Qualifications', 1, 'Judge 2', 87.0);
    CALL update_run_score(v_event_id, 'Fynn', 'Bullock-Womble', 'Qualifications', 1, 'Judge 3', 86.0);
    
    -- Women's Qualification Scores
    -- Kaitlyn Adams - Run 1
    CALL update_run_score(v_event_id, 'Kaitlyn', 'Adams', 'Qualifications', 1, 'Head Judge', 84.0);
    CALL update_run_score(v_event_id, 'Kaitlyn', 'Adams', 'Qualifications', 1, 'Judge 2', 85.5);
    CALL update_run_score(v_event_id, 'Kaitlyn', 'Adams', 'Qualifications', 1, 'Judge 3', 83.5);
    CALL update_run_score(v_event_id, 'Kaitlyn', 'Adams', 'Qualifications', 1, 'Judge 4', 84.5);
    CALL update_run_score(v_event_id, 'Kaitlyn', 'Adams', 'Qualifications', 1, 'Judge 5', 85.0);
    
    -- Kaitlyn Adams - Run 2
    CALL update_run_score(v_event_id, 'Kaitlyn', 'Adams', 'Qualifications', 2, 'Head Judge', 87.0);
    CALL update_run_score(v_event_id, 'Kaitlyn', 'Adams', 'Qualifications', 2, 'Judge 2', 88.5);
    CALL update_run_score(v_event_id, 'Kaitlyn', 'Adams', 'Qualifications', 2, 'Judge 3', 86.5);
    CALL update_run_score(v_event_id, 'Kaitlyn', 'Adams', 'Qualifications', 2, 'Judge 4', 87.5);
    CALL update_run_score(v_event_id, 'Kaitlyn', 'Adams', 'Qualifications', 2, 'Judge 5', 88.0);
    
    -- Sonora Alba - Run 1
    CALL update_run_score(v_event_id, 'Sonora', 'Alba', 'Qualifications', 1, 'Head Judge', 76.0);
    CALL update_run_score(v_event_id, 'Sonora', 'Alba', 'Qualifications', 1, 'Judge 2', 77.5);
    CALL update_run_score(v_event_id, 'Sonora', 'Alba', 'Qualifications', 1, 'Judge 3', 75.5);
    
    -- Gabriella Boday - Run 1
    CALL update_run_score(v_event_id, 'Gabriella', 'Boday', 'Qualifications', 1, 'Head Judge', 82.0);
    CALL update_run_score(v_event_id, 'Gabriella', 'Boday', 'Qualifications', 1, 'Judge 2', 83.5);
    CALL update_run_score(v_event_id, 'Gabriella', 'Boday', 'Qualifications', 1, 'Judge 3', 81.5);
    
    -- Felicity Geremia - Run 1 (Top qualifier)
    CALL update_run_score(v_event_id, 'Felicity', 'Geremia', 'Qualifications', 1, 'Head Judge', 92.0);
    CALL update_run_score(v_event_id, 'Felicity', 'Geremia', 'Qualifications', 1, 'Judge 2', 93.5);
    CALL update_run_score(v_event_id, 'Felicity', 'Geremia', 'Qualifications', 1, 'Judge 3', 91.5);
    CALL update_run_score(v_event_id, 'Felicity', 'Geremia', 'Qualifications', 1, 'Judge 4', 92.5);
    CALL update_run_score(v_event_id, 'Felicity', 'Geremia', 'Qualifications', 1, 'Judge 5', 93.0);
    
    RAISE NOTICE 'Assigned qualification scores for key athletes';
    RAISE NOTICE 'Scores will be automatically calculated and best runs determined';
END $$;

-- =====================================================
-- STEP 9: SET UP FINALS PROGRESSION
-- =====================================================
DO $$
DECLARE
    v_event_id INTEGER;
    v_mens_finals_round_id INTEGER;
    v_womens_finals_round_id INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '--- STEP 9: SETTING UP FINALS PROGRESSION ---';
    
    SELECT event_id INTO v_event_id FROM test_event_info;
    
    -- Get finals round IDs
    SELECT round_id INTO v_mens_finals_round_id 
    FROM ss_round_details 
    WHERE event_id = v_event_id AND division_id = 3 AND round_name = 'Finals';
    
    SELECT round_id INTO v_womens_finals_round_id 
    FROM ss_round_details 
    WHERE event_id = v_event_id AND division_id = 4 AND round_name = 'Finals';
    
    -- Set number of athletes to progress to finals
    UPDATE ss_round_details 
    SET num_athletes = 6 
    WHERE round_id = v_mens_finals_round_id;
    
    UPDATE ss_round_details 
    SET num_athletes = 6 
    WHERE round_id = v_womens_finals_round_id;
    
    RAISE NOTICE 'Set finals to accept top 6 athletes from each division';
END $$;

-- =====================================================
-- STEP 10: PROGRESS FINALISTS TO NEXT ROUND
-- =====================================================
DO $$
DECLARE
    v_event_id INTEGER;
    v_mens_qual_round_id INTEGER;
    v_womens_qual_round_id INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '--- STEP 10: PROGRESSING FINALISTS ---';
    
    SELECT event_id INTO v_event_id FROM test_event_info;
    
    -- Get qualification round IDs
    SELECT round_id INTO v_mens_qual_round_id 
    FROM ss_round_details 
    WHERE event_id = v_event_id AND division_id = 3 AND round_name = 'Qualifications';
    
    SELECT round_id INTO v_womens_qual_round_id 
    FROM ss_round_details 
    WHERE event_id = v_event_id AND division_id = 4 AND round_name = 'Qualifications';
    
    -- Progress men's finalists
    CALL progress_and_synchronize_round(v_mens_qual_round_id);
    RAISE NOTICE 'Progressed top 6 men to finals';
    
    -- Progress women's finalists
    CALL progress_and_synchronize_round(v_womens_qual_round_id);
    RAISE NOTICE 'Progressed top 6 women to finals';
    
    RAISE NOTICE 'Finalists have been automatically seeded based on qualification scores';
END $$;

-- =====================================================
-- STEP 11: ASSIGN SCORES TO FINALS
-- =====================================================
DO $$
DECLARE
    v_event_id INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '--- STEP 11: ASSIGNING FINALS SCORES ---';
    
    SELECT event_id INTO v_event_id FROM test_event_info;
    
    -- Men's Finals Scores (for athletes who progressed)
    -- Noah Avallone - Finals Run 1
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Finals', 1, 'Head Judge', 89.0);
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Finals', 1, 'Judge 2', 90.5);
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Finals', 1, 'Judge 3', 88.5);
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Finals', 1, 'Judge 4', 89.5);
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Finals', 1, 'Judge 5', 90.0);
    
    -- Noah Avallone - Finals Run 2 (winning run)
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Finals', 2, 'Head Judge', 95.0);
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Finals', 2, 'Judge 2', 96.5);
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Finals', 2, 'Judge 3', 94.5);
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Finals', 2, 'Judge 4', 95.5);
    CALL update_run_score(v_event_id, 'Noah', 'Avallone', 'Finals', 2, 'Judge 5', 96.0);
    
    -- William Buffey - Finals Run 1
    CALL update_run_score(v_event_id, 'William', 'Buffey', 'Finals', 1, 'Head Judge', 87.0);
    CALL update_run_score(v_event_id, 'William', 'Buffey', 'Finals', 1, 'Judge 2', 88.5);
    CALL update_run_score(v_event_id, 'William', 'Buffey', 'Finals', 1, 'Judge 3', 86.5);
    CALL update_run_score(v_event_id, 'William', 'Buffey', 'Finals', 1, 'Judge 4', 87.5);
    CALL update_run_score(v_event_id, 'William', 'Buffey', 'Finals', 1, 'Judge 5', 88.0);
    
    -- Fynn Bullock-Womble - Finals Run 1
    CALL update_run_score(v_event_id, 'Fynn', 'Bullock-Womble', 'Finals', 1, 'Head Judge', 84.0);
    CALL update_run_score(v_event_id, 'Fynn', 'Bullock-Womble', 'Finals', 1, 'Judge 2', 85.5);
    CALL update_run_score(v_event_id, 'Fynn', 'Bullock-Womble', 'Finals', 1, 'Judge 3', 83.5);
    
    -- Women's Finals Scores
    -- Felicity Geremia - Finals Run 1 (winning run)
    CALL update_run_score(v_event_id, 'Felicity', 'Geremia', 'Finals', 1, 'Head Judge', 94.0);
    CALL update_run_score(v_event_id, 'Felicity', 'Geremia', 'Finals', 1, 'Judge 2', 95.5);
    CALL update_run_score(v_event_id, 'Felicity', 'Geremia', 'Finals', 1, 'Judge 3', 93.5);
    CALL update_run_score(v_event_id, 'Felicity', 'Geremia', 'Finals', 1, 'Judge 4', 94.5);
    CALL update_run_score(v_event_id, 'Felicity', 'Geremia', 'Finals', 1, 'Judge 5', 95.0);
    
    -- Kaitlyn Adams - Finals Run 1
    CALL update_run_score(v_event_id, 'Kaitlyn', 'Adams', 'Finals', 1, 'Head Judge', 86.0);
    CALL update_run_score(v_event_id, 'Kaitlyn', 'Adams', 'Finals', 1, 'Judge 2', 87.5);
    CALL update_run_score(v_event_id, 'Kaitlyn', 'Adams', 'Finals', 1, 'Judge 3', 85.5);
    CALL update_run_score(v_event_id, 'Kaitlyn', 'Adams', 'Finals', 1, 'Judge 4', 86.5);
    CALL update_run_score(v_event_id, 'Kaitlyn', 'Adams', 'Finals', 1, 'Judge 5', 87.0);
    
    -- Gabriella Boday - Finals Run 1
    CALL update_run_score(v_event_id, 'Gabriella', 'Boday', 'Finals', 1, 'Head Judge', 83.0);
    CALL update_run_score(v_event_id, 'Gabriella', 'Boday', 'Finals', 1, 'Judge 2', 84.5);
    CALL update_run_score(v_event_id, 'Gabriella', 'Boday', 'Finals', 1, 'Judge 3', 82.5);
    
    RAISE NOTICE 'Assigned finals scores for key athletes';
    RAISE NOTICE 'Finals scoring complete - winners determined by best run';
END $$;

-- =====================================================
-- STEP 12: DISPLAY FINAL RESULTS
-- =====================================================
DO $$
DECLARE
    v_event_id INTEGER;
    result_record RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '--- STEP 12: FINAL RESULTS SUMMARY ---';
    
    SELECT event_id INTO v_event_id FROM test_event_info;
    
    RAISE NOTICE '';
    RAISE NOTICE '=== MEN''S FINALS RESULTS ===';
    
    FOR result_record IN
        SELECT 
            a.first_name || ' ' || a.last_name AS athlete_name,
            er.bib_num,
            hr.best AS best_score,
            ROW_NUMBER() OVER (ORDER BY hr.best DESC NULLS LAST) AS position
        FROM ss_heat_results hr
        JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
        JOIN ss_round_details rd ON hd.round_id = rd.round_id
        JOIN ss_event_registrations er ON hr.event_id = er.event_id 
            AND hr.division_id = er.division_id 
            AND hr.athlete_id = er.athlete_id
        JOIN ss_athletes a ON hr.athlete_id = a.athlete_id
        WHERE rd.event_id = v_event_id 
          AND rd.division_id = 3 
          AND rd.round_name = 'Finals'
        ORDER BY hr.best DESC NULLS LAST
    LOOP
        RAISE NOTICE '%. % (Bib #%) - Score: %', 
            result_record.position, 
            result_record.athlete_name, 
            result_record.bib_num,
            COALESCE(result_record.best_score::TEXT, 'No Score');
    END LOOP;
    
    RAISE NOTICE '';
    RAISE NOTICE '=== WOMEN''S FINALS RESULTS ===';
    
    FOR result_record IN
        SELECT 
            a.first_name || ' ' || a.last_name AS athlete_name,
            er.bib_num,
            hr.best AS best_score,
            ROW_NUMBER() OVER (ORDER BY hr.best DESC NULLS LAST) AS position
        FROM ss_heat_results hr
        JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
        JOIN ss_round_details rd ON hd.round_id = rd.round_id
        JOIN ss_event_registrations er ON hr.event_id = er.event_id 
            AND hr.division_id = er.division_id 
            AND hr.athlete_id = er.athlete_id
        JOIN ss_athletes a ON hr.athlete_id = a.athlete_id
        WHERE rd.event_id = v_event_id 
          AND rd.division_id = 4 
          AND rd.round_name = 'Finals'
        ORDER BY hr.best DESC NULLS LAST
    LOOP
        RAISE NOTICE '%. % (Bib #%) - Score: %', 
            result_record.position, 
            result_record.athlete_name, 
            result_record.bib_num,
            COALESCE(result_record.best_score::TEXT, 'No Score');
    END LOOP;
END $$;

-- =====================================================
-- STEP 13: VERIFICATION QUERIES
-- =====================================================
DO $$
DECLARE
    v_event_id INTEGER;
    v_total_judges INTEGER;
    v_total_athletes INTEGER;
    v_total_scores INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '--- STEP 13: EVENT VERIFICATION ---';
    
    SELECT event_id INTO v_event_id FROM test_event_info;
    
    -- Count judges
    SELECT COUNT(*) INTO v_total_judges 
    FROM ss_event_judges 
    WHERE event_id = v_event_id;
    
    -- Count registered athletes
    SELECT COUNT(*) INTO v_total_athletes 
    FROM ss_event_registrations 
    WHERE event_id = v_event_id;
    
    -- Count total scores entered
    SELECT COUNT(*) INTO v_total_scores 
    FROM ss_run_scores rs
    JOIN ss_run_results rr ON rs.run_result_id = rr.run_result_id
    WHERE rr.event_id = v_event_id AND rs.score IS NOT NULL;
    
    RAISE NOTICE '';
    RAISE NOTICE '=== EVENT STATISTICS ===';
    RAISE NOTICE 'Event ID: %', v_event_id;
    RAISE NOTICE 'Total Judges: %', v_total_judges;
    RAISE NOTICE 'Total Athletes: %', v_total_athletes;
    RAISE NOTICE 'Total Scores Entered: %', v_total_scores;
    
    RAISE NOTICE '';
    RAISE NOTICE '=== TEST COMPLETED SUCCESSFULLY ===';
    RAISE NOTICE 'All event management functions have been demonstrated:';
    RAISE NOTICE '✓ Event creation';
    RAISE NOTICE '✓ Round and heat configuration';
    RAISE NOTICE '✓ Judge assignment (event-wide and heat-specific)';
    RAISE NOTICE '✓ Athlete registration';
    RAISE NOTICE '✓ Score assignment';
    RAISE NOTICE '✓ Finalist progression';
    RAISE NOTICE '✓ Finals scoring';
    RAISE NOTICE '✓ Results calculation';
END $$;

-- Clean up temporary table
DROP TABLE IF EXISTS test_event_info;

-- =====================================================
-- ADDITIONAL UTILITY QUERIES FOR TESTING
-- =====================================================

-- Query to view event structure
/*
SELECT 
    e.name AS event_name,
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
WHERE e.name LIKE '%Test Championship%'
GROUP BY e.name, d.division_name, rd.round_name, rd.round_num, hd.heat_num, hd.num_runs
ORDER BY e.event_id, rd.division_id, rd.round_num DESC, hd.heat_num;
*/

-- Query to view judge assignments
/*
SELECT 
    e.name AS event_name,
    ej.header AS judge_role,
    ej.name AS judge_name,
    ej.passcode,
    COUNT(DISTINCT hj.round_heat_id) AS heats_assigned
FROM ss_events e
JOIN ss_event_judges ej ON e.event_id = ej.event_id
LEFT JOIN ss_heat_judges hj ON ej.personnel_id = hj.personnel_id
WHERE e.name LIKE '%Test Championship%'
GROUP BY e.name, ej.header, ej.name, ej.passcode
ORDER BY ej.personnel_id;
*/

-- Query to view detailed scores
/*
SELECT 
    a.first_name || ' ' || a.last_name AS athlete_name,
    d.division_name,
    rd.round_name,
    rr.run_num,
    ej.header AS judge_role,
    rs.score,
    rr.calc_score AS average_score,
    hr.best AS best_score
FROM ss_athletes a
JOIN ss_event_registrations er ON a.athlete_id = er.athlete_id
JOIN ss_division d ON er.division_id = d.division_id
JOIN ss_heat_results hr ON er.event_id = hr.event_id 
    AND er.division_id = hr.division_id 
    AND er.athlete_id = hr.athlete_id
JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
JOIN ss_round_details rd ON hd.round_id = rd.round_id
JOIN ss_run_results rr ON hr.round_heat_id = rr.round_heat_id 
    AND hr.athlete_id = rr.athlete_id
JOIN ss_run
