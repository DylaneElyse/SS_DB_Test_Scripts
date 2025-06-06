CREATE OR REPLACE FUNCTION handle_update_on_heat_details()
RETURNS TRIGGER AS $$
DECLARE
    -- Variables to hold the new parent context
    v_new_event_id ss_heat_results.event_id%TYPE;
    v_new_division_id ss_heat_results.division_id%TYPE;
BEGIN
    -- Only run logic if a key identifier (round_heat_id or round_id) has changed.
    -- This avoids doing work for irrelevant updates (like changing heat_num).
    -- "IS DISTINCT FROM" correctly handles NULLs.
    IF NEW.round_heat_id IS DISTINCT FROM OLD.round_heat_id OR NEW.round_id IS DISTINCT FROM OLD.round_id THEN

        -- Look up the new event and division context from the NEW round_id.
        -- This assumes you have a table (like ss_round_details) that maps round_id to event/division.
        -- We will use the name `ss_round_details` based on your previous functions.
        SELECT rd.event_id, rd.division_id
        INTO v_new_event_id, v_new_division_id
        FROM ss_round_details rd
        WHERE rd.round_id = NEW.round_id;

        -- Defensive programming: if the new parent round doesn't exist, something is wrong.
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Data integrity error: Parent round_id % not found in ss_round_details.', NEW.round_id;
        END IF;

        -- Now, perform a single UPDATE on ss_heat_results.
        -- This statement is powerful: it finds all results belonging to the OLD heat
        -- and updates them with the NEW heat ID and the NEW event/division context.
        UPDATE ss_heat_results
        SET
            round_heat_id = NEW.round_heat_id,  -- Update to the new heat ID
            event_id = v_new_event_id,          -- Update to the new event context
            division_id = v_new_division_id     -- Update to the new division context
        WHERE
            -- Find all the rows that belonged to the heat before the update.
            round_heat_id = OLD.round_heat_id;

    END IF;

    -- For an AFTER UPDATE trigger, always return the NEW row.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Create the trigger
CREATE TRIGGER trg_sync_on_heat_details_update
AFTER UPDATE ON ss_heat_details
FOR EACH ROW
EXECUTE FUNCTION handle_update_on_heat_details();