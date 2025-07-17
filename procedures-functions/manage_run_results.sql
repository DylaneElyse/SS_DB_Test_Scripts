CREATE OR REPLACE FUNCTION handle_run_results()
    RETURNS TRIGGER AS $$
DECLARE
    v_event_id INTEGER;
BEGIN
    -- Runs if a run_result is created or moved to a different event (via its round_heat_id).
    IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE' AND NEW.round_heat_id IS DISTINCT FROM OLD.round_heat_id) THEN

        -- On update, we assume it might be a move to a new event.
        -- Clean up old scores associated with the previous run_result_id.
        IF TG_OP = 'UPDATE' THEN
            DELETE FROM ss_run_scores WHERE run_result_id = OLD.run_result_id;
        END IF;

        -- Get the event_id for the new run.
        SELECT rd.event_id INTO v_event_id
        FROM ss_heat_details hd
        JOIN ss_round_details rd ON hd.round_id = rd.round_id
        WHERE hd.round_heat_id = NEW.round_heat_id;

        -- Create placeholder scores for all judges of that event.
        IF v_event_id IS NOT NULL THEN
            INSERT INTO ss_run_scores (personnel_id, run_result_id)
            SELECT j.personnel_id, NEW.run_result_id
            FROM ss_event_judges AS j
            WHERE j.event_id = v_event_id
            ON CONFLICT (personnel_id, run_result_id) DO NOTHING;
        END IF;
    END IF;

    RETURN NULL; -- This is an AFTER trigger, return value is ignored.
END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS trg_handle_insert_on_run_results ON ss_run_results;
DROP TRIGGER IF EXISTS trg_handle_update_on_run_results ON ss_run_results;

CREATE TRIGGER trg_handle_run_results
    AFTER INSERT OR UPDATE ON ss_run_results
    FOR EACH ROW
    EXECUTE FUNCTION handle_run_results();