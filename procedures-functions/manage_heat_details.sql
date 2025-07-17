CREATE OR REPLACE FUNCTION manage_heat_details()
    RETURNS TRIGGER AS $$
BEGIN
    -- Execute if a new round is inserted OR if the number of heats changes on an existing round.
    IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE' AND NEW.num_heats IS DISTINCT FROM OLD.num_heats) THEN

        -- If updating, clear out the old heats first.
        IF TG_OP = 'UPDATE' THEN
            DELETE FROM ss_heat_details WHERE round_id = OLD.round_id;
        END IF;

        -- Create all new heats at once using a set-based insert.
        IF NEW.num_heats > 0 THEN
            INSERT INTO ss_heat_details (round_id, heat_num, num_runs)
            SELECT
                NEW.round_id,
                i,
                DEFAULT -- Use the default value for num_runs
            FROM generate_series(1, NEW.num_heats) AS i;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS trg_handle_insert_on_round_details ON ss_round_details;
DROP TRIGGER IF EXISTS trg_handle_update_on_round_details ON ss_round_details;

CREATE TRIGGER trg_manage_heat_details
    AFTER INSERT OR UPDATE ON ss_round_details
    FOR EACH ROW
    EXECUTE FUNCTION manage_heat_details();