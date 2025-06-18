CREATE OR REPLACE FUNCTION handle_insert_on_heat_results()
  RETURNS TRIGGER AS $trigger$
DECLARE
    v_num_runs ss_heat_details.num_runs%TYPE;
BEGIN
    SELECT hd.num_runs
    INTO v_num_runs
    FROM ss_heat_details AS hd
    WHERE hd.heat_id = NEW.heat_id;

    IF v_num_runs > 0 THEN
        FOR i IN 1..v_num_runs LOOP
            INSERT INTO ss_run_results (heat_id, event_id, division_id, athlete_id, run_num)
            VALUES (NEW.heat_id, NEW.event_id, NEW.division_id, NEW.athlete_id, i)
            ON CONFLICT (heat_id, event_id, division_id, athlete_id, run_num) DO NOTHING;
        END LOOP;
    END IF;

    RETURN NULL;
END;
$trigger$ LANGUAGE plpgsql;



CREATE TRIGGER trg_create_run_results_on_heat_insert
AFTER INSERT ON ss_heat_results
FOR EACH ROW
EXECUTE FUNCTION handle_insert_on_heat_results();