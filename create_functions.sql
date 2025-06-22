-- 1.
CREATE OR REPLACE FUNCTION handle_insert_on_event_division()
  RETURNS trigger AS $function$
DECLARE
  v_event_id ss_round_details.event_id%TYPE;
  v_division_id ss_round_details.division_id%TYPE;
  v_num_rounds ss_event_divisions.num_rounds%TYPE;
  v_count INT; 
  v_round_name TEXT; 

  v_round_list_2 TEXT[] := ARRAY['Qualifications', 'Finals']; 
  v_round_list_3 TEXT[] := ARRAY['Qualifications', 'Semi-Finals', 'Finals'];
  v_round_list_4 TEXT[] := ARRAY['Qualifications', 'Quarter-Finals', 'Semi-Finals', 'Finals'];

BEGIN
  v_event_id := NEW.event_id;
  v_division_id := NEW.division_id;
  v_num_rounds := NEW.num_rounds;

  IF (v_num_rounds = 1) THEN
    INSERT INTO ss_round_details (event_id, division_id, round_name, num_heats) 
      VALUES (v_event_id, v_division_id, 'Finals', DEFAULT); 

  ELSEIF (v_num_rounds = 2) THEN
    v_count := 1;
    WHILE (v_count <= v_num_rounds) LOOP
      v_round_name := v_round_list_2[v_count];
      INSERT INTO ss_round_details (event_id, division_id, round_name, num_heats) 
        VALUES (v_event_id, v_division_id, v_round_name, DEFAULT);
      v_count := v_count + 1;
    END LOOP;

  ELSEIF (v_num_rounds = 3) THEN
    v_count := 1;
    WHILE (v_count <= v_num_rounds) LOOP
      v_round_name := v_round_list_3[v_count];
      INSERT INTO ss_round_details (event_id, division_id, round_name, num_heats) 
        VALUES (v_event_id, v_division_id, v_round_name, DEFAULT);
      v_count := v_count + 1;
    END LOOP; 

  ELSEIF (v_num_rounds = 4) THEN
    v_count := 1;
    WHILE (v_count <= v_num_rounds) LOOP
      v_round_name := v_round_list_4[v_count];
      INSERT INTO ss_round_details (event_id, division_id, round_name, num_heats) 
        VALUES (v_event_id, v_division_id, v_round_name, DEFAULT);
      v_count := v_count + 1;
    END LOOP; 
  END IF;

  RETURN NEW;
END;
$function$ LANGUAGE plpgsql;


-- 2.
CREATE OR REPLACE FUNCTION handle_update_on_event_division()
  RETURNS trigger AS $function$
BEGIN
    IF NEW.num_rounds IS DISTINCT FROM OLD.num_rounds THEN
      DELETE FROM ss_round_details
      WHERE event_id = NEW.event_id AND division_id = NEW.division_id;

      DECLARE
        v_event_id ss_round_details.event_id%TYPE;
        v_division_id ss_round_details.division_id%TYPE;
        v_num_rounds ss_event_divisions.num_rounds%TYPE;
        v_count INT; 
        v_round_name TEXT; 

        v_round_list_2 TEXT[] := ARRAY['Qualifications', 'Finals']; 
        v_round_list_3 TEXT[] := ARRAY['Qualifications', 'Semi-Finals', 'Finals'];
        v_round_list_4 TEXT[] := ARRAY['Qualifications', 'Quarter-Finals', 'Semi-Finals', 'Finals'];

      BEGIN
        v_event_id := NEW.event_id;
        v_division_id := NEW.division_id;
        v_num_rounds := NEW.num_rounds;

        IF (v_num_rounds = 1) THEN
          INSERT INTO ss_round_details (event_id, division_id, round_name, num_heats) 
            VALUES (v_event_id, v_division_id, 'Finals', DEFAULT); 

        ELSEIF (v_num_rounds = 2) THEN
          v_count := 1;
          WHILE (v_count <= v_num_rounds) LOOP
            v_round_name := v_round_list_2[v_count];
            INSERT INTO ss_round_details (event_id, division_id, round_name, num_heats) 
              VALUES (v_event_id, v_division_id, v_round_name, DEFAULT);
            v_count := v_count + 1;
          END LOOP; 

        ELSEIF (v_num_rounds = 3) THEN
          v_count := 1;
          WHILE (v_count <= v_num_rounds) LOOP
            v_round_name := v_round_list_3[v_count];
            INSERT INTO ss_round_details (event_id, division_id, round_name, num_heats) 
              VALUES (v_event_id, v_division_id, v_round_name, DEFAULT);
            v_count := v_count + 1;
          END LOOP; 

        ELSEIF (v_num_rounds = 4) THEN
          v_count := 1;
          WHILE (v_count <= v_num_rounds) LOOP
            v_round_name := v_round_list_4[v_count];
            INSERT INTO ss_round_details (event_id, division_id, round_name, num_heats) 
              VALUES (v_event_id, v_division_id, v_round_name, DEFAULT);
            v_count := v_count + 1;
          END LOOP; 
        END IF;
      END;
    END IF;
    RETURN NEW;
END;
$function$ LANGUAGE plpgsql;


-- 3.
CREATE OR REPLACE FUNCTION handle_insert_on_round_details()
  RETURNS TRIGGER AS $trigger$
BEGIN
    IF NEW.num_heats > 0 THEN
        INSERT INTO ss_heat_details (round_id, heat_num)
        SELECT
            NEW.round_id, 
            i     
        FROM generate_series(1, NEW.num_heats) AS i;
    END IF;

    RETURN NULL;
END;
$trigger$ LANGUAGE plpgsql;


-- 4.
CREATE OR REPLACE FUNCTION handle_update_on_round_details()
  RETURNS TRIGGER AS $trigger$
BEGIN
    IF NEW.num_heats IS DISTINCT FROM OLD.num_heats THEN
        DELETE FROM ss_heat_details
        WHERE round_id = OLD.round_id; 

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
$trigger$ LANGUAGE plpgsql;


-- 5.
CREATE OR REPLACE FUNCTION handle_insert_on_heat_details()
  RETURNS TRIGGER AS $function$
BEGIN
    INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
    SELECT
        NEW.round_heat_id,
        rd.event_id,
        rd.division_id,
        reg.athlete_id,
        0
    FROM
        ss_event_registrations AS reg
    INNER JOIN ss_round_details AS rd ON reg.event_id = rd.event_id AND reg.division_id = rd.division_id
    WHERE
        rd.round_id = NEW.round_id
        AND NOT EXISTS (
            SELECT 1
            FROM ss_heat_results AS existing_hr
            INNER JOIN ss_heat_details AS existing_hd ON existing_hr.round_heat_id = existing_hd.round_heat_id
            WHERE
                existing_hd.round_id = NEW.round_id 
                AND existing_hr.athlete_id = reg.athlete_id 
        )
    ON CONFLICT (round_heat_id, athlete_id) DO NOTHING;

    IF NOT FOUND THEN
        RAISE NOTICE 'Heat created (round_heat_id=%), but no available athletes were found to add.', NEW.round_heat_id;
    END IF;

    CALL reseed_heat(NEW.round_heat_id);

    RETURN NEW;
END;
$function$ LANGUAGE plpgsql;


-- 6.
CREATE OR REPLACE FUNCTION handle_update_on_heat_details()
  RETURNS TRIGGER AS $trigger$
DECLARE
    v_old_event_id    INTEGER;
    v_old_division_id INTEGER;
    v_new_event_id    INTEGER;
    v_new_division_id INTEGER;
BEGIN
    IF NEW.round_id IS DISTINCT FROM OLD.round_id THEN
        SELECT rd.event_id, rd.division_id
        INTO v_old_event_id, v_old_division_id
        FROM ss_round_details AS rd
        WHERE rd.round_id = OLD.round_id;

        SELECT rd.event_id, rd.division_id
        INTO v_new_event_id, v_new_division_id
        FROM ss_round_details AS rd
        WHERE rd.round_id = NEW.round_id;

        IF v_new_event_id IS DISTINCT FROM v_old_event_id OR v_new_division_id IS DISTINCT FROM v_old_division_id THEN
            RAISE EXCEPTION 'Invalid Operation: Cannot move heat to a different event or division.'
                USING HINT = 'To move athletes, please update their entries in the ss_event_registrations table first.';
        END IF;
    END IF;

    IF NEW.heat_id IS DISTINCT FROM OLD.heat_id OR NEW.round_id IS DISTINCT FROM OLD.round_id THEN
        CALL reseed_heat(NEW.heat_id);
    END IF;

    RETURN NEW;
END;
$trigger$ LANGUAGE plpgsql;


-- 7.
CREATE OR REPLACE FUNCTION handle_insert_on_event_registrations()
  RETURNS TRIGGER AS $function$
BEGIN
    INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
    SELECT
        hd.round_heat_id, 
        NEW.event_id,
        NEW.division_id,
        NEW.athlete_id,
        0
    FROM
        ss_round_details rd
        INNER JOIN ss_heat_details hd ON rd.round_id = hd.round_id
    WHERE
        rd.event_id = NEW.event_id
        AND rd.division_id = NEW.division_id
    ON CONFLICT (round_heat_id, athlete_id) DO NOTHING;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Registration failed: No heats are defined for event_id=%, division_id=%.', NEW.event_id, NEW.division_id
        USING HINT = 'Please ensure that at least one round and one heat have been created for this event and division before registering athletes.';
    END IF;

    RETURN NEW;
END;
$function$ LANGUAGE plpgsql;


-- 8.
CREATE OR REPLACE FUNCTION handle_update_on_event_registrations()
  RETURNS TRIGGER AS $function$
BEGIN
    IF NEW.event_id IS DISTINCT FROM OLD.event_id OR NEW.division_id IS DISTINCT FROM OLD.division_id THEN
        DELETE FROM ss_heat_results AS shr
        USING
            ss_heat_details AS hd
            INNER JOIN ss_round_details AS rd ON hd.round_id = rd.round_id
        WHERE rd.event_id = OLD.event_id
          AND rd.division_id = OLD.division_id
          AND shr.round_heat_id = hd.round_heat_id
          AND shr.athlete_id = OLD.athlete_id;

        INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
        SELECT
            hd.round_heat_id,
            NEW.event_id,
            NEW.division_id,
            NEW.athlete_id,
            0
        FROM ss_round_details AS rd
        INNER JOIN ss_heat_details AS hd
            ON rd.round_id = hd.round_id
        WHERE rd.event_id = NEW.event_id
          AND rd.division_id = NEW.division_id
        ON CONFLICT (round_heat_id, athlete_id) DO NOTHING;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Update failed: Cannot move registration. No heats are defined for the destination: event_id=%, division_id=%.', NEW.event_id, NEW.division_id
                USING HINT = 'Please create at least one round and one heat for the target event/division before updating the registration.';
        END IF;
    END IF;

    RETURN NEW;
END;
$function$ LANGUAGE plpgsql;


-- 9.
CREATE OR REPLACE FUNCTION reseed_affected_heats()
  RETURNS TRIGGER AS $function$
DECLARE
    v_round_heat_id INTEGER;
BEGIN
    FOR v_round_heat_id IN
        SELECT DISTINCT hd.round_heat_id
        FROM new_rows AS nr 
        INNER JOIN ss_round_details AS rd ON nr.event_id = rd.event_id AND nr.division_id = rd.division_id
        INNER JOIN ss_heat_details AS hd ON rd.round_id = hd.round_id
    LOOP
        CALL reseed_heat(v_round_heat_id);
    END LOOP;
    RETURN NULL; 
END;
$function$ LANGUAGE plpgsql;


-- 10.
CREATE OR REPLACE FUNCTION reseed_after_update()
  RETURNS TRIGGER AS $trigger$
DECLARE
    v_round_heat_id INTEGER;
BEGIN
    FOR v_round_heat_id IN
        SELECT DISTINCT hd.round_heat_id
        FROM old_rows AS o
        JOIN ss_round_details AS rd ON rd.event_id = o.event_id AND rd.division_id = o.division_id
        JOIN ss_heat_details AS hd ON hd.round_id = rd.round_id
        UNION
        SELECT DISTINCT hd.heat_id
        FROM new_rows AS n
        JOIN ss_round_details AS rd ON rd.event_id = n.event_id AND rd.division_id = n.division_id
        JOIN ss_heat_details AS hd ON hd.round_id = rd.round_id
    LOOP
        CALL reseed_heat(v_round_heat_id);
    END LOOP;

    RETURN NULL;
END;
$trigger$ LANGUAGE plpgsql;


-- 11.
CREATE OR REPLACE FUNCTION handle_insert_on_heat_results()
RETURNS TRIGGER AS $$
DECLARE
    v_num_runs ss_heat_details.num_runs%TYPE;
    i INT; 
BEGIN
    SELECT num_runs INTO v_num_runs
    FROM ss_heat_details
    WHERE round_heat_id = NEW.round_heat_id;

    IF v_num_runs IS NOT NULL AND v_num_runs > 0 THEN

        FOR i IN 1..v_num_runs LOOP

            INSERT INTO ss_run_results (round_heat_id, event_id, division_id, athlete_id, run_num)
            VALUES (NEW.round_heat_id, NEW.event_id, NEW.division_id, NEW.athlete_id, i)

            ON CONFLICT (round_heat_id, event_id, division_id, athlete_id, run_num) DO NOTHING;

        END LOOP;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- 12.
CREATE OR REPLACE FUNCTION handle_update_on_heat_results()
  RETURNS TRIGGER AS $function$
BEGIN
    IF NEW.event_id IS DISTINCT FROM OLD.event_id OR
       NEW.division_id IS DISTINCT FROM OLD.division_id OR
       NEW.athlete_id IS DISTINCT FROM OLD.athlete_id
    THEN
        UPDATE ss_run_results
        SET
            event_id = NEW.event_id,
            division_id = NEW.division_id,
            athlete_id = NEW.athlete_id
        WHERE
            heat_id = OLD.heat_id AND
            event_id = OLD.event_id AND
            division_id = OLD.division_id AND
            athlete_id = OLD.athlete_id;
    END IF;

    RETURN NULL;
END;
$function$ LANGUAGE plpgsql;


-- 13.
CREATE OR REPLACE FUNCTION handle_insert_on_event_judges()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO ss_run_scores (personnel_id, run_result_id)
    SELECT
        NEW.personnel_id,
        r.run_result_id
    FROM
        ss_run_results AS r
    WHERE
        r.event_id = NEW.event_id

    ON CONFLICT (personnel_id, run_result_id) DO NOTHING;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- 14.
CREATE OR REPLACE FUNCTION prevent_invalid_judge_update()
 RETURNS TRIGGER AS $function$
BEGIN
    IF NEW.personnel_id IS DISTINCT FROM OLD.personnel_id OR NEW.event_id IS DISTINCT FROM OLD.event_id THEN
        IF EXISTS (
            SELECT 1
            FROM ss_run_scores AS s
            JOIN ss_run_results AS r ON s.run_result_id = r.run_result_id
            WHERE s.personnel_id = OLD.personnel_id
              AND r.event_id = OLD.event_id
              AND s.score IS NOT NULL
        ) THEN
            RAISE EXCEPTION 'Update failed. Judge (ID: %) cannot be removed from event (ID: %) because they have already submitted scores.',
                OLD.personnel_id, OLD.event_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$function$ LANGUAGE plpgsql;


-- 15.
CREATE OR REPLACE FUNCTION manage_judge_deletion_with_cleanup()
  RETURNS TRIGGER AS $function$
DECLARE
    v_has_scored_rows         BOOLEAN := FALSE;
    v_deleted_null_scores_count INT;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM ss_run_scores AS s
        JOIN ss_run_results AS r ON s.run_result_id = r.run_result_id
        WHERE s.personnel_id = OLD.personnel_id
          AND r.event_id = OLD.event_id
          AND s.score IS NOT NULL
    ) INTO v_has_scored_rows;

    WITH deleted_rows AS (
        DELETE FROM ss_run_scores AS s
        USING ss_run_results AS r
        WHERE s.run_result_id = r.run_result_id
          AND s.personnel_id = OLD.personnel_id
          AND r.event_id = OLD.event_id
          AND s.score IS NULL
        RETURNING 1
    )
    SELECT count(*)
    INTO v_deleted_null_scores_count
    FROM deleted_rows;

    RAISE NOTICE 'Cleanup phase: Deleted % placeholder score row(s) for Judge (ID: %).',
        v_deleted_null_scores_count, OLD.personnel_id;

    IF v_has_scored_rows THEN
        RAISE EXCEPTION 'Cannot remove Judge (ID: %): They have submitted scores. % placeholder scores were cleaned up, but the judge was NOT removed from the event.',
            OLD.personnel_id, v_deleted_null_scores_count;
    ELSE
        RAISE NOTICE 'No submitted scores found for Judge (ID: %). Proceeding with deletion from event.', OLD.personnel_id;
        RETURN OLD;
    END IF;
END;
$function$ LANGUAGE plpgsql;


-- 16.
CREATE OR REPLACE FUNCTION set_judge_passcode_if_null()
  RETURNS TRIGGER AS $function$
BEGIN
    IF NEW.passcode IS NULL THEN
        NEW.passcode := generate_random_4_digit_code();
    END IF;

    RETURN NEW;
END;
$function$ LANGUAGE plpgsql;


-- 17.
CREATE OR REPLACE FUNCTION generate_random_4_digit_code()
  RETURNS TEXT AS $function$
DECLARE
    v_random_code TEXT;
    v_is_unique   BOOLEAN := FALSE;
BEGIN
    WHILE NOT v_is_unique LOOP
        v_random_code := lpad(floor(random() * 10000)::TEXT, 4, '0');

        SELECT NOT EXISTS (
            SELECT 1
            FROM ss_event_judges
            WHERE passcode = v_random_code
        ) INTO v_is_unique;
    END LOOP;

    RETURN v_random_code;
END;
$function$ LANGUAGE plpgsql VOLATILE;


-- 18.
CREATE OR REPLACE FUNCTION handle_insert_on_run_results()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO ss_run_scores (personnel_id, run_result_id)
    SELECT
        j.personnel_id,
        NEW.run_result_id
    FROM
        ss_event_judges AS j
    WHERE
        j.event_id = NEW.event_id

    ON CONFLICT (personnel_id, run_result_id) DO NOTHING;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- 19.
CREATE OR REPLACE FUNCTION handle_update_on_run_results()
  RETURNS TRIGGER AS $trigger$
DECLARE
    v_old_event_id INTEGER;
    v_new_event_id INTEGER;
BEGIN
    SELECT rd.event_id INTO v_new_event_id
    FROM ss_heat_details hd JOIN ss_round_details rd ON hd.round_id = rd.round_id
    WHERE hd.round_heat_id = NEW.round_heat_id;

    SELECT rd.event_id INTO v_old_event_id
    FROM ss_heat_details hd JOIN ss_round_details rd ON hd.round_id = rd.round_id
    WHERE hd.round_heat_id = OLD.round_heat_id;

    IF v_new_event_id IS DISTINCT FROM v_old_event_id THEN
        DELETE FROM ss_run_scores
        WHERE run_result_id = OLD.run_result_id;

        INSERT INTO ss_run_scores (personnel_id, run_result_id)
        SELECT
            j.personnel_id,
            NEW.run_result_id
        FROM ss_event_judges AS j
        WHERE j.event_id = v_new_event_id
        ON CONFLICT (personnel_id, run_result_id) DO NOTHING;
    END IF;

    RETURN NULL;
END;
$trigger$ LANGUAGE plpgsql;








