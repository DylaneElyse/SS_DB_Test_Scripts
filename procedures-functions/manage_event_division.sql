CREATE OR REPLACE FUNCTION manage_round_details()
    RETURNS TRIGGER AS $$
DECLARE
    v_round_list TEXT[];
BEGIN
    -- This block executes for a new division OR if the number of rounds on an existing one changes.
    IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE' AND NEW.num_rounds IS DISTINCT FROM OLD.num_rounds) THEN

        -- If it's an update, first clear out the old rounds.
        -- The ON DELETE CASCADE on your tables will handle cleaning up heats, results, etc.
        IF TG_OP = 'UPDATE' THEN
            DELETE FROM ss_round_details WHERE event_id = OLD.event_id AND division_id = OLD.division_id;
        END IF;

        -- Define the standard round names based on the count.
        v_round_list := CASE NEW.num_rounds
            WHEN 1 THEN ARRAY['Finals']
            WHEN 2 THEN ARRAY['Qualifications', 'Finals']
            WHEN 3 THEN ARRAY['Qualifications', 'Semi-Finals', 'Finals']
            WHEN 4 THEN ARRAY['Qualifications', 'Quarter-Finals', 'Semi-Finals', 'Finals']
            ELSE ARRAY[]::TEXT[]
        END;

        -- Use a set-based INSERT to create all rounds at once. This is much faster than a loop.
        IF array_length(v_round_list, 1) > 0 THEN
            INSERT INTO ss_round_details (event_id, division_id, round_num, round_name, num_heats)
            SELECT
                NEW.event_id,
                NEW.division_id,
                round_number,
                v_round_list[round_number],
                1 -- Default to 1 heat
            FROM generate_series(1, NEW.num_rounds) AS round_number;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Remove the old triggers
DROP TRIGGER IF EXISTS trg_handle_insert_on_event_division ON ss_event_divisions;
DROP TRIGGER IF EXISTS trg_handle_update_on_event_division ON ss_event_divisions;

-- Create the single, new trigger
CREATE TRIGGER trg_manage_round_details
    AFTER INSERT OR UPDATE ON ss_event_divisions
    FOR EACH ROW
    EXECUTE FUNCTION manage_round_details();