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


-- 1. Insert and update on ss_event_divisions
CREATE TRIGGER trg_manage_event_divisions
    AFTER INSERT OR UPDATE ON ss_event_divisions
    FOR EACH ROW
    EXECUTE FUNCTION handle_event_divisions();

-- 2. Insert and update on ss_round_details
CREATE TRIGGER trg_manage_round_details
    AFTER INSERT OR UPDATE ON ss_round_details
    FOR EACH ROW
    EXECUTE FUNCTION handle_round_details();

-- 3. Insert on ss_heat_details
CREATE TRIGGER trg_handle_insert_on_heat_details
	AFTER INSERT ON ss_heat_details
	FOR EACH ROW
	EXECUTE FUNCTION handle_insert_on_heat_details();

-- 4. Update on ss_heat_details
CREATE TRIGGER trg_handle_update_on_heat_details
	AFTER UPDATE ON ss_heat_details
	FOR EACH ROW
	EXECUTE FUNCTION handle_update_on_heat_details();

-- 5. Insert on ss_event_registrations
CREATE TRIGGER trg_handle_insert_on_event_registrations
    AFTER INSERT ON ss_event_registrations
    FOR EACH ROW
    EXECUTE FUNCTION handle_insert_on_event_registrations();

-- 6. Update on ss_event_registrations
CREATE TRIGGER trg_handle_update_on_event_registrations
    AFTER UPDATE ON ss_event_registrations
    FOR EACH ROW
    EXECUTE FUNCTION handle_update_on_event_registrations();

-- 7. Handles reseeding after insert on ss_event_registrations
CREATE TRIGGER trg_reseeding_after_registration_insert
    AFTER INSERT ON ss_event_registrations
    REFERENCING NEW TABLE AS new_rows
    FOR EACH STATEMENT
    EXECUTE FUNCTION manage_registration_reseeding();

-- 8. Handles reseeding after update on ss_event_registrations
CREATE TRIGGER trg_reseeding_after_registration_update
    AFTER UPDATE ON ss_event_registrations
    REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows
    FOR EACH STATEMENT
    EXECUTE FUNCTION manage_registration_reseeding();

-- 9. Handles reseeding after delete on ss_event_registrations
CREATE TRIGGER trg_reseeding_after_registration_delete
    AFTER DELETE ON ss_event_registrations
    REFERENCING OLD TABLE AS old_rows
    FOR EACH STATEMENT
    EXECUTE FUNCTION manage_registration_reseeding();

-- 10. Insert on ss_heat_results
CREATE TRIGGER trg_handle_insert_on_heat_results
	AFTER INSERT ON ss_heat_results
	FOR EACH ROW
	EXECUTE FUNCTION handle_insert_on_heat_results();

-- 11. Update on ss_heat_results
CREATE TRIGGER trg_handle_update_on_heat_results
	AFTER UPDATE ON ss_heat_results
	FOR EACH ROW
	EXECUTE FUNCTION handle_update_on_heat_results();

-- 12. Update on ss_event_judges
CREATE TRIGGER trg_prevent_invalid_judge_update
	BEFORE UPDATE ON ss_event_judges
	FOR EACH ROW
	EXECUTE FUNCTION prevent_invalid_judge_update();

-- 13. Judge passcode handling
CREATE TRIGGER trg_set_judge_passcode_if_null
	BEFORE INSERT ON ss_event_judges
	FOR EACH ROW
	EXECUTE FUNCTION set_judge_passcode_if_null();

-- 14. Insert or update on ss_run_results
CREATE TRIGGER trg_manage_run_scores
    AFTER INSERT OR UPDATE ON ss_run_results
    FOR EACH ROW
    EXECUTE FUNCTION handle_run_results_creation();

-- 15. Insert or update on ss_run_scores
CREATE TRIGGER trg_update_scores_after_change
	AFTER INSERT OR UPDATE OR DELETE ON ss_run_scores
	FOR EACH ROW
	EXECUTE FUNCTION trg_start_score_calculation_chain();

-- 16. Prevent event judge reassignment
CREATE TRIGGER trg_prevent_event_judge_reassignment
    BEFORE UPDATE ON ss_event_judges
    FOR EACH ROW
    WHEN (OLD.event_id IS DISTINCT FROM NEW.event_id)
    EXECUTE FUNCTION prevent_event_judge_reassignment();

-- 17. Prevent heat judge reassignment
CREATE TRIGGER trg_prevent_heat_judge_reassignment
    BEFORE UPDATE ON ss_heat_judges
    FOR EACH ROW
    EXECUTE FUNCTION prevent_heat_judge_reassignment();

-- 18. After update on ss_heat_judges
CREATE TRIGGER trg_handle_update_on_heat_judges
    AFTER UPDATE ON ss_heat_judges
    FOR EACH ROW
    EXECUTE FUNCTION handle_update_on_heat_judges();