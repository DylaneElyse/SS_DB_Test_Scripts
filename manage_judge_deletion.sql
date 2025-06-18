CREATE OR REPLACE FUNCTION manage_judge_deletion_with_cleanup()
RETURNS TRIGGER AS $$
DECLARE
    has_scored_rows BOOLEAN := false;
    deleted_null_scores_count INT;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM ss_run_scores AS s
        JOIN ss_run_results AS r ON s.run_result_id = r.run_result_id
        WHERE
            s.personnel_id = OLD.personnel_id
        AND
            r.event_id = OLD.event_id
        AND
            s.score IS NOT NULL
    ) INTO has_scored_rows;

    WITH deleted_rows AS (
        DELETE FROM ss_run_scores s
        USING ss_run_results r
        WHERE
            s.run_result_id = r.run_result_id
        AND s.personnel_id = OLD.personnel_id
        AND r.event_id = OLD.event_id
        AND s.score IS NULL
        RETURNING 1
    )
    SELECT count(*) INTO deleted_null_scores_count FROM deleted_rows;
    
    RAISE NOTICE 'Cleanup phase: Deleted % placeholder score row(s) for Judge (ID: %).', 
                    deleted_null_scores_count, OLD.personnel_id;


    IF has_scored_rows THEN
        RAISE EXCEPTION 'Cannot remove Judge (ID: %): They have submitted scores. % placeholder scores were cleaned up, but the judge was NOT removed from the event.',
                        OLD.personnel_id, deleted_null_scores_count;

    ELSE
        RAISE NOTICE 'No submitted scores found for Judge (ID: %). Proceeding with deletion from event.', OLD.personnel_id;
        RETURN OLD;
    END IF;

END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS trg_prevent_judge_delete_if_scored ON ss_event_judges;
DROP TRIGGER IF EXISTS trg_handle_judge_deletion ON ss_event_judges;
DROP TRIGGER IF EXISTS trg_cleanup_null_scores_on_judge_delete ON ss_event_judges;

CREATE TRIGGER trg_manage_judge_deletion
BEFORE DELETE ON ss_event_judges
FOR EACH ROW
EXECUTE FUNCTION manage_judge_deletion_with_cleanup();




-- CREATE OR REPLACE FUNCTION prevent_delete_of_scoring_judge()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     IF EXISTS (
--         SELECT 1
--         FROM ss_run_scores AS s
--         JOIN ss_run_results AS r ON s.run_result_id = r.run_result_id
--         WHERE
--             s.personnel_id = OLD.personnel_id
--         AND
--             r.event_id = OLD.event_id
--         AND
--             s.score IS NOT NULL
--     ) THEN
--         RAISE EXCEPTION 'Cannot remove Judge (ID: %) from Event (ID: %): They have already submitted scores. Please clear or reassign their scores first.',
--                         OLD.personnel_id, OLD.event_id;
--     END IF;
--     RETURN OLD;
-- END;
-- $$ LANGUAGE plpgsql;
