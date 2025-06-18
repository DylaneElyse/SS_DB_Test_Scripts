CREATE OR REPLACE FUNCTION handle_update_on_run_results()
  RETURNS TRIGGER AS $trigger$
BEGIN
    IF NEW.run_result_id IS DISTINCT FROM OLD.run_result_id OR NEW.event_id IS DISTINCT FROM OLD.event_id THEN
        DELETE FROM ss_run_scores
        WHERE run_result_id = OLD.run_result_id;

        INSERT INTO ss_run_scores (personnel_id, run_result_id)
        SELECT
            j.personnel_id,
            NEW.run_result_id
        FROM ss_event_judges AS j
        WHERE j.event_id = NEW.event_id
        ON CONFLICT (personnel_id, run_result_id) DO NOTHING;
    END IF;

    RETURN NULL;
END;
$trigger$ LANGUAGE plpgsql;



CREATE TRIGGER trg_cascade_update_on_run_results
AFTER UPDATE ON ss_run_results
FOR EACH ROW
EXECUTE FUNCTION handle_update_on_run_results();