DROP FUNCTION IF EXISTS handle_insert_on_heat_details() CASCADE;

CREATE OR REPLACE FUNCTION public.handle_insert_on_heat_details()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- This function runs when a new row is inserted into ss_heat_details.
    -- Its job is to populate the corresponding ss_heat_results table with all
    -- athletes from the round who are not already assigned to another heat in that round.

    INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
    SELECT
        NEW.round_heat_id,      -- The ID of the heat that was just created.
        candidate.event_id,
        candidate.division_id,
        candidate.athlete_id,
        0                       -- Default seeding value.
    FROM
        -- Step 1: Get a list of all "candidate" athletes who are registered
        -- for the event and division associated with this round.
        (
            SELECT
                reg.athlete_id,
                rd.event_id,
                rd.division_id
            FROM ss_event_registrations AS reg
            JOIN ss_round_details AS rd ON reg.event_id = rd.event_id AND reg.division_id = rd.division_id
            WHERE rd.round_id = NEW.round_id
        ) AS candidate

    -- Step 2: Use a LEFT JOIN to find which of the candidates are ALREADY
    -- in a heat for this same round.
    LEFT JOIN
        (
            SELECT DISTINCT hr.athlete_id -- Get the unique list of athletes
            FROM ss_heat_results AS hr
            JOIN ss_heat_details AS hd ON hr.round_heat_id = hd.round_heat_id
            WHERE hd.round_id = NEW.round_id
        ) AS existing_athlete ON candidate.athlete_id = existing_athlete.athlete_id

    -- Step 3: The key to the exclusion logic. We only keep the rows where
    -- the LEFT JOIN did NOT find a match (i.e., the athlete is NOT already in a heat).
    WHERE
        existing_athlete.athlete_id IS NULL;


    -- Check if any rows were inserted. The special variable FOUND is set by INSERT/UPDATE/DELETE.
    IF NOT FOUND THEN
        RAISE NOTICE 'Heat created (round_heat_id=%), but no available athletes were found to add (all may be assigned already).', NEW.round_heat_id;
    END IF;

    -- This part remains the same.
    CALL reseed_heat(NEW.round_heat_id);

    RETURN NEW;
END;
$function$;

-- CREATE OR REPLACE FUNCTION public.handle_insert_on_heat_details()
--  RETURNS trigger
--  LANGUAGE plpgsql
-- AS $function$
-- BEGIN
--     INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
--     SELECT
--         NEW.round_heat_id,
--         rd.event_id,
--         rd.division_id,
--         reg.athlete_id,
--         0
--     FROM
--         ss_event_registrations AS reg
--     INNER JOIN ss_round_details AS rd ON reg.event_id = rd.event_id AND reg.division_id = rd.division_id
--     WHERE
--         rd.round_id = NEW.round_id
--         AND NOT EXISTS (
--             SELECT 1
--             FROM ss_heat_results AS existing_hr
--             INNER JOIN ss_heat_details AS existing_hd ON existing_hr.round_heat_id = existing_hd.round_heat_id
--             WHERE
--                 existing_hd.round_id = NEW.round_id 
--                 AND existing_hr.athlete_id = reg.athlete_id 
--         )
--     ON CONFLICT (round_heat_id, athlete_id) DO NOTHING;

--     IF NOT FOUND THEN
--         RAISE NOTICE 'Heat created (round_heat_id=%), but no available athletes were found to add.', NEW.round_heat_id;
--     END IF;

--     CALL reseed_heat(NEW.round_heat_id);

--     RETURN NEW;
-- END;
-- $function$;


-- DB:
-- CREATE OR REPLACE FUNCTION handle_insert_on_heat_details()
--   RETURNS TRIGGER AS $trigger$
-- DECLARE
--     v_event_id INTEGER;
--     v_division_id INTEGER;
-- BEGIN
--     SELECT rd.event_id, rd.division_id
--     INTO v_event_id, v_division_id
--     FROM ss_round_details AS rd
--     WHERE rd.round_id = NEW.round_id;

--     INSERT INTO ss_heat_results (heat_id, registration_id)
--     SELECT
--         NEW.heat_id,         
--         reg.registration_id  
--     FROM ss_event_registrations AS reg
--     WHERE reg.event_id = v_event_id AND reg.division_id = v_division_id
--     ON CONFLICT (heat_id, registration_id) DO NOTHING;

--     IF NOT FOUND THEN
--         RAISE NOTICE 'Heat created (heat_id=%), but no registered athletes were found to add to it.', NEW.heat_id;
--     END IF;

--     CALL reseed_heat(NEW.heat_id);

--     RETURN NULL;
-- END;
-- $trigger$ LANGUAGE plpgsql;




-- CREATE OR REPLACE FUNCTION handle_insert_on_heat_details()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
--     SELECT
--         NEW.round_heat_id,
--         rd.event_id,
--         rd.division_id,
--         reg.athlete_id,
--         0
--     FROM
--         ss_event_registrations AS reg
--     INNER JOIN ss_round_details AS rd ON reg.event_id = rd.event_id AND reg.division_id = rd.division_id
--     WHERE
--         rd.round_id = NEW.round_id
--         AND NOT EXISTS (
--             SELECT 1
--             FROM ss_heat_results AS existing_hr
--             INNER JOIN ss_heat_details AS existing_hd ON existing_hr.round_heat_id = existing_hd.round_heat_id
--             WHERE
--                 existing_hd.round_id = NEW.round_id 
--                 AND existing_hr.athlete_id = reg.athlete_id 
--         );
--     ON CONFLICT (round_heat_id, athlete_id) DO NOTHING;

--     IF NOT FOUND THEN
--         RAISE NOTICE 'Heat created (round_heat_id=%), but no available athletes were found to add.', NEW.round_heat_id;
--     END IF;

--     CALL reseed_heat(NEW.round_heat_id);

--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;


CREATE TRIGGER trg_populate_new_heat
AFTER INSERT ON ss_heat_details
FOR EACH ROW
EXECUTE FUNCTION handle_insert_on_heat_details();