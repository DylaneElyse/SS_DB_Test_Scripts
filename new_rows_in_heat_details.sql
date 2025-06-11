DROP FUNCTION IF EXISTS handle_insert_on_heat_details() CASCADE;

CREATE OR REPLACE FUNCTION handle_insert_on_heat_details()
RETURNS TRIGGER AS $$
BEGIN
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
    ON CONFLICT (round_heat_id, athlete_id) DO NOTHING;

    IF NOT FOUND THEN
        RAISE NOTICE 'Heat created (round_heat_id=%), but no athletes were added as none are registered.', NEW.round_heat_id;
    END IF;

    CALL reseed_heat(NEW.round_heat_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_populate_new_heat
AFTER INSERT ON ss_heat_details
FOR EACH ROW
EXECUTE FUNCTION handle_insert_on_heat_details();