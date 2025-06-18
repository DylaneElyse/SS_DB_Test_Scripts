CREATE OR REPLACE FUNCTION handle_update_on_event_registrations()
  RETURNS TRIGGER AS $trigger$
BEGIN
    IF NEW.event_id IS DISTINCT FROM OLD.event_id OR NEW.division_id IS DISTINCT FROM OLD.division_id THEN
        DELETE FROM ss_heat_results AS shr
        USING
            ss_heat_details AS hd
            INNER JOIN ss_round_details AS rd ON hd.round_id = rd.round_id
        WHERE rd.event_id = OLD.event_id
          AND rd.division_id = OLD.division_id
          AND shr.heat_id = hd.heat_id
          AND shr.athlete_id = OLD.athlete_id;

        INSERT INTO ss_heat_results (heat_id, event_id, division_id, athlete_id, seeding)
        SELECT
            hd.heat_id,
            NEW.event_id,
            NEW.division_id,
            NEW.athlete_id,
            0
        FROM ss_round_details AS rd
        INNER JOIN ss_heat_details AS hd
            ON rd.round_id = hd.round_id
        WHERE rd.event_id = NEW.event_id
          AND rd.division_id = NEW.division_id
        ON CONFLICT (heat_id, athlete_id) DO NOTHING;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Update failed: Cannot move registration. No heats are defined for the destination: event_id=%, division_id=%.', NEW.event_id, NEW.division_id
                USING HINT = 'Please create at least one round and one heat for the target event/division before updating the registration.';
        END IF;
    END IF;

    RETURN NEW;
END;
$trigger$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION reseed_after_update()
  RETURNS TRIGGER AS $trigger$
DECLARE
    v_heat_id INTEGER;
BEGIN
    FOR v_heat_id IN
        SELECT DISTINCT hd.heat_id
        FROM old_rows AS o
        JOIN ss_round_details AS rd ON rd.event_id = o.event_id AND rd.division_id = o.division_id
        JOIN ss_heat_details AS hd ON hd.round_id = rd.round_id
        UNION
        SELECT DISTINCT hd.heat_id
        FROM new_rows AS n
        JOIN ss_round_details AS rd ON rd.event_id = n.event_id AND rd.division_id = n.division_id
        JOIN ss_heat_details AS hd ON hd.round_id = rd.round_id
    LOOP
        CALL reseed_heat(v_heat_id);
    END LOOP;

    RETURN NULL;
END;
$trigger$ LANGUAGE plpgsql;


CREATE TRIGGER trg_handle_update_on_event_registrations
AFTER UPDATE ON ss_event_registrations
FOR EACH ROW EXECUTE FUNCTION handle_update_on_event_registrations();

CREATE TRIGGER trg_reseed_after_update
AFTER UPDATE ON ss_event_registrations
REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows
FOR EACH STATEMENT EXECUTE FUNCTION reseed_after_update();