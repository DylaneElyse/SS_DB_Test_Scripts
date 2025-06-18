CREATE OR REPLACE FUNCTION handle_update_on_heat_details()
  RETURNS TRIGGER AS $trigger$
DECLARE
    v_old_event_id    INTEGER;
    v_old_division_id INTEGER;
    v_new_event_id    INTEGER;
    v_new_division_id INTEGER;
BEGIN
    IF NEW.round_id IS DISTINCT FROM OLD.round_id THEN
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
    END IF;

    -- Reseed if the heat itself changes or if it moves to a new round (within the same division)
    IF NEW.heat_id IS DISTINCT FROM OLD.heat_id OR NEW.round_id IS DISTINCT FROM OLD.round_id THEN
        CALL reseed_heat(NEW.heat_id);
    END IF;

    RETURN NEW;
END;
$trigger$ LANGUAGE plpgsql;


CREATE TRIGGER trg_sync_on_heat_details_update
AFTER UPDATE ON ss_heat_details
FOR EACH ROW
EXECUTE FUNCTION handle_update_on_heat_details();