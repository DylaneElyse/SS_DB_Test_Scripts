CREATE OR REPLACE FUNCTION handle_insert_on_event_registrations()
  RETURNS TRIGGER AS $trigger$
BEGIN
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
        RAISE EXCEPTION 'Registration failed: No heats are defined for event_id=%, division_id=%.', NEW.event_id, NEW.division_id
            USING HINT = 'Please ensure that at least one round and one heat have been created for this event and division before registering athletes.';
    END IF;

    RETURN NEW;
END;
$trigger$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION reseed_affected_heats()
  RETURNS TRIGGER AS $trigger$
DECLARE
    v_heat_id INTEGER;
BEGIN
    FOR v_heat_id IN
        SELECT DISTINCT hd.heat_id
        FROM new_rows AS nr
        INNER JOIN ss_round_details AS rd
            ON nr.event_id = rd.event_id AND nr.division_id = rd.division_id
        INNER JOIN ss_heat_details AS hd
            ON rd.round_id = hd.round_id
    LOOP
        CALL reseed_heat(v_heat_id);
    END LOOP;

    RETURN NULL;
END;
$trigger$ LANGUAGE plpgsql;


CREATE TRIGGER trg_handle_insert_on_event_registrations
AFTER INSERT ON ss_event_registrations
FOR EACH ROW EXECUTE FUNCTION handle_insert_on_event_registrations();

CREATE TRIGGER trg_reseed_affected_heats
AFTER INSERT ON ss_event_registrations
REFERENCING NEW TABLE AS new_rows
FOR EACH STATEMENT EXECUTE FUNCTION reseed_affected_heats();
