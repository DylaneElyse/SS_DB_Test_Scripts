CREATE OR REPLACE FUNCTION public.handle_insert_on_round_details()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_event_id ss_round_details.event_id%TYPE;
  v_division_id ss_round_details.division_id%TYPE;
  v_round_id ss_round_details.round_id%TYPE;
  v_num_heats ss_round_details.num_heats%TYPE;
  v_count INT;

BEGIN
  v_event_id := NEW.event_id;
  v_division_id := NEW.division_id;
  v_round_id := NEW.round_id;
  v_num_heats := NEW.num_heats;
  v_count := 1;

  WHILE (v_count <= v_num_heats) LOOP
    INSERT INTO ss_heat_details (heat_num, num_runs, round_id) 
      VALUES (v_count, DEFAULT, v_round_id);
    v_count := v_count + 1;
  END LOOP; 

  RETURN NEW;
END;
$function$


-- CREATE OR REPLACE FUNCTION handle_insert_on_round_details()
-- RETURNS TRIGGER AS $$
-- DECLARE
--   v_event_id ss_round_details.event_id%TYPE;
--   v_division_id ss_round_details.division_id%TYPE;
--   v_round_id ss_round_details.round_id%TYPE;
--   v_num_heats ss_round_details.num_heats%TYPE;
--   v_count INT;

-- BEGIN
--   v_event_id := NEW.event_id;
--   v_division_id := NEW.division_id;
--   v_round_id := NEW.round_id;
--   v_num_heats := NEW.num_heats;
--   v_count := 1;

--   WHILE (v_count <= v_num_heats) LOOP
--     INSERT INTO ss_heat_details (heat_num, num_runs, round_id) 
--       VALUES (v_count, DEFAULT, v_round_id);
--     v_count := v_count + 1;
--   END LOOP; 

--   RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_insert_on_round_details
AFTER INSERT ON ss_round_details
FOR EACH ROW
EXECUTE FUNCTION handle_insert_on_round_details();

DROP TRIGGER IF EXISTS trg_after_insert_on_round_details ON ss_round_details;