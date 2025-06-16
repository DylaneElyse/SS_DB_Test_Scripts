CREATE OR REPLACE FUNCTION handle_insert_on_event_judges()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO ss_run_scores (personnel_id, run_result_id)
    SELECT
        NEW.personnel_id,
        r.run_result_id
    FROM
        ss_run_results AS r
    WHERE
        r.event_id = NEW.event_id

    ON CONFLICT (personnel_id, run_result_id) DO NOTHING;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_create_scores_on_judge_insert ON ss_event_judges;

CREATE TRIGGER trg_create_scores_on_judge_insert
AFTER INSERT ON ss_event_judges
FOR EACH ROW
EXECUTE FUNCTION handle_insert_on_event_judges();