-- This function correctly adds a new athlete to all relevant heats.
-- It does NOT call reseed_heat.
CREATE OR REPLACE FUNCTION handle_new_rows_in_event_registrations()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
    SELECT
        rd.round_heat_id,
        NEW.event_id,
        NEW.division_id,
        NEW.athlete_id,
        0 -- Initial seeding is 0
    FROM
        ss_round_details rd
    WHERE
        rd.event_id = NEW.event_id
        AND rd.division_id = NEW.division_id
    ON CONFLICT (round_heat_id, event_id, division_id, athlete_id) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reseed_affected_heats()
RETURNS TRIGGER AS $$
DECLARE
    -- A variable to hold the round_heat_id during the loop
    v_round_heat_id INTEGER;
BEGIN
    -- This is the key: we query the "new_rows" transition table
    -- to find all the unique heats that were affected by the entire statement.
    FOR v_round_heat_id IN
        SELECT DISTINCT rd.round_heat_id
        FROM ss_round_details rd
        -- The "new_rows" table contains all rows inserted by the statement.
        JOIN new_rows nr ON rd.event_id = nr.event_id AND rd.division_id = nr.division_id
    LOOP
        -- Call the reseed procedure for each affected heat, but only once!
        CALL reseed_heat(v_round_heat_id);
    END LOOP;

    RETURN NULL; -- Statement-level AFTER triggers don't need to return a value.
END;
$$ LANGUAGE plpgsql;



-- TRIGGER 1: The row-level trigger (fires first for each row)
CREATE TRIGGER trg_handle_new_rows_in_event_registrations
AFTER INSERT ON ss_event_registrations
FOR EACH ROW
EXECUTE FUNCTION handle_new_rows_in_event_registrations();


-- TRIGGER 2: The statement-level trigger (fires once at the very end)
CREATE TRIGGER trg_reseed_affected_heats
AFTER INSERT ON ss_event_registrations
-- This clause defines the "new_rows" table we used in the function
REFERENCING NEW TABLE AS new_rows
FOR EACH STATEMENT
EXECUTE FUNCTION reseed_affected_heats();



-- CREATE OR REPLACE FUNCTION handle_new_row_on_event_registrations()
-- RETURNS TRIGGER AS $$
-- DECLARE
--   v_round_id ss_heat_details.round_id%TYPE;
--   v_event_id ss_event_registrations.event_id%TYPE;
--   v_division_id ss_event_registrations.division_id%TYPE;
--   v_athlete_id ss_event_registrations.athlete_id%TYPE;
--   v_round_heat_id ss_heat_details.round_heat_id%TYPE;
--   v_round_id ss_heat_details.round_id%TYPE;

--   CURSOR c_event_registrations IS
--     SELECT DISTINCT event_id, division_id, athlete_id
--     FROM ss_event_registrations
--     ORDER BY event_id, division_id, athlete_id;

--   CURSOR c_round_details IS
--     SELECT round_id, round_heat_id
--     FROM ss_round_details
--     ORDER BY round_id, round_heat_id;

-- BEGIN
--   FOR rec_event_registrations IN c_event_registrations LOOP
--     v_event_id := rec_event_registrations.event_id;
--     v_division_id := rec_event_registrations.division_id;
--     v_athlete_id := rec_event_registrations.athlete_id;

--     FOR rec_round_details IN c_round_details LOOP

--       -- Check if the event_id and division_id match the current event registration
--       IF rec_round_details.event_id = v_event_id AND rec_round_details.division_id = v_division_id THEN
--         v_round_heat_id := rec_round_details.round_heat_id;
--         v_round_id := rec_round_details.round_id;

--         INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
--         VALUES (v_round_heat_id, v_event_id, v_division_id, v_athlete_id, 0)
--         ON CONFLICT (round_heat_id, event_id, division_id, athlete_id) DO NOTHING; -- Prevent duplicates
--       END IF;

--     END LOOP;
--   END LOOP;

--   CALL reseed_heat(v_round_heat_id);

--   RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;


-- CREATE TRIGGER trg_after_insert_on_round_details
-- AFTER INSERT ON ss_round_details
-- FOR EACH ROW
-- EXECUTE FUNCTION handle_new_row_on_round_details();