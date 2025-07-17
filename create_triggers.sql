DROP TRIGGER IF EXISTS trg_handle_insert_on_event_division ON ss_event_divisions;
DROP TRIGGER IF EXISTS trg_handle_update_on_event_division ON ss_event_divisions;
DROP TRIGGER IF EXISTS trg_handle_insert_on_round_details ON ss_round_details;
DROP TRIGGER IF EXISTS trg_handle_update_on_round_details ON ss_round_details;
DROP TRIGGER IF EXISTS trg_handle_insert_on_heat_details ON ss_heat_details;
DROP TRIGGER IF EXISTS trg_handle_update_on_heat_details ON ss_heat_details;
DROP TRIGGER IF EXISTS trg_handle_insert_on_event_registrations ON ss_event_registrations;
DROP TRIGGER IF EXISTS trg_handle_update_on_event_registrations ON ss_event_registrations;
DROP TRIGGER IF EXISTS trg_reseed_affected_heats ON ss_event_registrations;
DROP TRIGGER IF EXISTS trg_reseed_after_update ON ss_event_registrations;
DROP TRIGGER IF EXISTS trg_handle_insert_on_heat_results ON ss_heat_results;
DROP TRIGGER IF EXISTS trg_handle_update_on_heat_results ON ss_heat_results;
DROP TRIGGER IF EXISTS trg_handle_insert_on_event_judges ON ss_event_judges;
DROP TRIGGER IF EXISTS trg_prevent_invalid_judge_update ON ss_event_judges;
DROP TRIGGER IF EXISTS trg_set_judge_passcode_if_null ON ss_event_judges;
DROP TRIGGER IF EXISTS trg_handle_run_results ON ss_run_results;
DROP TRIGGER IF EXISTS trg_update_scores_after_change ON ss_run_scores;
DROP TRIGGER IF EXISTS trg_reseeding_after_registration_change ON ss_event_registrations;
DROP TRIGGER IF EXISTS trg_manage_event_divisions ON ss_event_divisions;
DROP TRIGGER IF EXISTS trg_manage_round_details ON ss_round_details;
DROP TRIGGER IF EXISTS trg_manage_run_scores ON ss_run_results;


-- 1. On ss_event_divisions (Handles rounds)
CREATE TRIGGER trg_manage_event_divisions
    AFTER INSERT OR UPDATE ON ss_event_divisions
    FOR EACH ROW
    EXECUTE FUNCTION handle_event_divisions();

-- 2. On ss_round_details (Handles heats)
CREATE TRIGGER trg_manage_round_details
    AFTER INSERT OR UPDATE ON ss_round_details
    FOR EACH ROW
    EXECUTE FUNCTION handle_round_details();

-- 3. On ss_heat_details (Separate logic for INSERT vs UPDATE)
CREATE TRIGGER trg_handle_insert_on_heat_details
	AFTER INSERT ON ss_heat_details
	FOR EACH ROW
	EXECUTE FUNCTION handle_insert_on_heat_details();

CREATE TRIGGER trg_handle_update_on_heat_details
	AFTER UPDATE ON ss_heat_details
	FOR EACH ROW
	EXECUTE FUNCTION handle_update_on_heat_details();

-- 4. On ss_event_registrations (The new, optimized setup)
CREATE TRIGGER trg_handle_insert_on_event_registrations
    AFTER INSERT ON ss_event_registrations
    FOR EACH ROW
    EXECUTE FUNCTION handle_insert_on_event_registrations();

-- 5. On ss_event_registrations (Handles athlete movement)
CREATE TRIGGER trg_handle_update_on_event_registrations
    AFTER UPDATE ON ss_event_registrations
    FOR EACH ROW
    EXECUTE FUNCTION handle_update_on_event_registrations();

-- 5. On ss_event_registrations (Handles reseeding after updates)
CREATE TRIGGER trg_reseeding_after_registration_insert
    AFTER INSERT ON ss_event_registrations
    REFERENCING NEW TABLE AS new_rows
    FOR EACH STATEMENT
    EXECUTE FUNCTION manage_registration_reseeding();

-- Trigger #2: For UPDATE operations
CREATE TRIGGER trg_reseeding_after_registration_update
    AFTER UPDATE ON ss_event_registrations
    REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows
    FOR EACH STATEMENT
    EXECUTE FUNCTION manage_registration_reseeding();

-- Trigger #3: For DELETE operations
CREATE TRIGGER trg_reseeding_after_registration_delete
    AFTER DELETE ON ss_event_registrations
    REFERENCING OLD TABLE AS old_rows
    FOR EACH STATEMENT
    EXECUTE FUNCTION manage_registration_reseeding();

-- 6. On ss_heat_results (Handles run creation)
CREATE TRIGGER trg_handle_insert_on_heat_results
	AFTER INSERT ON ss_heat_results
	FOR EACH ROW
	EXECUTE FUNCTION handle_insert_on_heat_results();

-- 7. On ss_heat_results (Handles updates to run results)
CREATE TRIGGER trg_handle_update_on_heat_results
	AFTER UPDATE ON ss_heat_results
	FOR EACH ROW
	EXECUTE FUNCTION handle_update_on_heat_results();

-- 8. On ss_event_judges (Handles judge setup)
CREATE TRIGGER trg_handle_insert_on_event_judges
	AFTER INSERT ON ss_event_judges
	FOR EACH ROW
	EXECUTE FUNCTION handle_insert_on_event_judges();

-- 9. On ss_event_judges (Prevents invalid updates)
CREATE TRIGGER trg_prevent_invalid_judge_update
	BEFORE UPDATE ON ss_event_judges
	FOR EACH ROW
	EXECUTE FUNCTION prevent_invalid_judge_update();

-- 10. On ss_event_judges (Sets passcode if NULL)
CREATE TRIGGER trg_set_judge_passcode_if_null
	BEFORE INSERT ON ss_event_judges
	FOR EACH ROW
	EXECUTE FUNCTION set_judge_passcode_if_null();

-- 11. On ss_run_results (Handles score placeholder creation)
CREATE TRIGGER trg_manage_run_scores
    AFTER INSERT OR UPDATE ON ss_run_results
    FOR EACH ROW
    EXECUTE FUNCTION manage_run_scores_from_run_result();

-- 12. On ss_run_scores (Starts the final calculation chain)
CREATE TRIGGER trg_update_scores_after_change
	AFTER INSERT OR UPDATE OR DELETE ON ss_run_scores
	FOR EACH ROW
	EXECUTE FUNCTION trg_start_score_calculation_chain();