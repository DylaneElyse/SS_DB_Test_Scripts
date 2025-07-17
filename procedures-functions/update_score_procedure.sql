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
    WHERE lower(first_name) = lower(p_athlete_first_name)
      AND lower(last_name) = lower(p_athlete_last_name);

    IF v_athlete_id IS NULL THEN
        RAISE NOTICE 'Athlete not found (case-insensitive search): % %. Skipping update.', p_athlete_first_name, p_athlete_last_name;
        RETURN;
    END IF;

    SELECT personnel_id INTO v_personnel_id
    FROM ss_event_judges
    WHERE event_id = p_event_id
      AND lower(header) = lower(p_judge_header);

    IF v_personnel_id IS NULL THEN
        RAISE NOTICE 'Judge not found for event % with header (case-insensitive search): %. Skipping update.', p_event_id, p_judge_header;
        RETURN;
    END IF;

    SELECT T1.run_result_id INTO v_run_result_id
    FROM ss_run_results AS T1
    JOIN ss_heat_details AS T2 ON T1.round_heat_id = T2.round_heat_id
    JOIN ss_round_details AS T3 ON T2.round_id = T3.round_id
    WHERE T1.athlete_id = v_athlete_id
        AND T1.event_id = p_event_id
        AND T1.run_num = p_run_num
        AND lower(T3.round_name) = lower(p_round_name);

    IF v_run_result_id IS NULL THEN
        RAISE NOTICE 'Run result not found for Athlete ID %, Run %, Round % (case-insensitive search). Skipping update.', v_athlete_id, p_run_num, p_round_name;
        RETURN;
    END IF;

    INSERT INTO ss_run_scores (run_result_id, personnel_id, score)
    VALUES (v_run_result_id, v_personnel_id, p_score)
    ON CONFLICT (run_result_id, personnel_id) DO UPDATE
    SET score = EXCLUDED.score;

END;
$$ LANGUAGE plpgsql;