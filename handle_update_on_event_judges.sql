CREATE OR REPLACE FUNCTION handle_update_on_event_judges()
  RETURNS TRIGGER AS $trigger$
BEGIN
    IF NEW.personnel_id IS DISTINCT FROM OLD.personnel_id THEN
        UPDATE ss_run_scores
        SET personnel_id = NEW.personnel_id
        WHERE personnel_id = OLD.personnel_id
          AND run_result_id IN (
            SELECT run_result_id FROM ss_run_results WHERE event_id = NEW.event_id
        );
    END IF;

    IF NEW.event_id IS DISTINCT FROM OLD.event_id THEN
        DELETE FROM ss_run_scores
        WHERE personnel_id = OLD.personnel_id
          AND run_result_id IN (
            SELECT run_result_id FROM ss_run_results WHERE event_id = OLD.event_id
        );

        INSERT INTO ss_run_scores (personnel_id, run_result_id)
        SELECT
            NEW.personnel_id,
            r.run_result_id
        FROM ss_run_results AS r
        WHERE r.event_id = NEW.event_id
        ON CONFLICT (personnel_id, run_result_id) DO NOTHING;
    END IF;

    RETURN NULL;
END;
$trigger$ LANGUAGE plpgsql;


CREATE TRIGGER trg_cascade_update_on_event_judges
AFTER UPDATE ON ss_event_judges
FOR EACH ROW
EXECUTE FUNCTION handle_update_on_event_judges();