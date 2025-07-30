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
                (NEW.num_rounds - i + 1) AS calculated_round_num,
                v_round_list[i] AS round_name,
                1 
            FROM generate_series(1, NEW.num_rounds) AS i;
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
    v_round_num INT;
    v_max_round_num INT;
BEGIN
    SELECT rd.event_id, rd.division_id, rd.round_num
    INTO v_event_id, v_division_id, v_round_num
    FROM ss_round_details rd
    WHERE rd.round_id = NEW.round_id;

    SELECT MAX(rd.round_num)
    INTO v_max_round_num
    FROM ss_round_details rd
    WHERE rd.event_id = v_event_id AND rd.division_id = v_division_id;

    IF v_round_num = v_max_round_num THEN
        RAISE NOTICE 'New heat % is in the entry round (%). Populating with registered athletes.', NEW.round_heat_id, v_round_num;

        INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
        SELECT
            NEW.round_heat_id, 
            reg.event_id,
            reg.division_id,
            reg.athlete_id,
            0
        FROM
            ss_event_registrations reg
        WHERE
            reg.event_id = v_event_id
            AND reg.division_id = v_division_id
            AND NOT EXISTS (
                SELECT 1
                FROM ss_heat_results hr
                WHERE hr.athlete_id = reg.athlete_id AND hr.event_id = reg.event_id AND hr.division_id = reg.division_id
            )
        ON CONFLICT (round_heat_id, athlete_id) DO NOTHING;

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
CREATE OR REPLACE FUNCTION handle_insert_on_event_registrations()
    RETURNS TRIGGER AS $$
DECLARE
    target_round_heat_id INT;
BEGIN
    SELECT hd.round_heat_id 
    INTO target_round_heat_id
    FROM ss_round_details AS rd
    JOIN ss_heat_details AS hd ON rd.round_id = hd.round_id
    WHERE rd.event_id = NEW.event_id
      AND rd.division_id = NEW.division_id
      AND hd.heat_num = 1
    ORDER BY rd.round_num DESC 
    LIMIT 1;

    IF target_round_heat_id IS NOT NULL THEN
        INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
        VALUES (target_round_heat_id, NEW.event_id, NEW.division_id, NEW.athlete_id, 0);
    ELSE
        RAISE WARNING 'Registration for Athlete ID % processed, but could not be placed in a heat. No entry round (e.g. Qualifications) found.', NEW.athlete_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- 6.
CREATE OR REPLACE FUNCTION handle_update_on_event_registrations()
    RETURNS TRIGGER AS $$
DECLARE
    target_round_heat_id INT;
BEGIN
    IF (NEW.event_id, NEW.division_id) IS DISTINCT FROM (OLD.event_id, OLD.division_id) THEN
        DELETE FROM ss_heat_results AS shr
        USING ss_heat_details AS hd, ss_round_details AS rd
        WHERE rd.event_id = OLD.event_id
          AND rd.division_id = OLD.division_id
          AND hd.round_id = rd.round_id
          AND shr.round_heat_id = hd.round_heat_id
          AND shr.athlete_id = OLD.athlete_id;

        SELECT hd.round_heat_id 
        INTO target_round_heat_id
        FROM ss_round_details AS rd
        JOIN ss_heat_details AS hd ON rd.round_id = hd.round_id
        WHERE rd.event_id = NEW.event_id
          AND rd.division_id = NEW.division_id
          AND hd.heat_num = 1
        ORDER BY rd.round_num DESC 
        LIMIT 1;

        IF target_round_heat_id IS NOT NULL THEN
            INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
            VALUES (target_round_heat_id, NEW.event_id, NEW.division_id, NEW.athlete_id, 0);
        ELSE
            RAISE WARNING 'Athlete % moved, but could not be placed in a new heat. No entry round found.', NEW.athlete_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- 7.
CREATE OR REPLACE FUNCTION manage_heat_reseeding()
    RETURNS TRIGGER AS $$
DECLARE
    v_heat_ids_to_reseed INT[];
    v_heat_id INT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_heat_ids_to_reseed := ARRAY(SELECT DISTINCT round_heat_id FROM new_rows);
    ELSIF TG_OP = 'DELETE' THEN
        v_heat_ids_to_reseed := ARRAY(SELECT DISTINCT round_heat_id FROM old_rows);
        
    ELSIF TG_OP = 'UPDATE' THEN
        v_heat_ids_to_reseed := ARRAY(
            SELECT round_heat_id FROM (
                SELECT o.round_heat_id 
                FROM old_rows o
                JOIN new_rows n ON o.athlete_id = n.athlete_id
                WHERE o.round_heat_id IS DISTINCT FROM n.round_heat_id
                
                UNION
                
                SELECT n.round_heat_id 
                FROM old_rows o
                JOIN new_rows n ON o.athlete_id = n.athlete_id
                WHERE o.round_heat_id IS DISTINCT FROM n.round_heat_id
            ) AS changed_heats
        );
    END IF;

    IF array_length(v_heat_ids_to_reseed, 1) IS NULL THEN
        RETURN NULL;
    END IF;

    FOREACH v_heat_id IN ARRAY v_heat_ids_to_reseed
    LOOP
        RAISE NOTICE 'Heat roster changed for heat_id: %. Automatically reseeding.', v_heat_id;
        CALL reseed_heat(v_heat_id);
    END LOOP;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- 8.
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


-- 9.
CREATE OR REPLACE FUNCTION handle_update_on_heat_results()
    RETURNS TRIGGER AS $function$
BEGIN
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


-- 10.
CREATE OR REPLACE FUNCTION prevent_event_judge_reassignment()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM ss_run_scores 
        WHERE personnel_id = OLD.personnel_id AND score IS NOT NULL
    ) THEN
        RAISE EXCEPTION 'Update failed. Judge (ID: %) cannot be reassigned to a new event because they have already submitted scores for event (ID: %).', OLD.personnel_id, OLD.event_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- 11.
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


-- 12.
CREATE OR REPLACE FUNCTION set_judge_passcode_if_null()
    RETURNS TRIGGER AS $function$
BEGIN
    IF NEW.passcode IS NULL THEN
        NEW.passcode := generate_random_4_digit_code();
    END IF;
    RETURN NEW;
END;
$function$ LANGUAGE plpgsql;


-- 13.
CREATE OR REPLACE FUNCTION handle_insert_on_run_results()
    RETURNS TRIGGER AS $$
DECLARE
    v_event_id INTEGER;
BEGIN
    IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE' AND NEW.round_heat_id IS DISTINCT FROM OLD.round_heat_id) THEN

        IF TG_OP = 'UPDATE' THEN
            DELETE FROM ss_run_scores WHERE run_result_id = OLD.run_result_id;
        END IF;

        v_event_id := NEW.event_id;

        IF v_event_id IS NOT NULL THEN
            INSERT INTO ss_run_scores (personnel_id, run_result_id, round_heat_id)
            SELECT 
                hj.personnel_id, 
                NEW.run_result_id,
                NEW.round_heat_id
            FROM ss_heat_judges AS hj
            WHERE hj.round_heat_id = NEW.round_heat_id
            ON CONFLICT (personnel_id, run_result_id) DO NOTHING;
        END IF;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- 14.
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


-- 15.
CREATE OR REPLACE FUNCTION prevent_heat_judge_reassignment()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM ss_run_scores 
        WHERE personnel_id = OLD.personnel_id 
          AND round_heat_id = OLD.round_heat_id 
          AND score IS NOT NULL
    ) THEN
        RAISE EXCEPTION 'Update failed. Judge (ID: %) cannot be removed from heat (ID: %) because they have already submitted scores for it.', OLD.personnel_id, OLD.round_heat_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- 16.
CREATE OR REPLACE FUNCTION handle_update_on_heat_judges()
    RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Judge assignment updated. Creating placeholder scores for personnel_id % in new heat_id %', NEW.personnel_id, NEW.round_heat_id;
    
    INSERT INTO ss_run_scores (personnel_id, run_result_id, round_heat_id)
    SELECT 
        NEW.personnel_id, 
        r.run_result_id, 
        r.round_heat_id
    FROM ss_run_results AS r
    WHERE r.round_heat_id = NEW.round_heat_id
    ON CONFLICT (personnel_id, run_result_id) DO NOTHING;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- 17.
CREATE OR REPLACE FUNCTION manage_registration_reseeding()
    RETURNS TRIGGER AS $function$
DECLARE
    v_round_heat_id INTEGER;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS heats_to_reseed (round_heat_id INT PRIMARY KEY) ON COMMIT DROP;
    TRUNCATE heats_to_reseed;

    IF (TG_OP = 'INSERT') THEN
        INSERT INTO heats_to_reseed
        SELECT DISTINCT hr.round_heat_id
        FROM new_rows nr
        JOIN ss_heat_results hr ON nr.athlete_id = hr.athlete_id 
            AND nr.event_id = hr.event_id 
            AND nr.division_id = hr.division_id;
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        INSERT INTO heats_to_reseed
        SELECT DISTINCT hr.round_heat_id
        FROM old_rows o
        JOIN ss_heat_results hr ON o.athlete_id = hr.athlete_id
            AND o.event_id = hr.event_id 
            AND o.division_id = hr.division_id
        ON CONFLICT (round_heat_id) DO NOTHING;

        INSERT INTO heats_to_reseed
        SELECT DISTINCT hr.round_heat_id
        FROM new_rows n
        JOIN ss_heat_results hr ON n.athlete_id = hr.athlete_id
            AND n.event_id = hr.event_id 
            AND n.division_id = hr.division_id
        ON CONFLICT (round_heat_id) DO NOTHING;
    END IF;

    IF (TG_OP = 'DELETE') THEN
        INSERT INTO heats_to_reseed
        SELECT DISTINCT hr.round_heat_id
        FROM old_rows o
        JOIN ss_heat_results hr ON o.athlete_id = hr.athlete_id
            AND o.event_id = hr.event_id 
            AND o.division_id = hr.division_id
        ON CONFLICT (round_heat_id) DO NOTHING;
    END IF;

    FOR v_round_heat_id IN SELECT round_heat_id FROM heats_to_reseed
    LOOP
        CALL reseed_heat(v_round_heat_id);
    END LOOP;

    RETURN NULL;
END;
$function$ LANGUAGE plpgsql;


-- 18.
CREATE OR REPLACE FUNCTION ss_handle_new_event_judge()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- This function is triggered AFTER a new judge is inserted into ss_event_judges.
    -- The special variable 'NEW' holds the data of the newly inserted row.

    RAISE NOTICE 'Trigger (INSERT): Creating assignments for new judge (personnel_id: %) on event (event_id: %)', NEW.personnel_id, NEW.event_id;

    -- 1. Assign the new judge to all heats associated with the event.
    --    This replaces the second INSERT in your original procedure.
    INSERT INTO ss_heat_judges (round_heat_id, personnel_id)
    SELECT hd.round_heat_id, NEW.personnel_id
    FROM ss_heat_details AS hd
    JOIN ss_round_details AS rd ON hd.round_id = rd.round_id
    WHERE rd.event_id = NEW.event_id
    ON CONFLICT (round_heat_id, personnel_id) DO NOTHING;

    RAISE NOTICE 'Trigger (INSERT): Assigned judge % to all heats for event %.', NEW.personnel_id, NEW.event_id;

    -- 2. Create placeholder score entries for all runs associated with the event.
    --    This replaces the third INSERT in your original procedure.
    INSERT INTO ss_run_scores (personnel_id, run_result_id, round_heat_id)
    SELECT NEW.personnel_id, r.run_result_id, r.round_heat_id
    FROM ss_run_results AS r
    WHERE r.event_id = NEW.event_id
    ON CONFLICT (personnel_id, run_result_id) DO NOTHING;

    RAISE NOTICE 'Trigger (INSERT): Created placeholder run scores for judge % across event %.', NEW.personnel_id, NEW.event_id;

    -- For an AFTER trigger, the return value is ignored, but returning NEW is good practice.
    RETURN NEW;
END;
$$;


-- 19.
CREATE OR REPLACE FUNCTION ss_handle_deleted_event_judge()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- This function is triggered BEFORE a judge is deleted from ss_event_judges.
    -- The special variable 'OLD' holds the data of the row about to be deleted.
    -- We use a BEFORE trigger to ensure the related data is removed before the parent row is gone.

    RAISE NOTICE 'Trigger (DELETE): Removing assignments for judge (personnel_id: %) from event (event_id: %)', OLD.personnel_id, OLD.event_id;

    -- 1. Delete the placeholder run scores for this judge in this event.
    DELETE FROM ss_run_scores
    WHERE personnel_id = OLD.personnel_id
      AND run_result_id IN (
          SELECT run_result_id FROM ss_run_results WHERE event_id = OLD.event_id
      );

    RAISE NOTICE 'Trigger (DELETE): Removed run scores for judge % from event %.', OLD.personnel_id, OLD.event_id;

    -- 2. Delete the heat assignments for this judge in this event.
    DELETE FROM ss_heat_judges
    WHERE personnel_id = OLD.personnel_id
      AND round_heat_id IN (
          SELECT hd.round_heat_id
          FROM ss_heat_details AS hd
          JOIN ss_round_details AS rd ON hd.round_id = rd.round_id
          WHERE rd.event_id = OLD.event_id
      );
      
    RAISE NOTICE 'Trigger (DELETE): Removed heat assignments for judge % from event %.', OLD.personnel_id, OLD.event_id;

    -- For a BEFORE trigger, we must return the row that will proceed with the operation (in this case, deletion).
    RETURN OLD;
END;
$$;


-- 20.
CREATE OR REPLACE FUNCTION ss_handle_updated_event_judge()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- This function is triggered AFTER a judge's record is updated.
    -- We have access to both 'OLD' (the data before update) and 'NEW' (the data after update).

    -- Only act if the event_id has actually changed.
    -- If only the name or header was updated, we don't need to do anything.
    IF NEW.event_id IS DISTINCT FROM OLD.event_id THEN

        RAISE NOTICE 'Trigger (UPDATE): Moving judge % from event % to event %.', NEW.personnel_id, OLD.event_id, NEW.event_id;

        -- STEP 1: Perform the DELETE logic for the OLD event.
        -- ======================================================

        -- Delete placeholder run scores from the old event.
        DELETE FROM ss_run_scores
        WHERE personnel_id = OLD.personnel_id
          AND run_result_id IN (
              SELECT run_result_id FROM ss_run_results WHERE event_id = OLD.event_id
          );

        -- Delete heat assignments from the old event.
        DELETE FROM ss_heat_judges
        WHERE personnel_id = OLD.personnel_id
          AND round_heat_id IN (
              SELECT hd.round_heat_id
              FROM ss_heat_details AS hd
              JOIN ss_round_details AS rd ON hd.round_id = rd.round_id
              WHERE rd.event_id = OLD.event_id
          );

        -- STEP 2: Perform the INSERT logic for the NEW event.
        -- =====================================================

        -- Assign the judge to all heats in the new event.
        INSERT INTO ss_heat_judges (round_heat_id, personnel_id)
        SELECT hd.round_heat_id, NEW.personnel_id
        FROM ss_heat_details AS hd
        JOIN ss_round_details AS rd ON hd.round_id = rd.round_id
        WHERE rd.event_id = NEW.event_id
        ON CONFLICT (round_heat_id, personnel_id) DO NOTHING;

        -- Create placeholder scores for all runs in the new event.
        INSERT INTO ss_run_scores (personnel_id, run_result_id, round_heat_id)
        SELECT NEW.personnel_id, r.run_result_id, r.round_heat_id
        FROM ss_run_results AS r
        WHERE r.event_id = NEW.event_id
        ON CONFLICT (personnel_id, run_result_id) DO NOTHING;
        
        RAISE NOTICE 'Trigger (UPDATE): Move complete for judge %.', NEW.personnel_id;

    END IF;

    RETURN NEW;
END;
$$;


-- 21.
CREATE OR REPLACE FUNCTION add_event_judge(
    p_event_id INT,
    p_header VARCHAR,
    p_name VARCHAR DEFAULT NULL
)
RETURNS INT 
LANGUAGE plpgsql
AS $$
DECLARE
    v_personnel_id INT;
BEGIN
    INSERT INTO ss_event_judges (event_id, header, name)
    VALUES (p_event_id, p_header, p_name)
    RETURNING personnel_id INTO v_personnel_id;

    RAISE NOTICE 'Created event judge with personnel_id: % for event_id: %', v_personnel_id, p_event_id;

    INSERT INTO ss_heat_judges (round_heat_id, personnel_id)
    SELECT hd.round_heat_id, v_personnel_id
    FROM ss_heat_details AS hd
    JOIN ss_round_details AS rd ON hd.round_id = rd.round_id
    WHERE rd.event_id = p_event_id
    ON CONFLICT (round_heat_id, personnel_id) DO NOTHING;

    RAISE NOTICE 'Assigned judge % to all heats for event %.', v_personnel_id, p_event_id;

    INSERT INTO ss_run_scores (personnel_id, run_result_id, round_heat_id)
    SELECT v_personnel_id, r.run_result_id, r.round_heat_id
    FROM ss_run_results AS r
    WHERE r.event_id = p_event_id
    ON CONFLICT (personnel_id, run_result_id) DO NOTHING;

    RAISE NOTICE 'Created placeholder run scores for judge % across event %.', v_personnel_id, p_event_id;

    RETURN v_personnel_id;

END;
$$;


-- 22.
CREATE OR REPLACE FUNCTION trg_recalculate_on_dn_flag_change()
    RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.dn_flag IS DISTINCT FROM OLD.dn_flag THEN
        RAISE NOTICE 'dn_flag changed for run_result_id: %. Recalculating scores.', NEW.run_result_id;
        
        CALL calculate_average_score(NEW.run_result_id);
    END IF;

    RETURN NULL; 
END;
$$;