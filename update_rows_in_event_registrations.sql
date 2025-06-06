CREATE OR REPLACE FUNCTION handle_update_on_event_registrations()
RETURNS TRIGGER AS $$
BEGIN
    -- This is the crucial check: Only run the logic if the event or division has changed.
    -- Using "IS DISTINCT FROM" is important as it correctly handles NULL values.
    IF NEW.event_id IS DISTINCT FROM OLD.event_id OR NEW.division_id IS DISTINCT FROM OLD.division_id THEN

        -- Part 1: REMOVE the athlete from all heats related to their OLD registration.
        -- We use the "DELETE ... USING" syntax for a clean join.
        DELETE FROM ss_heat_results shr
        USING ss_round_details rd
        WHERE
            rd.event_id = OLD.event_id
            AND rd.division_id = OLD.division_id
            AND shr.round_heat_id = rd.round_heat_id
            AND shr.athlete_id = OLD.athlete_id; -- Or NEW.athlete_id, it should be the same

        -- Part 2: ADD the athlete to all heats related to their NEW registration.
        -- This is the same logic from your INSERT trigger, just using NEW.
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

    END IF;

    -- Always return NEW for an AFTER UPDATE row-level trigger.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION reseed_after_update()
RETURNS TRIGGER AS $$
DECLARE
    v_round_heat_id INTEGER;
BEGIN
    -- We need to find all unique heats from BOTH the old and new registrations.
    -- A UNION automatically finds the distinct set.
    FOR v_round_heat_id IN
        -- Heats from the OLD registrations
        SELECT DISTINCT rd.round_heat_id
        FROM ss_round_details rd
        JOIN old_rows o ON rd.event_id = o.event_id AND rd.division_id = o.division_id
        UNION
        -- Heats from the NEW registrations
        SELECT DISTINCT rd.round_heat_id
        FROM ss_round_details rd
        JOIN new_rows n ON rd.event_id = n.event_id AND rd.division_id = n.division_id
    LOOP
        -- Call the reseed procedure for each affected heat, but only once.
        CALL reseed_heat(v_round_heat_id);
    END LOOP;

    RETURN NULL; -- Statement-level AFTER triggers don't need a return value.
END;
$$ LANGUAGE plpgsql;


-- TRIGGER 1: The row-level trigger for UPDATE
CREATE TRIGGER trg_handle_update_on_event_registrations
AFTER UPDATE ON ss_event_registrations
FOR EACH ROW
EXECUTE FUNCTION handle_update_on_event_registrations();

-- TRIGGER 2: The statement-level trigger for UPDATE
CREATE TRIGGER trg_reseed_after_update
AFTER UPDATE ON ss_event_registrations
REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows
FOR EACH STATEMENT
EXECUTE FUNCTION reseed_after_update();