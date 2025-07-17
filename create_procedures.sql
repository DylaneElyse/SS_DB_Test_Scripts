-- 1.
CREATE OR REPLACE PROCEDURE reseed_heat(p_round_heat_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Reseeding heat: %', p_round_heat_id;

    WITH ranked_athletes AS (
        SELECT
            hr.athlete_id,
            -- This ROW_NUMBER() function calculates the new seeding order.
            -- IMPORTANT: Customize the ORDER BY clause for your business logic.
            -- This example seeds by FIS points (higher is better), then alphabetically.
            ROW_NUMBER() OVER (
                ORDER BY
                    COALESCE(a.fis_ss_points, 0) DESC, -- Use COALESCE to handle NULLs
                    a.last_name ASC,
                    a.first_name ASC
            ) AS new_seeding
        FROM
            ss_heat_results AS hr
        JOIN
            ss_athletes AS a ON hr.athlete_id = a.athlete_id
        WHERE
            hr.round_heat_id = p_round_heat_id
    )
    UPDATE ss_heat_results AS hr
    SET seeding = ra.new_seeding
    FROM ranked_athletes AS ra
    WHERE
        hr.round_heat_id = p_round_heat_id
        AND hr.athlete_id = ra.athlete_id
        AND hr.seeding IS DISTINCT FROM ra.new_seeding; -- Only update rows that actually changed

END;
$$;

-- CREATE OR REPLACE PROCEDURE reseed_heat(IN p_round_heat_id integer)
-- 	AS $procedure$
-- DECLARE
-- 	v_subcategory   ss_disciplines.subcategory_name%TYPE;
-- 	v_points_column TEXT;
-- 	v_sql           TEXT;
-- BEGIN
-- 	SELECT d.subcategory_name INTO v_subcategory
-- 	FROM ss_heat_details AS hd
-- 	JOIN ss_round_details AS rd ON hd.round_id = rd.round_id
-- 	JOIN ss_events AS e ON rd.event_id = e.event_id
-- 	JOIN ss_disciplines AS d ON e.discipline_id = d.discipline_id
-- 	WHERE hd.round_heat_id = p_round_heat_id
-- 	LIMIT 1;

-- 	IF NOT FOUND THEN
-- 		RAISE NOTICE 'reseed_heat: No heat found for round_heat_id %', p_round_heat_id;
-- 		RETURN;
-- 	END IF;

-- 	v_points_column := CASE v_subcategory
-- 		WHEN 'Big Air'    THEN 'fis_ba_points'
-- 		WHEN 'Slopestyle' THEN 'fis_ss_points'
-- 		WHEN 'Halfpipe'   THEN 'fis_hp_points'
-- 		ELSE NULL
-- 	END;

-- 	IF v_points_column IS NULL THEN
-- 		RAISE NOTICE 'reseed_heat: No seeding rule for subcategory "%". Seeding will not be changed.', v_subcategory;
-- 		RETURN;
-- 	END IF;

-- 	v_sql := format(
-- 		'WITH new_seeding AS (
-- 		SELECT
-- 			hr.athlete_id,
-- 			-- Per your rules (higher points = better), we order by points ASCENDING.
-- 			-- This gives the lowest-ranked athlete (lowest points) seed #1.
-- 			-- This gives the HIGHEST-ranked athlete (highest points) the HIGHEST seed number,
-- 			-- so they start last.
-- 			ROW_NUMBER() OVER (ORDER BY a.%I ASC, a.athlete_id ASC) AS new_seed_value
-- 		FROM
-- 			ss_heat_results hr
-- 		JOIN
-- 			ss_athletes a ON hr.athlete_id = a.athlete_id
-- 		WHERE
-- 			hr.round_heat_id = $1
-- 		)
-- 		UPDATE
-- 			ss_heat_results
-- 		SET
-- 			seeding = new_seeding.new_seed_value
-- 		FROM
-- 			new_seeding
-- 		WHERE
-- 			ss_heat_results.athlete_id = new_seeding.athlete_id
-- 			AND ss_heat_results.round_heat_id = $1;',
-- 		v_points_column
-- 	);

-- 	RAISE NOTICE 'Reseeding heat % based on % points (best athlete starts last).', p_round_heat_id, v_points_column;
-- 	EXECUTE v_sql USING p_round_heat_id;

-- END;
-- $procedure$ LANGUAGE plpgsql;


-- 2.
CREATE OR REPLACE PROCEDURE calculate_average_score(p_run_result_id INTEGER)
	AS $procedure$
BEGIN
    UPDATE ss_run_results
    SET
        calc_score = (
            SELECT ROUND(AVG(score), 2)
            FROM ss_run_scores
            WHERE run_result_id = p_run_result_id AND score <> 0 AND score IS NOT NULL
        )
    WHERE run_result_id = p_run_result_id;

    CALL find_best_score(p_run_result_id);
END;
$procedure$ LANGUAGE plpgsql;


-- 3.
CREATE OR REPLACE PROCEDURE find_best_score(p_run_result_id INTEGER)
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
        RAISE NOTICE 'No run result found for id %', p_run_result_id;
        RETURN;
    END IF;

    SELECT MAX(rr.calc_score)
    INTO v_best_score
    FROM ss_run_results AS rr
    WHERE rr.athlete_id = v_athlete_id AND rr.round_heat_id = v_round_heat_id;

    UPDATE ss_heat_results
    SET
        best = v_best_score
    WHERE
        athlete_id = v_athlete_id AND round_heat_id = v_round_heat_id;
END;
$procedure$ LANGUAGE plpgsql;


-- 4.
CREATE OR REPLACE PROCEDURE balance_freestyle_heats(p_heat1_id INTEGER)
	AS $procedure$
DECLARE
    v_round_id INTEGER;
    v_heat1_num INTEGER;
    v_heat2_id INTEGER;
    v_event_id INTEGER;
    v_division_id INTEGER;
    v_athlete_record RECORD;
    v_rank INTEGER := 0;
    v_target_heat_id INTEGER;
BEGIN
    SELECT hd.round_id, hd.heat_num, rd.event_id, rd.division_id
    INTO v_round_id, v_heat1_num, v_event_id, v_division_id
    FROM ss_heat_details hd
    JOIN ss_round_details rd ON hd.round_id = rd.round_id
    WHERE hd.round_heat_id = p_heat1_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid input: The provided heat ID (%) does not exist or is not linked to a round.', p_heat1_id;
    END IF;

    IF v_heat1_num <> 1 THEN
        RAISE EXCEPTION 'Invalid input: The provided heat ID (%) is for Heat #%, not Heat #1.', p_heat1_id, v_heat1_num;
    END IF;

    SELECT hd.round_heat_id INTO v_heat2_id
    FROM ss_heat_details hd
    WHERE hd.round_id = v_round_id AND hd.heat_num = 2;

    IF v_heat2_id IS NULL THEN
        RAISE EXCEPTION 'Procedure failed: A corresponding Heat 2 could not be found for the round associated with heat ID %.', p_heat1_id;
    END IF;

    RAISE NOTICE 'Starting to balance athletes between Heat 1 (ID: %) and Heat 2 (ID: %) for round_id: %.', p_heat1_id, v_heat2_id, v_round_id;

    RAISE NOTICE 'Consolidating all athletes into Heat 1 for reseeding.';
    UPDATE ss_heat_results
    SET round_heat_id = p_heat1_id
    WHERE round_heat_id = v_heat2_id;

    RAISE NOTICE 'Calling reseed_heat(%) to establish a single ranked list.', p_heat1_id;
    CALL reseed_heat(p_heat1_id);

    RAISE NOTICE 'Distributing athletes into balanced heats...';
    FOR v_athlete_record IN
        SELECT
            hr.athlete_id,
            hr.seeding
        FROM ss_heat_results AS hr
        WHERE hr.round_heat_id = p_heat1_id
        ORDER BY hr.seeding ASC, hr.athlete_id ASC
    LOOP
        v_rank := v_rank + 1;

        IF (v_rank % 4 = 1) OR (v_rank % 4 = 0) THEN
            v_target_heat_id := p_heat1_id;
        ELSE
            v_target_heat_id := v_heat2_id;
        END IF;

        UPDATE ss_heat_results
        SET round_heat_id = v_target_heat_id
        WHERE
            athlete_id = v_athlete_record.athlete_id
            AND event_id = v_event_id
            AND division_id = v_division_id;

    END LOOP;

    CALL reseed_heat(p_heat1_id);
    CALL reseed_heat(v_heat2_id);

    RAISE NOTICE 'Serpentine seeding completed for round_id=%.', v_round_id;
END;
$procedure$ LANGUAGE plpgsql;


-- 5.
CREATE OR REPLACE PROCEDURE update_run_score(
    p_event_id INT,
    p_athlete_first_name VARCHAR,
    p_athlete_last_name VARCHAR,
    p_round_name VARCHAR,
    p_run_num INT,
    p_judge_header VARCHAR,
    p_score DECIMAL
)
    AS $$
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

