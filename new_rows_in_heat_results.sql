CREATE FUNCTION handle_insert_on_heat_results()
RETURNS TRIGGER AS $$
DECLARE
    v_num_runs ss_heat_details.num_runs%TYPE;
    v_count INT;

BEGIN
    SELECT INTO v_num_runs
        FROM ss_heat_details
        WHERE round_heat_id = NEW.round_heat_id;

    WHILE v_count != v_num_runs LOOP
        INSERT INTO ss_run_results (round_heat_id, event_id, division_id, athlete_id, run_num)
            VALUES (NEW.round_heat_id, NEW.event_id, NEW.division_id, NEW.athlete_id, v_count)
            ON CONFLICT (round_heat_id, event_id, division_id, athlete_id, run_num) DO NOTHING;