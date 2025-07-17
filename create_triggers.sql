-- 1.
CREATE TRIGGER trg_handle_event_divisions
    AFTER INSERT OR UPDATE ON ss_event_divisions
    FOR EACH ROW
    EXECUTE FUNCTION handle_event_divisions();

-- 2.
CREATE TRIGGER trg_handle_round_details
    AFTER INSERT OR UPDATE ON ss_round_details
    FOR EACH ROW
    EXECUTE FUNCTION handle_round_details();

-- 3.
CREATE TRIGGER trg_handle_insert_on_heat_details
	AFTER INSERT ON ss_heat_details
	FOR EACH ROW
	EXECUTE FUNCTION handle_insert_on_heat_details();

-- 4.
CREATE TRIGGER trg_handle_update_on_heat_details
	AFTER UPDATE ON ss_heat_details
	FOR EACH ROW
	EXECUTE FUNCTION handle_update_on_heat_details();

-- 5.
CREATE TRIGGER trg_handle_insert_on_event_registrations
	AFTER INSERT ON ss_event_registrations
	FOR EACH ROW 
	EXECUTE FUNCTION handle_insert_on_event_registrations();

-- 6.
CREATE TRIGGER trg_handle_update_on_event_registrations
	AFTER UPDATE ON ss_event_registrations
	FOR EACH ROW 
	EXECUTE FUNCTION handle_update_on_event_registrations();

-- 7.
CREATE TRIGGER trg_reseed_affected_heats
	AFTER INSERT ON ss_event_registrations
	FOR EACH STATEMENT 
	EXECUTE FUNCTION reseed_affected_heats();

-- 8.
CREATE TRIGGER trg_reseed_after_update
	AFTER UPDATE ON ss_event_registrations
	REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows
	FOR EACH STATEMENT EXECUTE FUNCTION reseed_after_update();

-- 9.
CREATE TRIGGER trg_handle_insert_on_heat_results
	AFTER INSERT ON ss_heat_results
	FOR EACH ROW
	EXECUTE FUNCTION handle_insert_on_heat_results();

-- 10.
CREATE TRIGGER trg_handle_update_on_heat_results
	AFTER UPDATE ON ss_heat_results
	FOR EACH ROW
	EXECUTE FUNCTION handle_update_on_heat_results();

-- 11.
CREATE TRIGGER trg_handle_insert_on_event_judges
	AFTER INSERT ON ss_event_judges
	FOR EACH ROW
	EXECUTE FUNCTION handle_insert_on_event_judges();

-- 12.
CREATE TRIGGER trg_prevent_invalid_judge_update
	BEFORE UPDATE ON ss_event_judges
	FOR EACH ROW
	EXECUTE FUNCTION prevent_invalid_judge_update();

-- 13.
CREATE TRIGGER trg_set_judge_passcode_if_null
	BEFORE INSERT ON ss_event_judges
	FOR EACH ROW
	EXECUTE FUNCTION set_judge_passcode_if_null();

-- 14.
CREATE TRIGGER trg_handle_run_results
    AFTER INSERT OR UPDATE ON ss_run_results
    FOR EACH ROW
    EXECUTE FUNCTION handle_run_results();

-- 15.
CREATE TRIGGER trg_update_scores_after_change
	AFTER INSERT OR UPDATE OR DELETE ON ss_run_scores
	FOR EACH ROW
	EXECUTE FUNCTION trg_start_score_calculation_chain();

-- 16.
CREATE TRIGGER trg_reseeding_after_registration_change
    AFTER INSERT OR UPDATE OR DELETE ON ss_event_registrations
    REFERENCING NEW TABLE AS new_rows OLD TABLE AS old_rows
    FOR EACH STATEMENT
    EXECUTE FUNCTION manage_registration_reseeding();