CREATE OR REPLACE FUNCTION handle_update_on_run_results()
    RETURNS TRIGGER 
	AS $trigger$
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


DROP TRIGGER IF EXISTS trg_cascade_update_on_run_results ON ss_run_results;

CREATE TRIGGER trg_handle_update_on_run_results
	AFTER UPDATE ON ss_run_results
	FOR EACH ROW
	EXECUTE FUNCTION handle_update_on_run_results();