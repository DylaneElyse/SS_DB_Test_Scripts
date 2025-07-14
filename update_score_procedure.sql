DROP FUNCTION IF EXISTS update_run_score;

CREATE OR REPLACE FUNCTION update_run_score(
    p_event_id INT,
    p_athlete_first_name VARCHAR,
    p_athlete_last_name VARCHAR,
    p_round_name VARCHAR,
    p_run_num INT,
    p_judge_header VARCHAR,
    p_score DECIMAL
)
RETURNS VOID AS $$
DECLARE
    v_athlete_id INT;
    v_personnel_id INT;
    v_run_result_id INT;
BEGIN
    SELECT athlete_id INTO v_athlete_id
    FROM ss_athletes
    WHERE first_name = p_athlete_first_name AND last_name = p_athlete_last_name;

    IF v_athlete_id IS NULL THEN
        RAISE NOTICE 'Athlete not found: % %. Skipping update.', p_athlete_first_name, p_athlete_last_name;
        RETURN;
    END IF;

    SELECT personnel_id INTO v_personnel_id
    FROM ss_event_judges
    WHERE event_id = p_event_id AND header = p_judge_header;

    IF v_personnel_id IS NULL THEN
        RAISE NOTICE 'Judge not found for event %: %. Skipping update.', p_event_id, p_judge_header;
        RETURN;
    END IF;

    SELECT T1.run_result_id INTO v_run_result_id
    FROM ss_run_results AS T1
    JOIN ss_heat_details AS T2 ON T1.round_heat_id = T2.round_heat_id
    JOIN ss_round_details AS T3 ON T2.round_id = T3.round_id
    WHERE T1.athlete_id = v_athlete_id
        AND T1.event_id = p_event_id
        AND T1.run_num = p_run_num
        AND T3.round_name = p_round_name;

    IF v_run_result_id IS NULL THEN
        RAISE NOTICE 'Run result not found for Athlete ID %, Run %, Round %. Skipping update.', v_athlete_id, p_run_num, p_round_name;
        RETURN;
    END IF;

    UPDATE ss_run_scores
    SET score = p_score
    WHERE run_result_id = v_run_result_id
        AND personnel_id = v_personnel_id;

    RAISE NOTICE 'Updated score for Athlete: % %, Judge: %, Run: %, Score: %', p_athlete_first_name, p_athlete_last_name, p_judge_header, p_run_num, p_score;

END;
$$ LANGUAGE plpgsql;