DROP FUNCTION IF EXISTS handle_insert_on_event_registrations() CASCADE;
DROP FUNCTION IF EXISTS reseed_affected_heats() CASCADE;

CREATE OR REPLACE FUNCTION handle_insert_on_event_registrations()
    RETURNS trigger
	AS $function$
DECLARE
    target_round_heat_id INT;
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ss_heat_results hr
        JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
        JOIN ss_round_details rd ON hd.round_id = rd.round_id
        WHERE hr.athlete_id = NEW.athlete_id
            AND rd.event_id = NEW.event_id
            AND rd.division_id = NEW.division_id
    ) THEN
        RAISE NOTICE 'Athlete ID % is already assigned to a heat for this event/division. No action taken.', NEW.athlete_id;
        RETURN NEW;
    END IF;

    SELECT
        hd.round_heat_id INTO target_round_heat_id
    FROM
        ss_round_details AS rd
    JOIN
        ss_heat_details AS hd ON rd.round_id = hd.round_id
    WHERE
        rd.event_id = NEW.event_id
        AND rd.division_id = NEW.division_id
        AND rd.round_num = 1 
        AND hd.heat_num = 1
    LIMIT 1;

    IF target_round_heat_id IS NULL THEN
        RAISE EXCEPTION 'Registration failed: Round 1, Heat 1 is not defined for event_id=%, division_id=%.', NEW.event_id, NEW.division_id
        USING HINT = 'Please ensure that at least one round (with round_num=1) and one heat (with heat_num=1) have been created for this event and division.';
    END IF;

    INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
    VALUES (target_round_heat_id, NEW.event_id, NEW.division_id, NEW.athlete_id, 0);

    CALL reseed_heat(target_round_heat_id);

    RETURN NEW;
END;
$function$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION reseed_affected_heats()
    RETURNS TRIGGER AS $function$
DECLARE
    v_round_heat_id INTEGER;
BEGIN
    FOR v_round_heat_id IN
        SELECT DISTINCT hd.round_heat_id
        FROM new_rows AS nr 
        INNER JOIN ss_round_details AS rd ON nr.event_id = rd.event_id AND nr.division_id = rd.division_id
        INNER JOIN ss_heat_details AS hd ON rd.round_id = hd.round_id
    LOOP
        CALL reseed_heat(v_round_heat_id);
    END LOOP;
    RETURN NULL; 
END;
$function$ LANGUAGE plpgsql;


CREATE TRIGGER trg_handle_insert_on_event_registrations
	AFTER INSERT ON ss_event_registrations
	FOR EACH ROW 
	EXECUTE FUNCTION handle_insert_on_event_registrations();


CREATE TRIGGER trg_reseed_affected_heats
	AFTER INSERT ON ss_event_registrations
	REFERENCING NEW TABLE AS new_rows
	FOR EACH STATEMENT EXECUTE FUNCTION reseed_affected_heats();
