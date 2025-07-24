-- 1. Insert on ss_event_divisions
CREATE TRIGGER trg_manage_event_divisions_after_insert
    AFTER INSERT ON ss_event_divisions
    FOR EACH ROW
    EXECUTE FUNCTION handle_event_divisions();

-- 2. Update on ss_event_divisions
CREATE TRIGGER trg_manage_event_divisions_after_update
    AFTER UPDATE ON ss_event_divisions
    FOR EACH ROW
    WHEN (OLD.num_rounds IS DISTINCT FROM NEW.num_rounds)
    EXECUTE FUNCTION handle_event_divisions();

-- 3. Insert on ss_round_details
CREATE TRIGGER trg_manage_round_details_after_insert
    AFTER INSERT ON ss_round_details
    FOR EACH ROW
    EXECUTE FUNCTION handle_round_details();

-- 4. Update on ss_round_details
CREATE TRIGGER trg_manage_round_details_after_update
    AFTER UPDATE ON ss_round_details
    FOR EACH ROW
    WHEN (OLD.num_heats IS DISTINCT FROM NEW.num_heats)
    EXECUTE FUNCTION handle_round_details();

-- 5. Insert on ss_heat_details
CREATE TRIGGER trg_handle_insert_on_heat_details
	AFTER INSERT ON ss_heat_details
	FOR EACH ROW
	EXECUTE FUNCTION handle_insert_on_heat_details();

-- 6. Update on ss_heat_details
CREATE TRIGGER trg_handle_update_on_heat_details
	AFTER UPDATE ON ss_heat_details
	FOR EACH ROW
    WHEN (OLD.num_runs IS DISTINCT FROM NEW.num_runs)
	EXECUTE FUNCTION handle_update_on_heat_details();

-- 7. Insert on ss_event_registrations
CREATE TRIGGER trg_handle_insert_on_event_registrations
    AFTER INSERT ON ss_event_registrations
    FOR EACH ROW
    EXECUTE FUNCTION handle_insert_on_event_registrations();

-- 8. Update on ss_event_registrations
CREATE TRIGGER trg_handle_update_on_event_registrations
    AFTER UPDATE ON ss_event_registrations
    FOR EACH ROW
    WHEN ((OLD.event_id, OLD.division_id) IS DISTINCT FROM (NEW.event_id, NEW.division_id))
    EXECUTE FUNCTION handle_update_on_event_registrations();

-- 9. Handles reseeding after insert on ss_event_registrations
CREATE TRIGGER trg_reseeding_after_registration_insert
    AFTER INSERT ON ss_event_registrations
    REFERENCING NEW TABLE AS new_rows
    FOR EACH STATEMENT
    EXECUTE FUNCTION manage_registration_reseeding();

-- 10. Handles reseeding after update on ss_event_registrations
CREATE TRIGGER trg_reseeding_after_registration_update
    AFTER UPDATE ON ss_event_registrations
    REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows
    FOR EACH STATEMENT
    EXECUTE FUNCTION manage_registration_reseeding();

-- 11. Handles reseeding after delete on ss_event_registrations
CREATE TRIGGER trg_reseeding_after_registration_delete
    AFTER DELETE ON ss_event_registrations
    REFERENCING OLD TABLE AS old_rows
    FOR EACH STATEMENT
    EXECUTE FUNCTION manage_registration_reseeding();

-- 12. Insert on ss_heat_results
CREATE TRIGGER trg_handle_insert_on_heat_results
	AFTER INSERT ON ss_heat_results
	FOR EACH ROW
	EXECUTE FUNCTION handle_insert_on_heat_results();

-- 13. Update on ss_heat_results
CREATE TRIGGER trg_handle_update_on_heat_results
	AFTER UPDATE ON ss_heat_results
	FOR EACH ROW
    WHEN (OLD.round_heat_id IS DISTINCT FROM NEW.round_heat_id OR OLD.best IS DISTINCT FROM NEW.best)
	EXECUTE FUNCTION handle_update_on_heat_results();

-- 14. Judge passcode handling
CREATE TRIGGER trg_set_judge_passcode_if_null
	BEFORE INSERT ON ss_event_judges
	FOR EACH ROW
	EXECUTE FUNCTION set_judge_passcode_if_null();

-- 15. Insert or update on ss_run_results
CREATE TRIGGER trg_handle_insert_on_run_results
    AFTER INSERT OR UPDATE ON ss_run_results
    FOR EACH ROW
    EXECUTE FUNCTION handle_insert_on_run_results();

-- 16. Insert or update on ss_run_scores
CREATE TRIGGER trg_update_scores_after_insert_update
	AFTER INSERT OR UPDATE ON ss_run_scores
	FOR EACH ROW
	WHEN (NEW.score IS NOT NULL)
	EXECUTE FUNCTION trg_start_score_calculation_chain();

-- 17. Delete on ss_run_scores
CREATE TRIGGER trg_update_scores_after_delete
	AFTER DELETE ON ss_run_scores
	FOR EACH ROW
	EXECUTE FUNCTION trg_start_score_calculation_chain();

-- 18. Prevent event judge reassignment
CREATE TRIGGER trg_prevent_event_judge_reassignment
    BEFORE UPDATE ON ss_event_judges
    FOR EACH ROW
    WHEN (OLD.event_id IS DISTINCT FROM NEW.event_id)
    EXECUTE FUNCTION prevent_event_judge_reassignment();

-- 19. Prevent heat judge reassignment
CREATE TRIGGER trg_prevent_heat_judge_reassignment
    BEFORE UPDATE ON ss_heat_judges
    FOR EACH ROW
    EXECUTE FUNCTION prevent_heat_judge_reassignment();

-- 20. After update on ss_heat_judges
CREATE TRIGGER trg_handle_update_on_heat_judges
    AFTER UPDATE ON ss_heat_judges
    FOR EACH ROW
    EXECUTE FUNCTION handle_update_on_heat_judges();

-- 19. After insert on ss_heat_results
CREATE TRIGGER trg_update_round_athlete_count_after_insert
    AFTER INSERT ON ss_heat_results
    REFERENCING NEW TABLE AS new_rows
    FOR EACH STATEMENT
    EXECUTE FUNCTION update_round_athlete_count();

-- 20. After update on ss_heat_results
CREATE TRIGGER trg_update_round_athlete_count_after_update
    AFTER UPDATE ON ss_heat_results
    REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows
    FOR EACH STATEMENT
    EXECUTE FUNCTION update_round_athlete_count();

-- 21. After delete on ss_heat_results
CREATE TRIGGER trg_update_round_athlete_count_after_delete
    AFTER DELETE ON ss_heat_results
    REFERENCING OLD TABLE AS old_rows
    FOR EACH STATEMENT
    EXECUTE FUNCTION update_round_athlete_count();

-- 22. After insert on ss_heat_results
CREATE TRIGGER trg_reseed_after_heat_results_insert
    AFTER INSERT ON ss_heat_results
    REFERENCING NEW TABLE AS new_rows
    FOR EACH STATEMENT
    EXECUTE FUNCTION manage_heat_reseeding();

-- 23. After update on ss_heat_results
CREATE TRIGGER trg_reseed_after_heat_results_update
    AFTER UPDATE ON ss_heat_results
    REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows
    FOR EACH STATEMENT
    EXECUTE FUNCTION manage_heat_reseeding();

-- 24. After delete on ss_heat_results
CREATE TRIGGER trg_reseed_after_heat_results_delete
    AFTER DELETE ON ss_heat_results
    REFERENCING OLD TABLE AS old_rows
    FOR EACH STATEMENT
    EXECUTE FUNCTION manage_heat_reseeding();