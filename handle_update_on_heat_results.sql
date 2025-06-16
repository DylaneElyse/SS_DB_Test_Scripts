CREATE OR REPLACE FUNCTION handle_update_on_heat_results()
RETURNS TRIGGER AS $$
BEGIN
    -- This trigger should only act if one of the key columns that is
    -- duplicated in ss_run_results has actually changed. This prevents
    -- unnecessary updates if, for example, only a score field was changed.

    -- The "IS DISTINCT FROM" operator correctly handles NULL values.
    IF (NEW.event_id IS DISTINCT FROM OLD.event_id OR
        NEW.division_id IS DISTINCT FROM OLD.division_id OR
        NEW.athlete_id IS DISTINCT FROM OLD.athlete_id)
    THEN
        -- Update all associated run results.
        -- We find the rows to update using the OLD values.
        -- We set the new values using the NEW values.
        UPDATE ss_run_results
        SET
            event_id = NEW.event_id,
            division_id = NEW.division_id,
            athlete_id = NEW.athlete_id
        WHERE
            round_heat_id = OLD.round_heat_id AND
            event_id = OLD.event_id AND
            division_id = OLD.division_id AND
            athlete_id = OLD.athlete_id;
    END IF;

    -- The return value of an AFTER trigger is ignored, so we return NULL.
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- First, ensure any existing trigger with the same name is removed.
DROP TRIGGER IF EXISTS trg_cascade_update_on_heat_results ON ss_heat_results;

-- Now, create the trigger to fire the function AFTER a row is updated.
CREATE TRIGGER trg_cascade_update_on_heat_results
AFTER UPDATE ON ss_heat_results
FOR EACH ROW
EXECUTE FUNCTION handle_update_on_heat_results();