-- Neon Triggers - August 10

    trg_manage_event_divisions_after_insert AFTER INSERT ON ss_event_divisions FOR EACH ROW EXECUTE FUNCTION handle_event_divisions();
    trg_manage_event_divisions_after_update AFTER UPDATE ON ss_event_divisions FOR EACH ROW WHEN (old.num_rounds IS DISTINCT FROM new.num_rounds) EXECUTE FUNCTION handle_event_divisions();


    trg_prevent_event_judge_reassignment BEFORE UPDATE ON ss_event_judges FOR EACH ROW WHEN (old.event_id IS DISTINCT FROM new.event_id) EXECUTE FUNCTION prevent_event_judge_reassignment();
    trg_set_judge_passcode_if_null BEFORE INSERT ON ss_event_judges FOR EACH ROW EXECUTE FUNCTION set_judge_passcode_if_null(); 


    trg_handle_insert_on_event_registrations AFTER INSERT ON ss_event_registrations FOR EACH ROW EXECUTE FUNCTION handle_insert_on_event_registrations();
    trg_handle_update_on_event_registrations AFTER UPDATE ON ss_event_registrations FOR EACH ROW WHEN (old.event_id IS DISTINCT FROM new.event_id OR old.division_id IS DISTINCT FROM new.division_id) EXECUTE FUNCTION handle_update_on_event_registrations();
    trg_reseeding_after_registration_delete AFTER DELETE ON ss_event_registrations REFERENCING OLD TABLE AS old_rows FOR EACH STATEMENT EXECUTE FUNCTION manage_registration_reseeding();
    trg_reseeding_after_registration_insert AFTER INSERT ON ss_event_registrations REFERENCING NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION manage_registration_reseeding();
    trg_reseeding_after_registration_update AFTER UPDATE ON ss_event_registrations REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION manage_registration_reseeding();


    trg_handle_insert_on_heat_details AFTER INSERT ON ss_heat_details FOR EACH ROW EXECUTE FUNCTION handle_insert_on_heat_details();
    trg_handle_update_on_heat_details AFTER UPDATE ON ss_heat_details FOR EACH ROW WHEN (old.num_runs IS DISTINCT FROM new.num_runs) EXECUTE FUNCTION handle_update_on_heat_details();


    trg_handle_update_on_heat_judges AFTER UPDATE ON ss_heat_judges FOR EACH ROW EXECUTE FUNCTION handle_update_on_heat_judges();
    trg_prevent_heat_judge_reassignment BEFORE UPDATE ON ss_heat_judges FOR EACH ROW EXECUTE FUNCTION prevent_heat_judge_reassignment();


    trg_handle_insert_on_heat_results AFTER INSERT ON ss_heat_results FOR EACH ROW EXECUTE FUNCTION handle_insert_on_heat_results();
    trg_handle_update_on_heat_results AFTER UPDATE ON ss_heat_results FOR EACH ROW WHEN (old.round_heat_id IS DISTINCT FROM new.round_heat_id OR old.best IS DISTINCT FROM new.best) EXECUTE FUNCTION handle_update_on_heat_results();
    trg_reseed_after_heat_results_delete AFTER DELETE ON ss_heat_results REFERENCING OLD TABLE AS old_rows FOR EACH STATEMENT EXECUTE FUNCTION manage_heat_reseeding();
    trg_reseed_after_heat_results_insert AFTER INSERT ON ss_heat_results REFERENCING NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION manage_heat_reseeding();
    trg_reseed_after_heat_results_update AFTER UPDATE ON ss_heat_results REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION manage_heat_reseeding();
    trg_update_round_athlete_count_after_delete AFTER DELETE ON ss_heat_results REFERENCING OLD TABLE AS old_rows FOR EACH STATEMENT EXECUTE FUNCTION update_round_athlete_count();
    trg_update_round_athlete_count_after_insert AFTER INSERT ON ss_heat_results REFERENCING NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION update_round_athlete_count();
    trg_update_round_athlete_count_after_update AFTER UPDATE ON ss_heat_results REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION update_round_athlete_count();


    trg_manage_round_details_after_insert AFTER INSERT ON ss_round_details FOR EACH ROW EXECUTE FUNCTION handle_round_details();

    trg_manage_round_details_after_update AFTER UPDATE ON ss_round_details FOR EACH ROW WHEN (old.num_heats IS DISTINCT FROM new.num_heats) EXECUTE FUNCTION handle_round_details();

    trg_handle_insert_on_run_results AFTER INSERT OR UPDATE ON ss_run_results FOR EACH ROW EXECUTE FUNCTION handle_insert_on_run_results();

    trg_update_scores_after_delete AFTER DELETE ON ss_run_scores FOR EACH ROW EXECUTE FUNCTION trg_start_score_calculation_chain();
    trg_update_scores_after_insert_update AFTER INSERT OR UPDATE ON ss_run_scores FOR EACH ROW WHEN (new.score IS NOT NULL) EXECUTE FUNCTION trg_start_score_calculation_chain();
