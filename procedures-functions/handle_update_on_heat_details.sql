DROP FUNCTION IF EXISTS handle_update_on_heat_details() CASCADE;

CREATE OR REPLACE FUNCTION handle_update_on_heat_details()
    RETURNS TRIGGER 
    AS $trigger$
DECLARE
    v_old_event_id    INTEGER;
    v_old_division_id INTEGER;
    v_new_event_id    INTEGER;
    v_new_division_id INTEGER;
BEGIN
    IF NEW.num_runs IS DISTINCT FROM OLD.num_runs THEN
        
        SELECT rd.event_id, rd.division_id
        INTO v_old_event_id, v_old_division_id
        FROM ss_round_details AS rd
        WHERE rd.round_id = OLD.round_id;

        SELECT rd.event_id, rd.division_id
        INTO v_new_event_id, v_new_division_id
        FROM ss_round_details AS rd
        WHERE rd.round_id = NEW.round_id;

        IF v_new_event_id IS DISTINCT FROM v_old_event_id OR v_new_division_id IS DISTINCT FROM v_old_division_id THEN
            RAISE EXCEPTION 'Invalid Operation: Cannot move heat to a different event or division.'
                USING HINT = 'To move athletes, please update their entries in the ss_event_registrations table first.';
        END IF;

        RAISE NOTICE 'num_runs changed for round_heat_id=%. Deleting and re-adding athlete results.', NEW.round_heat_id;
        DELETE FROM ss_heat_results WHERE round_heat_id = NEW.round_heat_id;

        INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
        SELECT
            NEW.round_heat_id,
            rd.event_id,
            rd.division_id,
            reg.athlete_id,
            0 
        FROM
            ss_event_registrations AS reg
        INNER JOIN ss_round_details AS rd ON reg.event_id = rd.event_id AND reg.division_id = rd.division_id
        WHERE
            rd.round_id = NEW.round_id
            AND NOT EXISTS (
                SELECT 1
                FROM ss_heat_results AS existing_hr
                INNER JOIN ss_heat_details AS existing_hd ON existing_hr.round_heat_id = existing_hd.round_heat_id
                WHERE
                    existing_hd.round_id = NEW.round_id 
                    AND existing_hr.athlete_id = reg.athlete_id 
            )
        ON CONFLICT (round_heat_id, athlete_id) DO NOTHING;
        
        CALL reseed_heat(NEW.round_heat_id);

    END IF;

    IF NEW.round_heat_id IS DISTINCT FROM OLD.round_heat_id OR NEW.round_id IS DISTINCT FROM OLD.round_id THEN
        CALL reseed_heat(NEW.round_heat_id);
    END IF;

    RETURN NEW;
END;
$trigger$ LANGUAGE plpgsql;


CREATE TRIGGER trg_handle_update_on_heat_details
	AFTER UPDATE ON ss_heat_details
	FOR EACH ROW
	EXECUTE FUNCTION handle_update_on_heat_details();