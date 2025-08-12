-- Fix judge assignments for event 303
-- Run this before trying to assign scores

-- First, add the judges to the event if they don't exist
SELECT add_event_judge(303, 'Judge 2', 'Mike Chen');
SELECT add_event_judge(303, 'Judge 3', 'Emma Rodriguez');

-- Add Technical Judge to men's qualifications heat 1
DO $$
DECLARE
    v_event_id INTEGER := 303;
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
    
    IF v_specific_heat_id IS NOT NULL THEN
        -- Add specialized judge
        CALL add_heat_judge(v_specific_heat_id, 'Technical Judge', 'Alex Martinez');
        RAISE NOTICE 'Added Technical Judge to heat ID: %', v_specific_heat_id;
    ELSE
        RAISE NOTICE 'Could not find men''s qualifications heat 1 for event %', v_event_id;
    END IF;
END $$;

-- Now assign all event judges to all heats for this event
DO $$
DECLARE
    judge_rec RECORD;
    heat_rec RECORD;
BEGIN
    -- Loop through all judges for this event
    FOR judge_rec IN 
        SELECT personnel_id, header, name 
        FROM ss_event_judges 
        WHERE event_id = 303
    LOOP
        -- Loop through all heats for this event
        FOR heat_rec IN
            SELECT hd.round_heat_id, rd.round_name, hd.heat_num, d.division_name
            FROM ss_heat_details hd
            JOIN ss_round_details rd ON hd.round_id = rd.round_id
            JOIN ss_division d ON rd.division_id = d.division_id
            WHERE rd.event_id = 303
        LOOP
            -- Assign judge to heat
            INSERT INTO ss_heat_judges (round_heat_id, personnel_id)
            VALUES (heat_rec.round_heat_id, judge_rec.personnel_id)
            ON CONFLICT (round_heat_id, personnel_id) DO NOTHING;
            
            RAISE NOTICE 'Assigned % (%) to % % Heat %', 
                judge_rec.name, judge_rec.header, 
                heat_rec.division_name, heat_rec.round_name, heat_rec.heat_num;
        END LOOP;
    END LOOP;
END $$;

-- Create placeholder run scores for all judge-athlete-run combinations
DO $$
DECLARE
    run_rec RECORD;
    judge_rec RECORD;
BEGIN
    -- Loop through all run results for event 303
    FOR run_rec IN
        SELECT rr.run_result_id, rr.round_heat_id, rr.athlete_id, rr.run_num,
               a.first_name, a.last_name, rd.round_name
        FROM ss_run_results rr
        JOIN ss_athletes a ON rr.athlete_id = a.athlete_id
        JOIN ss_heat_details hd ON rr.round_heat_id = hd.round_heat_id
        JOIN ss_round_details rd ON hd.round_id = rd.round_id
        WHERE rr.event_id = 303
    LOOP
        -- Loop through all judges assigned to this heat
        FOR judge_rec IN
            SELECT hj.personnel_id, ej.header
            FROM ss_heat_judges hj
            JOIN ss_event_judges ej ON hj.personnel_id = ej.personnel_id
            WHERE hj.round_heat_id = run_rec.round_heat_id
        LOOP
            -- Create placeholder score entry
            INSERT INTO ss_run_scores (personnel_id, run_result_id, round_heat_id, score)
            VALUES (judge_rec.personnel_id, run_rec.run_result_id, run_rec.round_heat_id, NULL)
            ON CONFLICT (personnel_id, run_result_id) DO NOTHING;
            
            RAISE NOTICE 'Created score placeholder for % % - % Run % - Judge %',
                run_rec.first_name, run_rec.last_name, run_rec.round_name, 
                run_rec.run_num, judge_rec.header;
        END LOOP;
    END LOOP;
END $$;

-- Verify the setup
SELECT 
    'Final Verification' as status,
    COUNT(DISTINCT ej.personnel_id) as total_judges,
    COUNT(DISTINCT hj.round_heat_id) as heats_with_judges,
    COUNT(*) as total_judge_heat_assignments
FROM ss_event_judges ej
JOIN ss_heat_judges hj ON ej.personnel_id = hj.personnel_id
JOIN ss_heat_details hd ON hj.round_heat_id = hd.round_heat_id
JOIN ss_round_details rd ON hd.round_id = rd.round_id
WHERE ej.event_id = 303;

RAISE NOTICE 'Judge assignments completed for event 303. You can now run your scoring commands.';
