CREATE OR REPLACE FUNCTION manage_judge_deletion_with_cleanup()
  RETURNS TRIGGER AS $trigger$
DECLARE
    v_has_scored_rows         BOOLEAN := FALSE;
    v_deleted_null_scores_count INT;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM ss_run_scores AS s
        JOIN ss_run_results AS r ON s.run_result_id = r.run_result_id
        WHERE s.personnel_id = OLD.personnel_id
          AND r.event_id = OLD.event_id
          AND s.score IS NOT NULL
    ) INTO v_has_scored_rows;

    WITH deleted_rows AS (
        DELETE FROM ss_run_scores AS s
        USING ss_run_results AS r
        WHERE s.run_result_id = r.run_result_id
          AND s.personnel_id = OLD.personnel_id
          AND r.event_id = OLD.event_id
          AND s.score IS NULL
        RETURNING 1
    )
    SELECT count(*)
    INTO v_deleted_null_scores_count
    FROM deleted_rows;

    RAISE NOTICE 'Cleanup phase: Deleted % placeholder score row(s) for Judge (ID: %).',
        v_deleted_null_scores_count, OLD.personnel_id;

    IF v_has_scored_rows THEN
        RAISE EXCEPTION 'Cannot remove Judge (ID: %): They have submitted scores. % placeholder scores were cleaned up, but the judge was NOT removed from the event.',
            OLD.personnel_id, v_deleted_null_scores_count;
    ELSE
        RAISE NOTICE 'No submitted scores found for Judge (ID: %). Proceeding with deletion from event.', OLD.personnel_id;
        RETURN OLD;
    END IF;
END;
$trigger$ LANGUAGE plpgsql;


CREATE TRIGGER trg_manage_judge_deletion
BEFORE DELETE ON ss_event_judges
FOR EACH ROW
EXECUTE FUNCTION manage_judge_deletion_with_cleanup();
