-- Neon Procedures - August 11

CREATE OR REPLACE PROCEDURE public.add_heat_judge(IN p_round_heat_id integer, IN p_header character varying, IN p_name character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
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
$procedure$;


CREATE OR REPLACE PROCEDURE public.balance_freestyle_heats(IN p_heat1_id integer)
 LANGUAGE plpgsql
AS $procedure$
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
$procedure$;


CREATE OR REPLACE PROCEDURE public.calculate_average_score(IN p_run_result_id integer)
 LANGUAGE plpgsql
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
$procedure$;


CREATE OR REPLACE PROCEDURE public.find_best_score(IN p_run_result_id integer)
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
$procedure$;


CREATE OR REPLACE PROCEDURE public.progress_and_synchronize_round(IN p_source_round_id integer)
 LANGUAGE plpgsql
AS $procedure$
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
    -- Clean up any leftover temporary tables from previous failed runs
    DROP TABLE IF EXISTS expected_athletes;
    DROP TABLE IF EXISTS actual_athletes;
    
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
        -- For 2-heat rounds, select the top athletes overall, not per heat
        -- This ensures we get the best performers regardless of which heat they were in
        RAISE NOTICE 'Progressing top % athletes from 2-heat qualification round', v_num_to_progress;

        INSERT INTO expected_athletes (athlete_id)
        SELECT hr.athlete_id
        FROM ss_heat_results hr
        JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
        WHERE hd.round_id = p_source_round_id
        ORDER BY hr.best DESC NULLS LAST
        LIMIT v_num_to_progress;
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
$procedure$;


CREATE OR REPLACE PROCEDURE public.reseed_heat(IN p_round_heat_id integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_discipline_id   TEXT;
    v_points_column   TEXT;
    v_sql             TEXT;
    v_athlete_count   INTEGER;
BEGIN
    -- Step 1: Find the discipline for the given heat.
    SELECT d.discipline_id INTO v_discipline_id
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

    -- Step 2: Determine the correct FIS points column based on the discipline_id.
    v_points_column := CASE v_discipline_id
        WHEN 'FREE_BA_SBD' THEN 'fis_ba_points'
        WHEN 'FREE_SS_SBD' THEN 'fis_ss_points'
        WHEN 'FREE_HP_SBD' THEN 'fis_hp_points'
        ELSE NULL -- If the discipline doesn't match, this will be NULL.
    END;

    -- If we couldn't find a matching points column, we can't proceed.
    IF v_points_column IS NULL THEN
        RAISE WARNING 'reseed_heat: Unsupported discipline_id "%" for heat %. Cannot reseed.', v_discipline_id, p_round_heat_id;
        RETURN;
    END IF;

    -- Step 3: Build and execute the dynamic SQL to update the seeding.
    v_sql := format(
    'WITH new_seeding AS (
        SELECT
            hr.athlete_id,
            -- We use ROW_NUMBER() to assign a seed number.
            -- Athletes are ordered by their FIS points in ASCENDING order,
            -- with any NULL values appearing first in the list.
            -- This gives athletes with no points the lowest seed numbers.
            -- Tie-breaking is done by last name, then first name for a consistent order.
            ROW_NUMBER() OVER (ORDER BY a.%I ASC NULLS FIRST, a.last_name ASC, a.first_name ASC) AS new_seed_value
        FROM ss_heat_results hr
        JOIN ss_athletes a ON hr.athlete_id = a.athlete_id
        WHERE hr.round_heat_id = $1
    )
    UPDATE ss_heat_results
    SET seeding = new_seeding.new_seed_value
    FROM new_seeding
    WHERE ss_heat_results.athlete_id = new_seeding.athlete_id
      AND ss_heat_results.round_heat_id = $1
      -- This is a smart optimization: only update rows where the seeding has actually changed.
      AND ss_heat_results.seeding IS DISTINCT FROM new_seeding.new_seed_value;',
    v_points_column
    );

    -- Updated notice to reflect the new NULL handling logic
    RAISE NOTICE 'Reseeding heat % (Discipline ID: %). Ordering by % ASC NULLS FIRST. Athletes with no points go first.', p_round_heat_id, v_discipline_id, v_points_column;

    EXECUTE v_sql USING p_round_heat_id;

    -- Optional: Report how many athletes were updated.
    GET DIAGNOSTICS v_athlete_count = ROW_COUNT;
    RAISE NOTICE 'Reseed complete. Updated % athletes in heat %.', v_athlete_count, p_round_heat_id;

END;
$procedure$;


CREATE OR REPLACE PROCEDURE public.reseed_heat_by_score(IN p_round_heat_id integer)
 LANGUAGE plpgsql
AS $procedure$
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
$procedure$;


CREATE OR REPLACE PROCEDURE public.run_full_database_seed()
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    RAISE NOTICE '--- Starting Full Database Seed Process ---';

    CALL ss_reset_data();
    CALL ss_seed_lookup_tables();
    CALL ss_seed_event_data();
    CALL ss_seed_athlete_data();
    RAISE NOTICE 'Step 6: Poplulating scores....';
    CALL update_m_ba_q_scores();
    CALL update_w_ba_f_scores();
    CALL update_m_ss_q_scores();
    CALL update_w_ss_f_scores();
    CALL update_m_hp_f_scores();
    CALL update_w_hp_f_scores();
    RAISE NOTICE 'Step 6: Complete.';
    CALL ss_synchronize_sequences();

    RAISE NOTICE '--- Full Database Seed Process Finished Successfully ---';
END;
$procedure$;


CREATE OR REPLACE PROCEDURE public.ss_reseed_heats()
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    heat_to_reseed RECORD;
BEGIN
    RAISE NOTICE 'Step 5: Dynamically reseeding all heats with registered athletes...';

    FOR heat_to_reseed IN
        SELECT DISTINCT round_heat_id
        FROM ss_heat_results
        ORDER BY round_heat_id
    LOOP
        RAISE NOTICE '--> Reseeding heat_id: %', heat_to_reseed.round_heat_id;
        CALL reseed_heat(heat_to_reseed.round_heat_id);
    END LOOP;

    RAISE NOTICE 'Step 5: Complete.';
END;
$procedure$;


CREATE OR REPLACE PROCEDURE public.ss_reset_data()
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    RAISE NOTICE 'Step 1: Clearing transactional data...';
    DELETE FROM ss_run_scores;
    DELETE FROM ss_run_results;
    DELETE FROM ss_heat_judges;
    DELETE FROM ss_heat_results;
    DELETE FROM ss_event_registrations; 
    DELETE FROM ss_heat_details;
    DELETE FROM ss_round_details;
    DELETE FROM ss_event_divisions;
    DELETE FROM ss_event_judges;
    DELETE FROM ss_events;
    DELETE FROM ss_athletes;
    RAISE NOTICE 'Step 1: Complete.';
END;
$procedure$;


CREATE OR REPLACE PROCEDURE public.ss_seed_athlete_data()
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    RAISE NOTICE 'Step 4: Populate athletes and registrations';

    INSERT INTO ss_athletes (athlete_id, last_name, first_name, dob, nationality, stance, gender, fis_num, fis_hp_points, fis_ss_points, fis_ba_points) VALUES
    (1, 'Adams', 'Kaitlyn', '2005-09-16', 'USA', 'Regular', 'Female', 9535573, NULL, 111.70, 157.30),
    (2, 'Adib-Samii', 'Alejandro', '2008-08-31', 'USA', 'Regular', 'Male', 9531806, NULL, 22.65, 42.30),
    (3, 'Alba', 'Sonora', '2006-07-16', 'USA', 'Goofy', 'Female', 9535609, 369.35, NULL, 37.50),
    (4, 'Avallone', 'Noah', '2007-05-16', 'USA', 'Goofy', 'Male', 9531687, 127.70, NULL, 48.85),
    (5, 'Bachman', 'Quinn', '2007-10-13', 'CAN', 'Regular', 'Male', 9101274, 10.35, NULL, 1.95),
    (6, 'Bald', 'Gus', '2003-12-20', 'AUS', NULL, 'Male', 9040319, NULL, 47.70, 33.85),
    (7, 'Bezushko', 'Zachary', '2008-01-06', 'CAN', 'Goofy', 'Male', 9101342, 22.50, 12.25, 41.75),
    (8, 'Boday', 'Gabriella', '2010-06-12', 'USA', 'Regular', 'Female', 9535746, 6.51, 19.60, 110.00),
    (9, 'Bouchard', 'Eli', '2007-12-07', 'CAN', 'Goofy', 'Male', 9101325, NULL, 587.50, 199.70),
    (10, 'Brayer', 'Katie', '2003-12-11', 'CAN', 'Regular', 'Female', 9105528, NULL, 2.81, 43.65),
    (11, 'Brienza', 'Giada', '2010-11-03', 'USA', 'Goofy', 'Female', 9535749, 59.10, 70.40, 108.85),
    (12, 'Briggs', 'Lucas', '2004-08-02', 'CAN', 'Goofy', 'Male', 9101108, 49.25, NULL, 1.82),
    (13, 'Buffey', 'William', '2002-07-16', 'CAN', 'Goofy', 'Male', 9100947, NULL, 64.20, 141.20),
    (14, 'Bullock-Womble', 'Fynn', '2005-02-03', 'USA', 'Regular', 'Male', 9531486, 0.15, 174.35, 334.05),
    (15, 'Cantelon', 'Jonah', '2002-12-09', 'CAN', 'Goofy', 'Male', 9101215, NULL, 45.25, 19.90),
    (16, 'Cantelon', 'Kobe', '2008-08-11', 'CAN', 'Regular', 'Male', 9101460, NULL, 101.10, 113.00),
    (17, 'Casas', 'Orion', '2009-09-22', 'USA', 'Regular', 'Male', 9531847, 113.75, NULL, NULL),
    (18, 'Coleman', 'Harry', '2006-02-22', 'GBR', 'Goofy', 'Male', 9220171, 45.35, 8.82, 12.15),
    (19, 'Cowan', 'Lola', '2005-06-06', 'CHI', 'Goofy', 'Female', 9535575, 49.60, 1.12, 0.94),
    (20, 'Cowan', 'Taitten', '2008-04-25', 'CHI', 'Goofy', 'Male', 9531746, 87.65, NULL, NULL),
    (21, 'Crouch', 'Brock', '1999-08-22', 'USA', 'Regular', 'Male', 9531095, NULL, 53.75, 266.30),
    (22, 'Dai', 'Yuyang', '2011-12-01', 'CHN', 'Goofy', 'Male', 9120162, 39.35, NULL, NULL),
    (23, 'Demchuk', 'Keenan', '2001-07-26', 'CAN', NULL, 'Male', 9101006, NULL, 110.85, 129.35),
    (24, 'DePriest', 'Brooklyn', '2006-02-21', 'USA', 'Regular', 'Male', 9531578, 0.09, 180.00, 238.00),
    (25, 'Dhawornvej', 'Lily', '2009-08-14', 'USA', 'Regular', 'Female', 9535706, NULL, 458.25, 371.90),
    (26, 'DHondt', 'Brooke', '2005-03-09', 'CAN', 'Regular', 'Female', 9105446, 351.14, NULL, 61.20),
    (27, 'Dicaire', 'Charles Emile', '2006-05-18', 'CAN', 'Goofy', 'Male', 9101495, NULL, 17.75, 16.55),
    (28, 'Douglas-Crampton', 'Zoe', '2008-12-14', 'CAN', 'Goofy', 'Female', 9105554, 5.98, NULL, 27.85),
    (29, 'Eckert', 'Coltan', '2003-10-06', 'CAN', NULL, 'Male', 9101220, NULL, 79.70, 119.95),
    (30, 'Elvy', 'Sascha', '2006-09-02', 'AUS', 'Goofy', 'Female', 9045145, 16.45, NULL, 0.14),
    (31, 'Ethier', 'Laurent', '2006-01-07', 'CAN', 'Goofy', 'Male', 9101314, NULL, 114.05, 114.75),
    (32, 'Fedorowycz', 'Lys', '2006-05-22', 'USA', 'Regular', 'Male', 9531605, 0.44, 93.25, 108.95),
    (33, 'Ferry', 'Lucas', '2004-06-16', 'USA', 'Regular', 'Male', 9531505, NULL, 100.30, 82.90),
    (34, 'FitzSimons', 'Sean', '2000-09-22', 'USA', 'Regular', 'Male', 9531194, 0.01, 166.55, 547.95),
    (35, 'Flynn', 'Rebecca', '2006-07-02', 'USA', 'Regular', 'Female', 9535600, NULL, 103.85, 540.25),
    (36, 'Foster', 'Lucas', '1999-09-17', 'CAN', 'Goofy', 'Male', 9531230, 417.10, NULL, NULL),
    (37, 'Garth', 'James', '2008-07-17', 'AUS', 'Regular', 'Male', 9040324, 0.37, 48.45, 56.65),
    (38, 'Ge', 'Chunyu', '2006-08-30', 'CHN', 'Goofy', 'Male', 9120153, NULL, 198.75, 112.55),
    (39, 'Geremia', 'Felicity', '2007-06-04', 'CAN', 'Goofy', 'Female', 9105513, 148.60, NULL, 1.66),
    (40, 'Germain', 'Kyle', '2008-02-15', 'CAN', 'Goofy', 'Male', 9101410, 24.60, NULL, 0.37),
    (41, 'Gjerdalen', 'Bendik', '1998-01-26', 'NOR', 'Regular', 'Male', 9420143, NULL, 178.60, 130.70),
    (42, 'Graven', 'Isla', '2011-04-02', 'CAN', 'Regular', 'Female', 9105593, 50.00, NULL, NULL),
    (43, 'Guerrero', 'Zoe', '2008-03-29', 'USA', 'Regular', 'Female', 9535679, 67.35, NULL, NULL),
    (44, 'Haskell', 'Amelie', '2008-01-08', 'AUS', 'Regular', 'Female', 9045157, 144.60, NULL, 0.25),
    (45, 'Hendrix', 'Barrett', '2006-10-31', 'USA', 'Regular', 'Female', 9535626, NULL, 27.70, 59.35),
    (46, 'Henkels', 'Tristam', '2009-11-29', 'USA', 'Regular', 'Male', 9531856, 82.20, NULL, 0.26),
    (47, 'Henkes', 'Justus', '2001-04-03', 'USA', 'Regular', 'Male', 9531241, 0.01, 120.78, 304.85),
    (48, 'Henriquez', 'Lj', '2008-03-19', 'USA', 'Regular', 'Male', 9531743, 0.53, 9.72, 60.00),
    (49, 'Hunter', 'Colin', '2006-01-26', 'CAN', 'Regular', 'Male', 9101302, NULL, 32.55, 46.35),
    (50, 'Jin', 'Rongxi', '2006-01-04', 'CHN', 'Goofy', 'Female', 9125129, NULL, 98.60, 45.75),
    (51, 'Krauskopf', 'Tosh', '2005-01-16', 'CAN', 'Regular', 'Male', 9101232, NULL, 57.75, 154.10),
    (52, 'Kyme', 'Samuel', '2008-11-26', 'CAN', 'Goofy', 'Male', 9101363, 5.46, 3.71, 31.70),
    (53, 'Lahiff', 'Keira', '2008-03-10', 'USA', 'Regular', 'Female', 9535665, 41.15, 0.18, 13.90),
    (54, 'LaMont', 'Terje', '2011-12-20', 'USA', 'Regular', 'Male', 9532082, 35.45, NULL, NULL),
    (55, 'Langbakk', 'Stian', '2009-10-08', 'CAN', 'Regular', 'Male', 9101420, NULL, 26.55, 55.90),
    (56, 'Leal', 'Luke', '2007-05-10', 'USA', 'Regular', 'Male', 9531682, 0.35, 34.20, 31.35),
    (57, 'Levere', 'Abenu', '2007-05-21', 'CAN', 'Goofy', 'Male', 9101426, 5.35, NULL, 1.95),
    (58, 'Lilly', 'Ava', '2009-10-05', 'USA', 'Regular', 'Female', 9535732, 96.05, NULL, 0.06),
    (59, 'Liu', 'Haoyu', '2004-04-11', 'CHN', NULL, 'Male', 9120057, NULL, 169.20, 110.65),
    (60, 'Mailer', 'Molly', '2007-12-14', 'CAN', 'Regular', 'Female', 9105540, 28.50, NULL, 4.95),
    (61, 'Martin', 'Oliver', '2008-06-15', 'USA', 'Regular', 'Male', 9531734, 3.28, 642.60, 848.30),
    (62, 'Matte', 'Maddox', '2007-11-04', 'CAN', 'Regular', 'Male', 9101370, NULL, 27.03, 77.50),
    (63, 'McCorrister', 'Maddox', '2007-09-06', 'CAN', NULL, 'Male', 9101323, NULL, NULL, 11.05),
    (64, 'Montalvo', 'Blake', '2008-03-08', 'CAN', 'Goofy', 'Male', 9101338, 18.65, 22.05, 41.90),
    (65, 'Neal', 'Kaylie', '2006-04-25', 'USA', 'Regular', 'Female', 9535610, 67.55, NULL, NULL),
    (66, 'Norman', 'Hahna', '2004-10-26', 'USA', 'Regular', 'Female', 9535624, 0.66, 368.10, 290.00),
    (67, 'Park', 'Cooper', '2009-07-01', 'CAN', 'Goofy', 'Male', 9101411, 5.33, 25.56, 54.85),
    (68, 'Pelchat', 'Juliette', '2004-12-04', 'CAN', 'Regular', 'Female', 9105462, NULL, 171.15, 184.10),
    (69, 'Pershad', 'Kiran', '2000-04-28', 'CAN', 'Goofy', 'Male', 9100953, 89.70, NULL, NULL),
    (70, 'Reimer', 'Neko', '2006-11-28', 'NZL', 'Regular', 'Male', 9410075, NULL, 41.05, 116.15),
    (71, 'Rice', 'Brian', '2004-12-20', 'USA', 'Goofy', 'Male', 9531517, 0.02, 139.20, 94.85),
    (72, 'Rummel', 'Courtney', '2003-11-12', 'USA', 'Regular', 'Female', 9535505, NULL, 116.50, 166.30),
    (73, 'Schwab', 'Alex', '2005-11-02', 'USA', 'Goofy', 'Male', 9531704, NULL, 52.65, 77.45),
    (74, 'Seidler', 'Katie', '2007-03-19', 'CAN', 'Regular', 'Female', 9105522, 23.40, NULL, NULL),
    (75, 'Slavinski', 'Alexandre', '2007-04-24', 'CAN', 'Goofy', 'Male', 9101431, NULL, 38.90, 52.20),
    (76, 'Smith', 'Truth', '2004-03-04', 'CAN', 'Goofy', 'Male', 9101123, NULL, 67.29, 220.75),
    (77, 'Solomon', 'Will', '2006-10-31', 'USA', 'Regular', 'Male', 9531684, NULL, 68.40, 100.95),
    (78, 'Spence', 'Jack', '2008-09-24', 'NZL', 'Regular', 'Male', 9410082, NULL, 27.24, 34.00),
    (79, 'Spitzer', 'Kai', '2005-12-13', 'CAN', 'Regular', 'Male', 9101456, NULL, 7.92, 24.70),
    (80, 'Stalker', 'Meila', '2004-02-04', 'AUS', 'Goofy', 'Female', 9045144, 0.09, 164.75, 274.15),
    (81, 'Taggart', 'Jack', '2008-01-28', 'USA', 'Regular', 'Male', 9531771, 0.12, 33.10, 63.95),
    (82, 'Tait', 'Sydney', '2008-07-04', 'CAN', 'Regular', 'Female', 9105521, 3.54, NULL, NULL),
    (83, 'Teixeira', 'Augustinho', '2005-03-01', 'BRA', 'Goofy', 'Male', 1084977, 132.25, 13.91, 42.33),
    (84, 'Teixeira', 'Joao', '2007-09-25', 'BRA', 'Goofy', 'Male', 1084984, 26.75, NULL, 0.63),
    (85, 'Tyler', 'Hayden', '2006-09-23', 'USA', 'Regular', 'Male', 9531583, 0.07, 34.25, 101.40),
    (86, 'Ullah', 'Siddhartha', '2006-10-14', 'GBR', 'Goofy', 'Male', 9531572, 133.45, NULL, NULL),
    (87, 'Vallerand', 'Juliette', '2009-08-21', 'CAN', 'Goofy', 'Female', 9105561, NULL, 49.15, 95.75),
    (88, 'Vicentelo', 'Mateo', '2006-12-30', 'CAN', 'Regular', 'Male', 9101498, NULL, 22.65, 31.15),
    (89, 'Vo', 'Ryan', '2004-02-27', 'CAN', 'Regular', 'Male', 9101134, 93.80, 5.28, 19.32),
    (90, 'Weaver', 'Lane', '2003-05-10', 'CAN', 'Goofy', 'Male', 9101200, NULL, 27.54, 73.70),
    (91, 'Weinberg', 'Rochelle', '2009-04-13', 'USA', 'Goofy', 'Female', 9535699, 135.70, NULL, NULL),
    (92, 'Wild', 'Aaron', '2009-01-01', 'GBR', 'Goofy', 'Male', 9531837, 73.80, NULL, 0.33),
    (93, 'Wild', 'Aimee', '2011-01-01', 'USA', 'Regular', 'Female', 9535784, 145.80, NULL, NULL),
    (94, 'Wilson', 'Keani', '2007-05-14', 'NZL', 'Regular', 'Male', 9410081, NULL, 1.80, 7.05),
    (95, 'Wolle', 'Jason', '1999-11-30', 'USA', 'Goofy', 'Male', 9531295, 310.00, NULL, NULL),
    (96, 'Wrobel', 'Evan', '2005-12-30', 'USA', NULL, 'Male', 9531581, NULL, 56.45, 140.95),
    (97, 'Wynnyk', 'Solomon', '2008-05-24', 'CAN', 'Regular', 'Male', 9101372, 0.36, 1.75, 16.75),
    (98, 'Xiong', 'Shirui', '2007-12-12', 'CHN', 'Regular', 'Female', 9125149, NULL, 261.55, 192.70),
    (99, 'Zhang', 'Xiaonan', '2006-03-15', 'CHN', 'Goofy', 'Female', 9125143, 418.10, NULL, 159.30);

    INSERT INTO ss_event_registrations (event_id, division_id, athlete_id, bib_num) VALUES
    (200, 4, 26, 1), (200, 4, 91, 2), (200, 4, 43, 3), (200, 4, 44, 4), (200, 4, 39, 5), (200, 4, 93, 6),
    (200, 4, 58, 7), (200, 4, 30, 8), (200, 4, 19, 9), (200, 4, 65, 10), (200, 4, 74, 11), (200, 4, 60, 12),
    (200, 4, 82, 13), (200, 4, 42, 14), (200, 3, 36, 20), (200, 3, 95, 21), (200, 3, 17, 22), (200, 3, 4, 23),
    (200, 3, 83, 24), (200, 3, 86, 25), (200, 3, 12, 26), (200, 3, 89, 27), (200, 3, 69, 29), (200, 3, 92, 30),
    (200, 3, 46, 31), (200, 3, 20, 32), (200, 3, 64, 36), (200, 3, 84, 41), (200, 3, 18, 42), (200, 3, 40, 43),
    (200, 3, 54, 44), (200, 3, 52, 46), (200, 3, 57, 47), (200, 3, 5, 48), (200, 3, 22, 49), (100, 3, 61, 47),
    (100, 3, 47, 50), (100, 3, 24, 43), (100, 3, 9, 46), (100, 3, 96, 49), (100, 3, 31, 62), (100, 3, 90, 53),
    (100, 3, 59, 64), (100, 3, 33, 57), (100, 3, 77, 59), (100, 3, 23, 60), (100, 3, 83, 65), (100, 3, 32, 66),
    (100, 3, 62, 97), (100, 3, 81, 72), (100, 3, 67, 71), (100, 3, 16, 74), (100, 3, 55, 75), (100, 3, 2, 76),
    (100, 3, 15, 79), (100, 3, 6, 80), (100, 3, 73, 83), (100, 3, 64, 85), (100, 3, 18, 86), (100, 3, 78, 87),
    (100, 3, 52, 91), (100, 3, 34, 41), (100, 3, 14, 42), (100, 3, 76, 48), (100, 3, 21, 44), (100, 3, 51, 52),
    (100, 3, 41, 56), (100, 3, 85, 54), (100, 3, 4, 55), (100, 3, 38, 58), (100, 3, 48, 94), (100, 3, 70, 61),
    (100, 3, 37, 63), (100, 3, 13, 67), (100, 3, 71, 68), (100, 3, 29, 69), (100, 3, 49, 93), (100, 3, 56, 73),
    (100, 3, 88, 96), (100, 3, 27, 95), (100, 3, 94, 77), (100, 3, 75, 81), (100, 3, 97, 82), (100, 3, 7, 84),
    (100, 3, 79, 89), (100, 3, 89, 90), (100, 3, 63, 92), (100, 4, 35, 10), (100, 4, 25, 11), (100, 4, 66, 12),
    (100, 4, 80, 13), (100, 4, 1, 14), (100, 4, 72, 18), (100, 4, 68, 15), (100, 4, 99, 16), (100, 4, 98, 17),
    (100, 4, 11, 20), (100, 4, 10, 32), (100, 4, 50, 19), (100, 4, 45, 21), (100, 4, 87, 35), (100, 4, 8, 23),
    (100, 4, 53, 24), (100, 4, 3, 27), (100, 4, 26, 29), (300, 3, 61, 20), (300, 3, 24, 23), (300, 3, 21, 24),
    (300, 3, 23, 27), (300, 3, 33, 29), (300, 3, 51, 35), (300, 3, 96, 36), (300, 3, 73, 44), (300, 3, 81, 52),
    (300, 3, 75, 46), (300, 3, 77, 48), (300, 3, 15, 61), (300, 3, 85, 62), (300, 3, 32, 76), (300, 3, 88, 77),
    (300, 3, 18, 82), (300, 3, 52, 83), (300, 3, 13, 88), (300, 3, 94, 89), (300, 3, 89, 92), (300, 3, 14, 21),
    (300, 3, 38, 22), (300, 3, 59, 25), (300, 3, 71, 26), (300, 3, 29, 32), (300, 3, 70, 33), (300, 3, 31, 39),
    (300, 3, 62, 41), (300, 3, 49, 47), (300, 3, 37, 93), (300, 3, 90, 55), (300, 3, 56, 60), (300, 3, 55, 65),
    (300, 3, 67, 73), (300, 3, 64, 80), (300, 3, 16, 81), (300, 3, 27, 85), (300, 3, 48, 86), (300, 3, 7, 90),
    (300, 3, 79, 91), (300, 4, 25, 1), (300, 4, 99, 2), (300, 4, 66, 3), (300, 4, 98, 7), (300, 4, 50, 9),
    (300, 4, 72, 11), (300, 4, 87, 12), (300, 4, 68, 5), (300, 4, 1, 14), (300, 4, 11, 15), (300, 4, 8, 17);

    UPDATE ss_heat_results
    SET round_heat_id = target_heat.round_heat_id
    FROM ss_heat_details AS current_heat, ss_heat_details AS target_heat 
    WHERE ss_heat_results.round_heat_id = current_heat.round_heat_id
    AND current_heat.round_id = target_heat.round_id AND target_heat.heat_num = 2
    AND ss_heat_results.event_id = 100 AND ss_heat_results.division_id = 3
    AND ss_heat_results.athlete_id IN (34, 14, 21, 76, 51, 85, 4, 41, 38, 70, 37, 13, 71, 29, 56, 94, 75, 97, 7, 79, 89, 63, 49, 48, 27, 88);

    UPDATE ss_heat_results
    SET round_heat_id = target_heat.round_heat_id
    FROM ss_heat_details AS current_heat, ss_heat_details AS target_heat 
    WHERE ss_heat_results.round_heat_id = current_heat.round_heat_id
    AND current_heat.round_id = target_heat.round_id AND target_heat.heat_num = 2
    AND ss_heat_results.event_id = 300 AND ss_heat_results.division_id = 3
    AND ss_heat_results.athlete_id IN (7, 14, 16, 27, 29, 31, 37, 38, 48, 49, 55, 56, 59, 62, 64, 67, 70, 71, 79, 90);
    
    RAISE NOTICE 'Step 4: Complete.';
END;
$procedure$;


CREATE OR REPLACE PROCEDURE public.ss_seed_event_data()
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    RAISE NOTICE 'Step 3: Seeding event data (events, heats, etc.)...';

    INSERT INTO ss_events (event_id, name, start_date, end_date, location, discipline_id, status) VALUES
    (100, 'NACP - Air Nation Slopestyle', '2025-02-25', '2025-02-25', 'Winsport', 'FREE_SS_SBD', 'Inactive'),
    (200, 'NACP - Air Nation Halfpipe', '2025-02-23', '2025-02-23', 'Winsport', 'FREE_HP_SBD', 'Inactive'),
    (300, 'NACP - Air Nation Big Air', '2025-02-26', '2025-02-27', 'Winsport', 'FREE_BA_SBD', 'Inactive');

    INSERT INTO ss_event_divisions (event_id, division_id, num_rounds) VALUES
    (100, 3, 2), (100, 4, 1), (200, 3, 1), (200, 4, 1), (300, 3, 2), (300, 4, 1);

    UPDATE ss_round_details SET num_heats = 2 WHERE event_id = 100 AND division_id = 3 AND round_name = 'Qualifications';
    UPDATE ss_round_details SET num_heats = 2 WHERE event_id = 300 AND division_id = 3 AND round_name = 'Qualifications';

    UPDATE ss_heat_details SET num_runs = 2 WHERE round_id IN (SELECT round_id FROM ss_round_details WHERE event_id = 100 AND division_id = 3 AND round_name = 'Qualifications');
    UPDATE ss_heat_details SET num_runs = 2 WHERE round_id IN (SELECT round_id FROM ss_round_details WHERE event_id = 100 AND division_id = 3 AND round_name = 'Finals');
    UPDATE ss_heat_details SET num_runs = 2 WHERE round_id IN (SELECT round_id FROM ss_round_details WHERE event_id = 300 AND division_id = 3 AND round_name = 'Qualifications');
    UPDATE ss_heat_details SET num_runs = 2 WHERE round_id IN (SELECT round_id FROM ss_round_details WHERE event_id = 200 AND division_id = 3 AND round_name = 'Finals');
    UPDATE ss_heat_details SET num_runs = 2 WHERE round_id IN (SELECT round_id FROM ss_round_details WHERE event_id = 200 AND division_id = 4 AND round_name = 'Finals');

    PERFORM add_event_judge(100, 'Judge 1');
    PERFORM add_event_judge(100, 'Judge 2');
    PERFORM add_event_judge(100, 'Judge 3');
    PERFORM add_event_judge(100, 'Judge 4');
    PERFORM add_event_judge(100, 'Judge 5');
    PERFORM add_event_judge(100, 'Judge 6');
    PERFORM add_event_judge(200, 'Judge 1');
    PERFORM add_event_judge(200, 'Judge 2');
    PERFORM add_event_judge(200, 'Judge 3');
    PERFORM add_event_judge(200, 'Judge 4');
    PERFORM add_event_judge(200, 'Judge 5');
    PERFORM add_event_judge(300, 'Judge 1');
    PERFORM add_event_judge(300, 'Judge 2');
    PERFORM add_event_judge(300, 'Judge 3');
    PERFORM add_event_judge(300, 'Judge 4');
    PERFORM add_event_judge(300, 'Judge 5');

    RAISE NOTICE 'Step 3: Complete.';
END;
$procedure$;


CREATE OR REPLACE PROCEDURE public.ss_seed_lookup_tables()
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    RAISE NOTICE 'Step 2: Seeding lookup tables (roles, disciplines, divisions)...';
    
    INSERT INTO ss_roles (role_id, role_name) VALUES
    (1, 'Executive Director'), (2, 'Administrator'), (3, 'Chief of Competition'),
    (4, 'Technical Director'), (5, 'Head Judge'), (6, 'Volunteer'), (7, 'Coach')
    ON CONFLICT (role_id) DO NOTHING;

    INSERT INTO ss_disciplines (discipline_id, category_name, subcategory_name, discipline_name) VALUES
    ('FREE_BA_SBD', 'Freestyle', 'Big Air', 'Snowboard'), ('FREE_HP_SBD', 'Freestyle', 'Halfpipe', 'Snowboard'),
    ('FREE_SS_SBD', 'Freestyle', 'Slopestyle', 'Snowboard'), ('ALP_SBX_SBD', 'Alpine', 'Snowboard Cross', 'Snowboard'),
    ('FREE_BA_SKI', 'Freestyle', 'Big Air', 'Ski'), ('FREE_HP_SKI', 'Freestyle', 'Halfpipe', 'Ski')
    -- ('FREE_SS_SKI', 'Freestyle', 'Slopestyle', 'Ski'), ('ALP_SL_SKI', 'Alpine', 'Slalom', 'Ski'),
    -- ('FREE_MOG_SKI', 'Freestyle', 'Moguls', 'Ski'), ('ALP_DH_SKI', 'Alpine', 'Downhill', 'Ski'),
    -- ('ALP_SG_SKI', 'Alpine', 'Super-G', 'Ski'), ('ALP_GS_SKI', 'Alpine', 'Giant Slalom', 'Ski'),
    -- ('ALP_SKX_SKI', 'Alpine', 'Ski Cross', 'Ski'), ('NORD_SP_SKI', 'Nordic', 'Sprint', 'Ski'),
    -- ('NORD_DIST_SKI', 'Nordic', 'Distance', 'Ski'), ('NORD_CP_SKI', 'Nordic', 'Combined Pursuit', 'Ski'),
    -- ('NORD_JUMP_SKI', 'Nordic', 'Ski Jumping', 'Ski'), ('SNOW_PS_SBD', 'Snowboard', 'Parallel Slalom', 'Snowboard'),
    -- ('SNOW_PGS_SBD', 'Snowboard', 'Parallel Giant Slalom', 'Snowboard'), ('FREESKI_BX_SKI', 'Freeski', 'Big Air', 'Ski')
    ON CONFLICT (discipline_id) DO NOTHING;

    INSERT INTO ss_division(division_id, division_name) VALUES
    (1, 'Male'), (2, 'Female'), (3, 'Men'), (4, 'Women')
    ON CONFLICT DO NOTHING;

    RAISE NOTICE 'Step 2: Complete.';
END;
$procedure$;


CREATE OR REPLACE PROCEDURE public.ss_synchronize_sequences()
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    RAISE NOTICE 'Step 7: Synchronizing SERIAL sequences...';
    
    PERFORM setval('ss_users_user_id_seq', (SELECT COALESCE(max(user_id), 1) FROM ss_users), true);
    PERFORM setval('ss_division_division_id_seq', (SELECT COALESCE(max(division_id), 1) FROM ss_division), true);
    PERFORM setval('ss_athletes_athlete_id_seq', (SELECT COALESCE(max(athlete_id), 1) FROM ss_athletes), true);
    PERFORM setval('ss_events_event_id_seq', (SELECT COALESCE(max(event_id), 1) FROM ss_events), true);
    PERFORM setval('ss_round_details_round_id_seq', (SELECT COALESCE(max(round_id), 1) FROM ss_round_details), true);
    PERFORM setval('ss_heat_details_round_heat_id_seq', (SELECT COALESCE(max(round_heat_id), 1) FROM ss_heat_details), true);
    PERFORM setval('ss_run_results_run_result_id_seq', (SELECT COALESCE(max(run_result_id), 1) FROM ss_run_results), true);
    PERFORM setval('ss_event_judges_personnel_id_seq', (SELECT COALESCE(max(personnel_id), 1) FROM ss_event_judges), true);
    
    RAISE NOTICE 'Step 7: Complete.';
END;
$procedure$;


CREATE OR REPLACE PROCEDURE public.update_run_score(IN p_event_id integer, IN p_athlete_first_name character varying, IN p_athlete_last_name character varying, IN p_round_name character varying, IN p_run_num integer, IN p_judge_header character varying, IN p_score numeric)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_athlete_id INT;
    v_personnel_id INT;
    v_run_result_id INT;
    v_round_heat_id INT;
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

    SELECT T1.run_result_id, T1.round_heat_id 
    INTO v_run_result_id, v_round_heat_id
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

    INSERT INTO ss_run_scores (run_result_id, personnel_id, round_heat_id, score)
    VALUES (v_run_result_id, v_personnel_id, v_round_heat_id, p_score)
    ON CONFLICT (run_result_id, personnel_id) DO UPDATE
    SET score = EXCLUDED.score;

END;
$procedure$;
