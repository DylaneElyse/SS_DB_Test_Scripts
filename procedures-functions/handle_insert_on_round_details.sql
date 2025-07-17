CREATE OR REPLACE FUNCTION handle_insert_on_round_details()
	RETURNS trigger
	AS $function$
DECLARE
	v_count INT;
BEGIN
	IF NEW.num_heats IS NOT NULL AND NEW.num_heats > 0 THEN
	v_count := 1;
	WHILE (v_count <= NEW.num_heats) LOOP
		INSERT INTO ss_heat_details (heat_num, num_runs, round_id)
		VALUES (v_count, DEFAULT, NEW.round_id);

		v_count := v_count + 1;
	END LOOP;
	END IF;

	RETURN NEW;
END;
$function$ LANGUAGE plpgsql;


CREATE TRIGGER trg_handle_insert_on_round_details
	AFTER INSERT ON ss_round_details
	FOR EACH ROW
	EXECUTE FUNCTION handle_insert_on_round_details();

