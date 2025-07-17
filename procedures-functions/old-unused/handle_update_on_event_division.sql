CREATE OR REPLACE FUNCTION handle_update_on_event_division()
    RETURNS trigger 
	AS $function$
BEGIN
    IF NEW.num_rounds IS DISTINCT FROM OLD.num_rounds THEN
		DELETE FROM ss_round_details
		WHERE event_id = NEW.event_id AND division_id = NEW.division_id;

		DECLARE
			v_event_id ss_round_details.event_id%TYPE;
			v_division_id ss_round_details.division_id%TYPE;
			v_num_rounds ss_event_divisions.num_rounds%TYPE;
			v_count INT; 
			v_round_name TEXT; 

			v_round_list_2 TEXT[] := ARRAY['Qualifications', 'Finals']; 
			v_round_list_3 TEXT[] := ARRAY['Qualifications', 'Semi-Finals', 'Finals'];
			v_round_list_4 TEXT[] := ARRAY['Qualifications', 'Quarter-Finals', 'Semi-Finals', 'Finals'];

		BEGIN
			v_event_id := NEW.event_id;
			v_division_id := NEW.division_id;
			v_num_rounds := NEW.num_rounds;

			IF (v_num_rounds = 1) THEN
			INSERT INTO ss_round_details (event_id, division_id, round_name, num_heats) 
				VALUES (v_event_id, v_division_id, 'Finals', DEFAULT); 

			ELSEIF (v_num_rounds = 2) THEN
			v_count := 1;
			WHILE (v_count <= v_num_rounds) LOOP
				v_round_name := v_round_list_2[v_count];
				INSERT INTO ss_round_details (event_id, division_id, round_name, num_heats) 
				VALUES (v_event_id, v_division_id, v_round_name, DEFAULT);
				v_count := v_count + 1;
			END LOOP; 

			ELSEIF (v_num_rounds = 3) THEN
			v_count := 1;
			WHILE (v_count <= v_num_rounds) LOOP
				v_round_name := v_round_list_3[v_count];
				INSERT INTO ss_round_details (event_id, division_id, round_name, num_heats) 
				VALUES (v_event_id, v_division_id, v_round_name, DEFAULT);
				v_count := v_count + 1;
			END LOOP; 

			ELSEIF (v_num_rounds = 4) THEN
			v_count := 1;
			WHILE (v_count <= v_num_rounds) LOOP
				v_round_name := v_round_list_4[v_count];
				INSERT INTO ss_round_details (event_id, division_id, round_name, num_heats) 
				VALUES (v_event_id, v_division_id, v_round_name, DEFAULT);
				v_count := v_count + 1;
			END LOOP; 
			END IF;
		END;
    END IF;
    RETURN NEW;
END;
$function$ LANGUAGE plpgsql;


CREATE TRIGGER trg_handle_update_on_event_division
	AFTER UPDATE ON ss_event_divisions
	FOR EACH ROW
	EXECUTE FUNCTION handle_update_on_event_division();