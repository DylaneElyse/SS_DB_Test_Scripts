CREATE OR REPLACE FUNCTION handle_insert_on_heat_details()
  RETURNS TRIGGER AS $trigger$
BEGIN
    INSERT INTO ss_heat_results (heat_id, event_id, division_id, athlete_id, seeding)
    SELECT
        NEW.heat_id,
        rd.event_id,
        rd.division_id,
        reg.athlete_id,
        0
    FROM ss_event_registrations AS reg
    INNER JOIN ss_round_details AS rd
        ON reg.event_id = rd.event_id AND reg.division_id = rd.division_id
    WHERE rd.round_id = NEW.round_id
      AND NOT EXISTS (
        SELECT 1
        FROM ss_heat_results AS existing_hr
        INNER JOIN ss_heat_details AS existing_hd
            ON existing_hr.heat_id = existing_hd.heat_id
        WHERE existing_hd.round_id = NEW.round_id
          AND existing_hr.athlete_id = reg.athlete_id
      )
    ON CONFLICT (heat_id, athlete_id) DO NOTHING;

    IF NOT FOUND THEN
        RAISE NOTICE 'Heat created (heat_id=%), but no available athletes were found to add.', NEW.heat_id;
    END IF;

    CALL reseed_heat(NEW.heat_id);

    RETURN NEW;
END;
$trigger$ LANGUAGE plpgsql;


CREATE TRIGGER trg_populate_new_heat
AFTER INSERT ON ss_heat_details
FOR EACH ROW
EXECUTE FUNCTION handle_insert_on_heat_details();