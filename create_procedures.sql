-- 1.
CREATE OR REPLACE PROCEDURE reseed_heat(IN p_round_heat_id integer)
LANGUAGE plpgsql
AS $procedure$
DECLARE
	v_subcategory   ss_disciplines.subcategory_name%TYPE;
	v_points_column TEXT;
	v_sql           TEXT;
BEGIN
	SELECT d.subcategory_name INTO v_subcategory
	FROM ss_heat_details AS hd
	JOIN ss_round_details AS rd ON hd.round_id = rd.round_id
	JOIN ss_events AS e ON rd.event_id = e.event_id
	JOIN ss_disciplines AS d ON e.discipline_id = d.discipline_id
	WHERE hd.round_heat_id = p_round_heat_id
	LIMIT 1;

	IF NOT FOUND THEN
		RAISE NOTICE 'reseed_heat: No heat found for round_heat_id %', p_round_heat_id;
		RETURN;
	END IF;

	v_points_column := CASE v_subcategory
		WHEN 'Big Air'    THEN 'fis_ba_points'
		WHEN 'Slopestyle' THEN 'fis_ss_points'
		WHEN 'Halfpipe'   THEN 'fis_hp_points'
		ELSE 'last_name'
	END;

	v_sql := format(
		'WITH new_seeding AS (
            SELECT
                hr.athlete_id,
                -- We use ROW_NUMBER() to assign a rank.
                -- Higher points should result in a higher seed number (start last).
                ROW_NUMBER() OVER (ORDER BY a.%I DESC, a.last_name ASC, a.first_name ASC) AS new_seed_value
            FROM ss_heat_results hr
            JOIN ss_athletes a ON hr.athlete_id = a.athlete_id
            WHERE hr.round_heat_id = $1
		)
		UPDATE ss_heat_results
		SET seeding = new_seeding.new_seed_value
		FROM new_seeding
		WHERE ss_heat_results.athlete_id = new_seeding.athlete_id
		  AND ss_heat_results.round_heat_id = $1
          AND ss_heat_results.seeding IS DISTINCT FROM new_seeding.new_seed_value;',
		v_points_column
	);

	RAISE NOTICE 'Reseeding heat % based on % (best athlete gets highest seed #).', p_round_heat_id, v_points_column;
	EXECUTE v_sql USING p_round_heat_id;

END;
$procedure$;


-- 2.
-- CREATE OR REPLACE PROCEDURE calculate_average_score(p_run_result_id INTEGER)
-- 	AS $procedure$
-- BEGIN
--     UPDATE ss_run_results
--     SET
--         calc_score = (
--             SELECT ROUND(AVG(score), 2)
--             FROM ss_run_scores
--             WHERE run_result_id = p_run_result_id AND score <> 0 AND score IS NOT NULL
--         )
--     WHERE run_result_id = p_run_result_id;

--     CALL find_best_score(p_run_result_id);
-- END;
-- $procedure$ LANGUAGE plpgsql;


-- 3.
CREATE OR REPLACE PROCEDURE find_best_score(p_run_result_id INTEGER)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_athlete_id INTEGER;
    v_round_heat_id INTEGER;
    v_best_score DECIMAL;
BEGIN
    SELECT rr.athlete_id, rr.round_heat_id
    INTO v_athlete_id, v_round_heat_id
    FROM ss_run_results AS rr
    WHERE rr.run_result_id = p_run_result_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'find_best_score: No run result found for id %', p_run_result_id;
        RETURN;
    END IF;

    SELECT MAX(rr.calc_score)
    INTO v_best_score
    FROM ss_run_results AS rr
    WHERE rr.athlete_id = v_athlete_id
      AND rr.round_heat_id = v_round_heat_id
      AND rr.dn_flag IS NULL; 

    UPDATE ss_heat_results
    SET
        best = v_best_score
    WHERE
        athlete_id = v_athlete_id AND round_heat_id = v_round_heat_id;
END;
$procedure$;



-- 4.
CREATE OR REPLACE PROCEDURE balance_freestyle_heats(p_heat1_id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_round_id INTEGER;
    v_heat2_id INTEGER;
BEGIN
    SELECT hd.round_id INTO v_round_id
    FROM ss_heat_details hd
    WHERE hd.round_heat_id = p_heat1_id AND hd.heat_num = 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Procedure requires a valid ID for Heat #1. Heat ID % is invalid or not Heat #1.', p_heat1_id;
    END IF;

    SELECT hd.round_heat_id INTO v_heat2_id
    FROM ss_heat_details hd
    WHERE hd.round_id = v_round_id AND hd.heat_num = 2;

    IF v_heat2_id IS NULL THEN
        RAISE EXCEPTION 'A corresponding Heat #2 could not be found for the round (ID: %).', v_round_id;
    END IF;

    RAISE NOTICE 'Balancing athletes between Heat 1 (ID: %) and Heat 2 (ID: %)...', p_heat1_id, v_heat2_id;

    UPDATE ss_heat_results SET round_heat_id = p_heat1_id
    WHERE round_heat_id = v_heat2_id;

    CALL reseed_heat(p_heat1_id);

    RAISE NOTICE 'Distributing athletes using serpentine logic...';
    WITH ranked_list AS (
        SELECT athlete_id, seeding FROM ss_heat_results WHERE round_heat_id = p_heat1_id
    )
    UPDATE ss_heat_results hr
    SET round_heat_id =
        CASE
            WHEN rl.seeding % 4 IN (1, 0) THEN p_heat1_id
            ELSE v_heat2_id
        END
    FROM ranked_list rl
    WHERE hr.athlete_id = rl.athlete_id AND hr.round_heat_id = p_heat1_id;

    RAISE NOTICE 'Finalizing seeding for both heats.';
    CALL reseed_heat(p_heat1_id);
    CALL reseed_heat(v_heat2_id);

    RAISE NOTICE 'Serpentine seeding completed for round_id=%.', v_round_id;
END;
$$;


-- 5.
-- CREATE OR REPLACE PROCEDURE update_run_score(
--     p_event_id INT,
--     p_athlete_first_name VARCHAR,
--     p_athlete_last_name VARCHAR,
--     p_round_name VARCHAR,
--     p_run_num INT,
--     p_judge_header VARCHAR,
--     p_score DECIMAL
-- )
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     v_athlete_id INT;
--     v_personnel_id INT;
--     v_run_result_id INT;
--     v_round_heat_id INT;
-- BEGIN
--     SELECT athlete_id INTO v_athlete_id
--     FROM ss_athletes
--     WHERE lower(first_name) = lower(p_athlete_first_name)
--       AND lower(last_name) = lower(p_athlete_last_name);

--     IF v_athlete_id IS NULL THEN
--         RAISE NOTICE 'Athlete not found (case-insensitive search): % %. Skipping update.', p_athlete_first_name, p_athlete_last_name;
--         RETURN;
--     END IF;

--     SELECT personnel_id INTO v_personnel_id
--     FROM ss_event_judges
--     WHERE event_id = p_event_id
--       AND lower(header) = lower(p_judge_header);

--     IF v_personnel_id IS NULL THEN
--         RAISE NOTICE 'Judge not found for event % with header (case-insensitive search): %. Skipping update.', p_event_id, p_judge_header;
--         RETURN;
--     END IF;

--     SELECT T1.run_result_id, T1.round_heat_id 
--     INTO v_run_result_id, v_round_heat_id
--     FROM ss_run_results AS T1
--     JOIN ss_heat_details AS T2 ON T1.round_heat_id = T2.round_heat_id
--     JOIN ss_round_details AS T3 ON T2.round_id = T3.round_id
--     WHERE T1.athlete_id = v_athlete_id
--       AND T1.event_id = p_event_id
--       AND T1.run_num = p_run_num
--       AND lower(T3.round_name) = lower(p_round_name);

--     IF v_run_result_id IS NULL THEN
--         RAISE NOTICE 'Run result not found for Athlete ID %, Run %, Round % (case-insensitive search). Skipping update.', v_athlete_id, p_run_num, p_round_name;
--         RETURN;
--     END IF;

--     INSERT INTO ss_run_scores (run_result_id, personnel_id, round_heat_id, score)
--     VALUES (v_run_result_id, v_personnel_id, v_round_heat_id, p_score)
--     ON CONFLICT (run_result_id, personnel_id) DO UPDATE
--     SET score = EXCLUDED.score;

-- END;
-- $$;


-- 7.
CREATE OR REPLACE PROCEDURE add_heat_judge(
    p_round_heat_id INT,
    p_header VARCHAR,
    p_name VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_event_id INT;
    v_personnel_id INT;
BEGIN
    SELECT rd.event_id
    INTO v_event_id
    FROM ss_heat_details AS hd
    JOIN ss_round_details AS rd ON hd.round_id = rd.round_id
    WHERE hd.round_heat_id = p_round_heat_id;

    IF v_event_id IS NULL THEN
        RAISE EXCEPTION 'Invalid round_heat_id provided: %', p_round_heat_id;
    END IF;
    
    RAISE NOTICE 'Procedure called for heat_id: %, which belongs to event_id: %', p_round_heat_id, v_event_id;

    SELECT personnel_id
    INTO v_personnel_id
    FROM ss_event_judges
    WHERE event_id = v_event_id AND header = p_header;
    
    IF v_personnel_id IS NULL THEN
        RAISE NOTICE 'Judge with header "%" not found for event %. Creating new judge.', p_header, v_event_id;
        INSERT INTO ss_event_judges (event_id, header, name)
        VALUES (v_event_id, p_header, p_name)
        RETURNING personnel_id INTO v_personnel_id;
        RAISE NOTICE 'Created new event judge with personnel_id: %', v_personnel_id;
    ELSE
        RAISE NOTICE 'Found existing judge with header "%". Re-using personnel_id: %', p_header, v_personnel_id;
    END IF;

    INSERT INTO ss_heat_judges (round_heat_id, personnel_id)
    VALUES (p_round_heat_id, v_personnel_id)
    ON CONFLICT (round_heat_id, personnel_id) DO NOTHING;

    RAISE NOTICE 'Assigned judge % to specific heat %.', v_personnel_id, p_round_heat_id;
    
    INSERT INTO ss_run_scores (personnel_id, run_result_id, round_heat_id)
    SELECT v_personnel_id, r.run_result_id, r.round_heat_id
    FROM ss_run_results AS r
    WHERE r.round_heat_id = p_round_heat_id
    ON CONFLICT (personnel_id, run_result_id) DO NOTHING;

    RAISE NOTICE 'Created placeholder run scores for judge % for heat %.', v_personnel_id, p_round_heat_id;

END;
$$;


-- 8.
CREATE OR REPLACE PROCEDURE reseed_heat_by_score(
    p_round_heat_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_round_id INT;
    v_event_id INT;
    v_division_id INT;
    v_round_num INT;
    v_previous_round_id INT;
BEGIN
    SELECT 
        rd.round_id, rd.event_id, rd.division_id, rd.round_num
    INTO 
        v_round_id, v_event_id, v_division_id, v_round_num
    FROM ss_heat_details hd
    JOIN ss_round_details rd ON hd.round_id = rd.round_id
    WHERE hd.round_heat_id = p_round_heat_id;

    IF NOT FOUND THEN
        RAISE WARNING 'reseed_heat_by_score: No heat found for round_heat_id %', p_round_heat_id;
        RETURN;
    END IF;

    SELECT round_id INTO v_previous_round_id
    FROM ss_round_details
    WHERE event_id = v_event_id 
      AND division_id = v_division_id 
      AND round_num = v_round_num + 1;

    IF v_previous_round_id IS NULL THEN
        RAISE WARNING 'reseed_heat_by_score: Could not find previous round for heat %. Seeding will not be performed.', p_round_heat_id;
        RETURN;
    END IF;

    RAISE NOTICE 'Reseeding heat % based on scores from previous round (ID: %)', p_round_heat_id, v_previous_round_id;

    WITH previous_round_scores AS (
        SELECT
            hr.athlete_id,
            hr.best AS previous_score
        FROM ss_heat_results hr
        JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
        WHERE hd.round_id = v_previous_round_id
    ),
    new_seeding AS (
        SELECT 
            current_hr.athlete_id,
            ROW_NUMBER() OVER (ORDER BY prs.previous_score ASC, current_hr.athlete_id) AS new_seed_value
        FROM ss_heat_results current_hr
        JOIN previous_round_scores prs ON current_hr.athlete_id = prs.athlete_id
        WHERE current_hr.round_heat_id = p_round_heat_id
    )
    UPDATE ss_heat_results hr
    SET seeding = ns.new_seed_value
    FROM new_seeding ns
    WHERE hr.athlete_id = ns.athlete_id
      AND hr.round_heat_id = p_round_heat_id;

END;
$$;


-- 9.
CREATE OR REPLACE PROCEDURE progress_and_synchronize_round(
    p_source_round_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_event_id INT;
    v_division_id INT;
    v_source_round_num INT;
    v_num_source_heats INT;

    v_destination_round_id INT;
    v_destination_heat_id INT;
    v_num_to_progress INT;
    
    v_num_per_heat INT;
    v_deleted_count INT;
    v_inserted_count INT;
BEGIN
    -------------------------------------------------------------------
    RAISE NOTICE 'Starting progression from source round ID: %', p_source_round_id;

    SELECT event_id, division_id, round_num 
    INTO v_event_id, v_division_id, v_source_round_num
    FROM ss_round_details WHERE round_id = p_source_round_id;

    IF v_source_round_num IS NULL THEN
        RAISE EXCEPTION 'Progression failed: Invalid source_round_id %.', p_source_round_id;
    END IF;

    SELECT round_id, num_athletes INTO v_destination_round_id, v_num_to_progress
    FROM ss_round_details
    WHERE event_id = v_event_id 
      AND division_id = v_division_id 
      AND round_num = v_source_round_num - 1;

    IF v_destination_round_id IS NULL THEN
        RAISE NOTICE 'Progression skipped: Round % is the final round for this division.', p_source_round_id;
        RETURN;
    END IF;

    IF v_num_to_progress IS NULL OR v_num_to_progress <= 0 THEN
        RAISE EXCEPTION 'Progression failed: The destination round (ID: %) has not been configured with the number of athletes to progress to it. Please set `num_athletes`.', v_destination_round_id;
    END IF;
    
    SELECT round_heat_id INTO v_destination_heat_id FROM ss_heat_details
    WHERE round_id = v_destination_round_id LIMIT 1;
    
    IF v_destination_heat_id IS NULL THEN
        RAISE EXCEPTION 'Progression failed: The destination round (ID: %) does not have any heats.', v_destination_round_id;
    END IF;
    
    RAISE NOTICE 'Calculating the % athletes who should progress to round ID % (heat ID %)...', v_num_to_progress, v_destination_round_id, v_destination_heat_id;

    CREATE TEMP TABLE expected_athletes (athlete_id INT PRIMARY KEY) ON COMMIT DROP;

    SELECT COUNT(*) INTO v_num_source_heats FROM ss_heat_details WHERE round_id = p_source_round_id;

    IF v_num_source_heats = 1 THEN
        INSERT INTO expected_athletes (athlete_id)
        SELECT hr.athlete_id
        FROM ss_heat_results hr
        JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
        WHERE hd.round_id = p_source_round_id
        ORDER BY hr.best DESC NULLS LAST
        LIMIT v_num_to_progress;

    ELSIF v_num_source_heats = 2 THEN
        v_num_per_heat := v_num_to_progress / 2;
        IF (v_num_to_progress % 2) <> 0 THEN
            RAISE WARNING 'Number to progress (%) is odd for a 2-heat round. Taking % from each heat, which might not match the total.', v_num_to_progress, v_num_per_heat;
        END IF;

        INSERT INTO expected_athletes (athlete_id)
        SELECT athlete_id FROM (
            (SELECT hr.athlete_id FROM ss_heat_results hr WHERE hr.round_heat_id = (SELECT round_heat_id FROM ss_heat_details WHERE round_id = p_source_round_id ORDER BY heat_num LIMIT 1 OFFSET 0) ORDER BY hr.best DESC NULLS LAST LIMIT v_num_per_heat)
            UNION ALL
            (SELECT hr.athlete_id FROM ss_heat_results hr WHERE hr.round_heat_id = (SELECT round_heat_id FROM ss_heat_details WHERE round_id = p_source_round_id ORDER BY heat_num LIMIT 1 OFFSET 1) ORDER BY hr.best DESC NULLS LAST LIMIT v_num_per_heat)
        ) AS progressing_athletes;
    ELSE
        RAISE WARNING 'Progression logic not implemented for % heats. No action taken.', v_num_source_heats;
        DROP TABLE expected_athletes;
        RETURN;
    END IF;

    CREATE TEMP TABLE actual_athletes (athlete_id INT PRIMARY KEY) ON COMMIT DROP;
    INSERT INTO actual_athletes (athlete_id) 
    SELECT hr.athlete_id FROM ss_heat_results hr WHERE hr.round_heat_id = v_destination_heat_id;

    DELETE FROM ss_heat_results
    WHERE round_heat_id = v_destination_heat_id
      AND athlete_id IN (SELECT aa.athlete_id FROM actual_athletes aa LEFT JOIN expected_athletes ea ON aa.athlete_id = ea.athlete_id WHERE ea.athlete_id IS NULL);
    
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    RAISE NOTICE 'Synchronization: Removed % incorrect athlete(s) from destination heat %.', v_deleted_count, v_destination_heat_id;

    INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id)
    SELECT v_destination_heat_id, v_event_id, v_division_id, ea.athlete_id
    FROM expected_athletes ea
    LEFT JOIN actual_athletes aa ON ea.athlete_id = aa.athlete_id
    WHERE aa.athlete_id IS NULL
    ON CONFLICT DO NOTHING;
    
    GET DIAGNOSTICS v_inserted_count = ROW_COUNT;
    RAISE NOTICE 'Synchronization: Added % missing athlete(s) to destination heat %.', v_inserted_count, v_destination_heat_id;

    IF v_deleted_count > 0 OR v_inserted_count > 0 THEN
        RAISE NOTICE 'Roster changed, reseeding heat % by score...', v_destination_heat_id;
        CALL reseed_heat_by_score(v_destination_heat_id);
    ELSE
        RAISE NOTICE 'No changes needed. Roster for heat % is already correct.', v_destination_heat_id;
    END IF;
    
    RAISE NOTICE 'Progression and synchronization from round % complete.', p_source_round_id;
END;
$$;


