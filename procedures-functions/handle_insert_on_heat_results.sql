CREATE OR REPLACE FUNCTION handle_insert_on_heat_results()
	RETURNS TRIGGER 
	AS $function$
DECLARE
    v_num_runs ss_heat_details.num_runs%TYPE;
    i INT; 
BEGIN
    SELECT num_runs INTO v_num_runs
    FROM ss_heat_details
    WHERE round_heat_id = NEW.round_heat_id;

    IF v_num_runs IS NOT NULL AND v_num_runs > 0 THEN

        FOR i IN 1..v_num_runs LOOP

            INSERT INTO ss_run_results (round_heat_id, event_id, division_id, athlete_id, run_num)
            VALUES (NEW.round_heat_id, NEW.event_id, NEW.division_id, NEW.athlete_id, i)

            ON CONFLICT (round_heat_id, event_id, division_id, athlete_id, run_num) DO NOTHING;

        END LOOP;
    END IF;

    RETURN NULL;
END;
$function$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS trg_create_run_results_on_heat_insert ON ss_heat_results;

CREATE TRIGGER trg_handle_insert_on_heat_results
	AFTER INSERT ON ss_heat_results
	FOR EACH ROW
	EXECUTE FUNCTION handle_insert_on_heat_results();