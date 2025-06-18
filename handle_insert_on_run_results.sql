CREATE OR REPLACE FUNCTION handle_insert_on_run_results()
  RETURNS TRIGGER AS $trigger$
BEGIN
    INSERT INTO ss_run_scores (personnel_id, run_result_id)
    SELECT
        j.personnel_id,
        NEW.run_result_id
    FROM ss_event_judges AS j
    WHERE j.event_id = NEW.event_id
    ON CONFLICT (personnel_id, run_result_id) DO NOTHING;

    RETURN NULL;
END;
$trigger$ LANGUAGE plpgsql;



CREATE TRIGGER trg_create_scores_on_run_insert
AFTER INSERT ON ss_run_results
FOR EACH ROW
EXECUTE FUNCTION handle_insert_on_run_results();