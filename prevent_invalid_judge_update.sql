CREATE OR REPLACE FUNCTION prevent_invalid_judge_update()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.personnel_id IS DISTINCT FROM OLD.personnel_id OR
       NEW.event_id IS DISTINCT FROM OLD.event_id
    THEN
        IF EXISTS (
            SELECT 1
            FROM ss_run_scores s
            JOIN ss_run_results r ON s.run_result_id = r.run_result_id
            WHERE s.personnel_id = OLD.personnel_id
              AND r.event_id = OLD.event_id
              AND s.score IS NOT NULL
        ) THEN
            RAISE EXCEPTION 'Update failed. Judge (ID: %) cannot be removed from event (ID: %) because they have already submitted scores.',
                            OLD.personnel_id, OLD.event_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_invalid_judge_update ON ss_event_judges;

CREATE TRIGGER trg_prevent_invalid_judge_update
BEFORE UPDATE ON ss_event_judges
FOR EACH ROW
EXECUTE FUNCTION prevent_invalid_judge_update();