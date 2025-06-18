-- 1.
CREATE TRIGGER trg_after_insert_on_event_division
    AFTER INSERT ON ss_event_divisions
    FOR EACH ROW
    EXECUTE FUNCTION handle_insert_on_event_division();

-- 2.
CREATE TRIGGER trg_create_scores_on_judge_insert
    AFTER INSERT ON ss_event_judges
    FOR EACH ROW
    EXECUTE FUNCTION handle_insert_on_event_judges();

-- 3.
CREATE TRIGGER trg_handle_insert_on_event_registrations
    AFTER INSERT ON ss_event_registrations
    FOR EACH ROW 
    EXECUTE FUNCTION handle_insert_on_event_registrations();

-- 4.
CREATE TRIGGER trg_reseed_affected_heats
    AFTER INSERT ON ss_event_registrations
    REFERENCING NEW TABLE AS new_rows
    FOR EACH STATEMENT EXECUTE FUNCTION reseed_affected_heats();

-- 5.
CREATE TRIGGER trg_populate_new_heat
    AFTER INSERT ON ss_heat_details
    FOR EACH ROW
    EXECUTE FUNCTION handle_insert_on_heat_details();

-- 6.
CREATE TRIGGER trg_create_run_results_on_heat_insert
    AFTER INSERT ON ss_heat_results
    FOR EACH ROW
    EXECUTE FUNCTION handle_insert_on_heat_results();

-- 7.
CREATE TRIGGER trg_after_insert_on_round_details
    AFTER INSERT ON ss_round_details
    FOR EACH ROW
    EXECUTE FUNCTION handle_insert_on_round_details();

-- 8.
CREATE TRIGGER trg_create_scores_on_run_insert
    AFTER INSERT ON ss_run_results
    FOR EACH ROW
    EXECUTE FUNCTION handle_insert_on_run_results();

-- 9.
CREATE TRIGGER trg_after_update_on_event_division
    AFTER UPDATE ON ss_event_divisions
    FOR EACH ROW
    EXECUTE FUNCTION handle_update_on_event_division();

-- 10.
CREATE TRIGGER trg_cascade_update_on_event_judges
    AFTER UPDATE ON ss_event_judges
    FOR EACH ROW
    EXECUTE FUNCTION handle_update_on_event_judges();

-- 11.
CREATE TRIGGER trg_handle_update_on_event_registrations
    AFTER UPDATE ON ss_event_registrations
    FOR EACH ROW 
    EXECUTE FUNCTION handle_update_on_event_registrations();

-- 12.
CREATE TRIGGER trg_reseed_after_update
    AFTER UPDATE ON ss_event_registrations
    REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows
    FOR EACH STATEMENT EXECUTE FUNCTION reseed_after_update();

-- 13.
CREATE TRIGGER trg_sync_on_heat_details_update
    AFTER UPDATE ON ss_heat_details
    FOR EACH ROW
    EXECUTE FUNCTION handle_update_on_heat_details();

-- 14.
CREATE TRIGGER trg_cascade_update_on_heat_results
    AFTER UPDATE ON ss_heat_results
    FOR EACH ROW
    EXECUTE FUNCTION handle_update_on_heat_results();

-- 15.
CREATE TRIGGER trg_sync_heats_on_round_update
    AFTER UPDATE ON ss_round_details
    FOR EACH ROW
    EXECUTE FUNCTION handle_update_on_round_details();

-- 16.
CREATE TRIGGER trg_cascade_update_on_run_results
    AFTER UPDATE ON ss_run_results
    FOR EACH ROW
    EXECUTE FUNCTION handle_update_on_run_results();

-- 17.
CREATE TRIGGER trg_manage_judge_deletion
    BEFORE DELETE ON ss_event_judges
    FOR EACH ROW
    EXECUTE FUNCTION manage_judge_deletion_with_cleanup();

-- 18.
CREATE TRIGGER trg_prevent_invalid_judge_update
    BEFORE UPDATE ON ss_event_judges
    FOR EACH ROW
    EXECUTE FUNCTION prevent_invalid_judge_update();

-- 19.
CREATE TRIGGER trigger_set_judge_passcode
    BEFORE INSERT
    ON ss_event_judges
    FOR EACH ROW
    EXECUTE FUNCTION set_judge_passcode_if_null();