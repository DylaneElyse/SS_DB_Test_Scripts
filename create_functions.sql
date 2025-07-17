-- 1.
CREATE OR REPLACE FUNCTION handle_event_divisions()
    RETURNS TRIGGER AS $$
DECLARE
    v_round_list TEXT[];
BEGIN
    IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE' AND NEW.num_rounds IS DISTINCT FROM OLD.num_rounds) THEN

        IF TG_OP = 'UPDATE' THEN
            DELETE FROM ss_round_details WHERE event_id = OLD.event_id AND division_id = OLD.division_id;
        END IF;

        v_round_list := CASE NEW.num_rounds
            WHEN 1 THEN ARRAY['Finals']
            WHEN 2 THEN ARRAY['Qualifications', 'Finals']
            WHEN 3 THEN ARRAY['Qualifications', 'Semi-Finals', 'Finals']
            WHEN 4 THEN ARRAY['Qualifications', 'Quarter-Finals', 'Semi-Finals', 'Finals']
            ELSE ARRAY[]::TEXT[]
        END;

        IF array_length(v_round_list, 1) > 0 THEN
            INSERT INTO ss_round_details (event_id, division_id, round_num, round_name, num_heats)
            SELECT
                NEW.event_id,
                NEW.division_id,
                round_number,
                v_round_list[round_number],
                1 
            FROM generate_series(1, NEW.num_rounds) AS round_number;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- 2.
CREATE OR REPLACE FUNCTION handle_round_details()
    RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE' AND NEW.num_heats IS DISTINCT FROM OLD.num_heats) THEN

        IF TG_OP = 'UPDATE' THEN
            DELETE FROM ss_heat_details WHERE round_id = OLD.round_id;
        END IF;

        IF NEW.num_heats > 0 THEN
            INSERT INTO ss_heat_details (round_id, heat_num)
            SELECT
                NEW.round_id,
                i
            FROM generate_series(1, NEW.num_heats) AS i;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- 3.
CREATE OR REPLACE FUNCTION handle_insert_on_heat_details()
    RETURNS trigger
	AS $function$
DECLARE
    v_event_id INT;
    v_division_id INT;
    v_num_rounds INT;
    v_round_heat_id INT := new.round_heat_id;
    v_round_id INT := new.round_id;
BEGIN
    SELECT rd.event_id, rd.division_id
    INTO v_event_id, v_division_id
    FROM ss_round_details rd
    WHERE v_round_id = rd.round_id;

    SELECT COUNT(*)
    INTO v_num_rounds
    FROM ss_round_details rd
    WHERE rd.event_id = v_event_id AND rd.division_id = v_division_id;

    IF v_num_rounds > 1 THEN
        SELECT INTO v_round_heat_id
            FROM ss_heat_details hd
            JOIN ss_round_details rd ON hd.round_id = rd.round_id
            WHERE rd.round_id = v_round_id
            AND rd.round_num = 1;

        INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
        SELECT
            v_round_heat_id,
            rd.event_id,
            rd.division_id,
            reg.athlete_id,
            0
        FROM
            ss_event_registrations reg
        INNER JOIN ss_round_details rd ON reg.event_id = rd.event_id AND reg.division_id = rd.division_id
        WHERE
            rd.round_id = v_round_id
            AND NOT EXISTS (
                SELECT 1
                FROM ss_heat_results hr
                INNER JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
                WHERE hd.round_id = v_round_id AND hr.athlete_id = reg.athlete_id
            )
        ON CONFLICT (round_heat_id, athlete_id) DO NOTHING;

        IF NOT FOUND THEN
            RAISE NOTICE 'Heat created (round_heat_id=%), but no available athletes were found to add.', v_round_heat_id;
        END IF;

    END IF;

	RETURN NULL;
END;
$function$ LANGUAGE plpgsql;


-- 4.
CREATE OR REPLACE FUNCTION handle_update_on_heat_details()
    RETURNS TRIGGER AS $trigger$
BEGIN
    IF NEW.num_runs IS DISTINCT FROM OLD.num_runs THEN
        RAISE NOTICE 'num_runs changed for round_heat_id=%. Re-creating athlete run results.', NEW.round_heat_id;
        DELETE FROM ss_heat_results WHERE round_heat_id = NEW.round_heat_id;

        INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
        SELECT NEW.round_heat_id, rd.event_id, rd.division_id, reg.athlete_id, 0
        FROM ss_event_registrations AS reg
        JOIN ss_round_details AS rd ON reg.event_id = rd.event_id AND reg.division_id = rd.division_id
        WHERE rd.round_id = NEW.round_id;
        
        CALL reseed_heat(NEW.round_heat_id);
    END IF;

    -- This condition is for when a heat is moved to a different round.
    -- Moving a heat does NOT change the athletes in it, so reseeding is not necessary.
    -- IF NEW.round_id IS DISTINCT FROM OLD.round_id THEN
    --    CALL reseed_heat(NEW.round_heat_id); -- This call is likely unnecessary and can be removed.
    -- END IF;

    RETURN NEW;
END;
$trigger$ LANGUAGE plpgsql;


-- 5.
CREATE OR REPLACE FUNCTION manage_registration_reseeding()
    RETURNS TRIGGER AS $function$
DECLARE
    v_round_heat_id INTEGER;
BEGIN
    -- This temporary table will hold the unique heat IDs that need reseeding.
    CREATE TEMP TABLE heats_to_reseed (round_heat_id INT PRIMARY KEY) ON COMMIT DROP;

    -- Collect affected heat IDs from all changed rows (INSERT, UPDATE, DELETE)
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO heats_to_reseed
        SELECT DISTINCT hr.round_heat_id
        FROM new_rows nr
        JOIN ss_heat_results hr ON nr.athlete_id = hr.athlete_id
        JOIN ss_round_details rd ON hr.event_id = rd.event_id AND hr.division_id = rd.division_id
        WHERE rd.event_id = nr.event_id AND rd.division_id = nr.division_id;
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        -- Heats the athlete moved FROM
        INSERT INTO heats_to_reseed
        SELECT DISTINCT hr.round_heat_id
        FROM old_rows o
        JOIN ss_heat_results hr ON o.athlete_id = hr.athlete_id
        JOIN ss_round_details rd ON hr.event_id = rd.event_id AND hr.division_id = rd.division_id
        WHERE rd.event_id = o.event_id AND rd.division_id = o.division_id
        ON CONFLICT (round_heat_id) DO NOTHING;

        -- Heats the athlete moved TO
        INSERT INTO heats_to_reseed
        SELECT DISTINCT hr.round_heat_id
        FROM new_rows n
        JOIN ss_heat_results hr ON n.athlete_id = hr.athlete_id
        JOIN ss_round_details rd ON hr.event_id = rd.event_id AND hr.division_id = rd.division_id
        WHERE rd.event_id = n.event_id AND rd.division_id = n.division_id
        ON CONFLICT (round_heat_id) DO NOTHING;
    END IF;

    IF (TG_OP = 'DELETE') THEN
        INSERT INTO heats_to_reseed
        SELECT DISTINCT hr.round_heat_id
        FROM old_rows o
        JOIN ss_heat_results hr ON o.athlete_id = hr.athlete_id
        JOIN ss_round_details rd ON hr.event_id = rd.event_id AND hr.division_id = rd.division_id
        WHERE rd.event_id = o.event_id AND rd.division_id = o.division_id
        ON CONFLICT (round_heat_id) DO NOTHING;
    END IF;

    -- Now, loop through the UNIQUE list of heats and call reseed only once per heat.
    FOR v_round_heat_id IN SELECT round_heat_id FROM heats_to_reseed
    LOOP
        CALL reseed_heat(v_round_heat_id);
    END LOOP;

    RETURN NULL;
END;
$function$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION handle_insert_on_event_registrations()
--     RETURNS trigger
-- 	AS $function$
-- DECLARE
--     target_round_heat_id INT;
-- BEGIN
--     IF EXISTS (
--         SELECT 1
--         FROM ss_heat_results hr
--         JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
--         JOIN ss_round_details rd ON hd.round_id = rd.round_id
--         WHERE hr.athlete_id = NEW.athlete_id
--             AND rd.event_id = NEW.event_id
--             AND rd.division_id = NEW.division_id
--     ) THEN
--         RAISE NOTICE 'Athlete ID % is already assigned to a heat for this event/division. No action taken.', NEW.athlete_id;
--         RETURN NEW;
--     END IF;

--     SELECT
--         hd.round_heat_id INTO target_round_heat_id
--     FROM
--         ss_round_details AS rd
--     JOIN
--         ss_heat_details AS hd ON rd.round_id = hd.round_id
--     WHERE
--         rd.event_id = NEW.event_id
--         AND rd.division_id = NEW.division_id
--         AND rd.round_num = 1 
--         AND hd.heat_num = 1
--     LIMIT 1;

--     IF target_round_heat_id IS NULL THEN
--         RAISE EXCEPTION 'Registration failed: Round 1, Heat 1 is not defined for event_id=%, division_id=%.', NEW.event_id, NEW.division_id
--         USING HINT = 'Please ensure that at least one round (with round_num=1) and one heat (with heat_num=1) have been created for this event and division.';
--     END IF;

--     INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
--     VALUES (target_round_heat_id, NEW.event_id, NEW.division_id, NEW.athlete_id, 0);

--     CALL reseed_heat(target_round_heat_id);

--     RETURN NEW;
-- END;
-- $function$ LANGUAGE plpgsql;


-- -- 6.
-- CREATE OR REPLACE FUNCTION handle_update_on_event_registrations()
--     RETURNS TRIGGER 
-- 	AS $function$
-- BEGIN
--     IF NEW.event_id IS DISTINCT FROM OLD.event_id OR NEW.division_id IS DISTINCT FROM OLD.division_id THEN
--         DELETE FROM ss_heat_results AS shr
--         USING
--             ss_heat_details AS hd
--             INNER JOIN ss_round_details AS rd ON hd.round_id = rd.round_id
--         WHERE rd.event_id = OLD.event_id
--             AND rd.division_id = OLD.division_id
--             AND shr.round_heat_id = hd.round_heat_id
--             AND shr.athlete_id = OLD.athlete_id;

--         INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
--         SELECT
--             hd.round_heat_id,
--             NEW.event_id,
--             NEW.division_id,
--             NEW.athlete_id,
--             0
--         FROM ss_round_details AS rd
--         INNER JOIN ss_heat_details AS hd
--             ON rd.round_id = hd.round_id
--         WHERE rd.event_id = NEW.event_id
--             AND rd.division_id = NEW.division_id
--         ON CONFLICT (round_heat_id, athlete_id) DO NOTHING;

--         IF NOT FOUND THEN
--             RAISE EXCEPTION 'Update failed: Cannot move registration. No heats are defined for the destination: event_id=%, division_id=%.', NEW.event_id, NEW.division_id
--                 USING HINT = 'Please create at least one round and one heat for the target event/division before updating the registration.';
--         END IF;
--     END IF;

--     RETURN NEW;
-- END;
-- $function$ LANGUAGE plpgsql;


-- -- 7.
-- CREATE OR REPLACE FUNCTION reseed_affected_heats()
--     RETURNS TRIGGER AS $function$
-- DECLARE
--     v_round_heat_id INTEGER;
-- BEGIN
--     FOR v_round_heat_id IN
--         SELECT DISTINCT hd.round_heat_id
--         FROM new_rows AS nr 
--         INNER JOIN ss_round_details AS rd ON nr.event_id = rd.event_id AND nr.division_id = rd.division_id
--         INNER JOIN ss_heat_details AS hd ON rd.round_id = hd.round_id
--     LOOP
--         CALL reseed_heat(v_round_heat_id);
--     END LOOP;
--     RETURN NULL; 
-- END;
-- $function$ LANGUAGE plpgsql;


-- -- 8.
-- CREATE OR REPLACE FUNCTION reseed_after_update()
--     RETURNS TRIGGER AS $trigger$
-- DECLARE
--     v_round_heat_id INTEGER;
-- BEGIN
--     FOR v_round_heat_id IN
--         SELECT DISTINCT hd.round_heat_id
--         FROM old_rows AS o
--         JOIN ss_round_details AS rd ON rd.event_id = o.event_id AND rd.division_id = o.division_id
--         JOIN ss_heat_details AS hd ON hd.round_id = rd.round_id
--         UNION
--         SELECT DISTINCT hd.heat_id
--         FROM new_rows AS n
--         JOIN ss_round_details AS rd ON rd.event_id = n.event_id AND rd.division_id = n.division_id
--         JOIN ss_heat_details AS hd ON hd.round_id = rd.round_id
--     LOOP
--         CALL reseed_heat(v_round_heat_id);
--     END LOOP;

--     RETURN NULL;
-- END;
-- $trigger$ LANGUAGE plpgsql;


-- 9.
CREATE OR REPLACE FUNCTION handle_insert_on_heat_results()
	RETURNS TRIGGER AS $function$
DECLARE
    v_num_runs ss_heat_details.num_runs%TYPE;
BEGIN
    SELECT num_runs INTO v_num_runs FROM ss_heat_details WHERE round_heat_id = NEW.round_heat_id;
    IF v_num_runs > 0 THEN
        INSERT INTO ss_run_results (round_heat_id, event_id, division_id, athlete_id, run_num)
        SELECT NEW.round_heat_id, NEW.event_id, NEW.division_id, NEW.athlete_id, i
        FROM generate_series(1, v_num_runs) AS i
        ON CONFLICT DO NOTHING;
    END IF;
    RETURN NULL;
END;
$function$ LANGUAGE plpgsql;


-- 10.
CREATE OR REPLACE FUNCTION handle_update_on_heat_results()
    RETURNS TRIGGER AS $function$
BEGIN
    -- If an athlete is moved to a new heat, update their child run_results to follow.
    IF NEW.round_heat_id IS DISTINCT FROM OLD.round_heat_id THEN
        UPDATE ss_run_results
        SET round_heat_id = NEW.round_heat_id
        WHERE round_heat_id = OLD.round_heat_id
            AND event_id = OLD.event_id
            AND division_id = OLD.division_id
            AND athlete_id = OLD.athlete_id;
    END IF;
    RETURN NULL;
END;
$function$ LANGUAGE plpgsql;


-- 11.
CREATE OR REPLACE FUNCTION handle_insert_on_event_judges()
RETURNS TRIGGER AS $function$
BEGIN
    INSERT INTO ss_run_scores (personnel_id, run_result_id)
    SELECT NEW.personnel_id, r.run_result_id
    FROM ss_run_results AS r
    WHERE r.event_id = NEW.event_id
    ON CONFLICT (personnel_id, run_result_id) DO NOTHING;
    RETURN NULL;
END;
$function$ LANGUAGE plpgsql;


-- 12.
CREATE OR REPLACE FUNCTION prevent_invalid_judge_update()
    RETURNS TRIGGER AS $function$
BEGIN
    IF NEW.personnel_id IS DISTINCT FROM OLD.personnel_id OR NEW.event_id IS DISTINCT FROM OLD.event_id THEN
        IF EXISTS (SELECT 1 FROM ss_run_scores s JOIN ss_run_results r ON s.run_result_id = r.run_result_id WHERE s.personnel_id = OLD.personnel_id AND r.event_id = OLD.event_id AND s.score IS NOT NULL) THEN
            RAISE EXCEPTION 'Update failed. Judge (ID: %) cannot be removed from event (ID: %) because they have already submitted scores.', OLD.personnel_id, OLD.event_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$function$ LANGUAGE plpgsql;


-- 13.
CREATE OR REPLACE FUNCTION generate_random_4_digit_code()
    RETURNS TEXT AS $function$
DECLARE
    v_random_code TEXT;
    v_is_unique   BOOLEAN := FALSE;
BEGIN
    WHILE NOT v_is_unique LOOP
        v_random_code := lpad(floor(random() * 10000)::TEXT, 4, '0');
        SELECT NOT EXISTS (SELECT 1 FROM ss_event_judges WHERE passcode = v_random_code) INTO v_is_unique;
    END LOOP;
    RETURN v_random_code;
END;
$function$ LANGUAGE plpgsql VOLATILE;


-- 14.
CREATE OR REPLACE FUNCTION set_judge_passcode_if_null()
    RETURNS TRIGGER AS $function$
BEGIN
    IF NEW.passcode IS NULL THEN
        NEW.passcode := generate_random_4_digit_code();
    END IF;
    RETURN NEW;
END;
$function$ LANGUAGE plpgsql;


-- 15.
CREATE OR REPLACE FUNCTION manage_run_scores_from_run_result()
    RETURNS TRIGGER AS $$
DECLARE
    v_event_id INTEGER;
BEGIN
    IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE' AND NEW.round_heat_id IS DISTINCT FROM OLD.round_heat_id) THEN
        IF TG_OP = 'UPDATE' THEN
            DELETE FROM ss_run_scores WHERE run_result_id = OLD.run_result_id;
        END IF;
        SELECT rd.event_id INTO v_event_id FROM ss_heat_details hd JOIN ss_round_details rd ON hd.round_id = rd.round_id WHERE hd.round_heat_id = NEW.round_heat_id;
        IF v_event_id IS NOT NULL THEN
            INSERT INTO ss_run_scores (personnel_id, run_result_id)
            SELECT j.personnel_id, NEW.run_result_id FROM ss_event_judges AS j WHERE j.event_id = v_event_id
            ON CONFLICT (personnel_id, run_result_id) DO NOTHING;
        END IF;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- 16.
CREATE OR REPLACE FUNCTION handle_run_results()
    RETURNS TRIGGER AS $$
DECLARE
    v_event_id INTEGER;
BEGIN
    IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE' AND NEW.round_heat_id IS DISTINCT FROM OLD.round_heat_id) THEN

        IF TG_OP = 'UPDATE' THEN
            DELETE FROM ss_run_scores WHERE run_result_id = OLD.run_result_id;
        END IF;

        SELECT rd.event_id INTO v_event_id
        FROM ss_heat_details hd
        JOIN ss_round_details rd ON hd.round_id = rd.round_id
        WHERE hd.round_heat_id = NEW.round_heat_id;

        IF v_event_id IS NOT NULL THEN
            INSERT INTO ss_run_scores (personnel_id, run_result_id)
            SELECT j.personnel_id, NEW.run_result_id
            FROM ss_event_judges AS j
            WHERE j.event_id = v_event_id
            ON CONFLICT (personnel_id, run_result_id) DO NOTHING;
        END IF;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- 17.
CREATE OR REPLACE FUNCTION trg_start_score_calculation_chain()
    RETURNS TRIGGER LANGUAGE plpgsql AS $function$
DECLARE
    v_run_result_id INTEGER;
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        v_run_result_id := NEW.run_result_id;
    ELSE
        v_run_result_id := OLD.run_result_id;
    END IF;
    CALL calculate_average_score(v_run_result_id);
    RETURN NULL;
END;
$function$;



