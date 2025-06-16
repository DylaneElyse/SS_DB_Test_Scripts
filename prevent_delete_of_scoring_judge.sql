CREATE OR REPLACE FUNCTION prevent_delete_of_scoring_judge()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ss_run_scores AS s
        JOIN ss_run_results AS r ON s.run_result_id = r.run_result_id
        WHERE
            s.personnel_id = OLD.personnel_id
        AND
            r.event_id = OLD.event_id
        AND
            s.score IS NOT NULL
    ) THEN
        RAISE EXCEPTION 'Cannot remove Judge (ID: %) from Event (ID: %): They have already submitted scores. Please clear or reassign their scores first.',
                        OLD.personnel_id, OLD.event_id;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_cleanup_scores_on_judge_delete ON ss_event_judges;
DROP TRIGGER IF EXISTS trg_prevent_judge_delete_if_scored ON ss_event_judges;

CREATE TRIGGER trg_prevent_judge_delete_if_scored
BEFORE DELETE ON ss_event_judges
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_of_scoring_judge();