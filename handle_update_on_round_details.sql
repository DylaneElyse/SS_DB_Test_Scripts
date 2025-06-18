CREATE OR REPLACE FUNCTION handle_update_on_round_details()
  RETURNS TRIGGER AS $trigger$
BEGIN
    IF NEW.num_heats IS DISTINCT FROM OLD.num_heats THEN
        DELETE FROM ss_heat_details
        WHERE round_id = NEW.round_id;

        IF NEW.num_heats > 0 THEN
            INSERT INTO ss_heat_details (round_id, heat_num, num_runs)
            SELECT
                NEW.round_id,
                i,
                DEFAULT
            FROM generate_series(1, NEW.num_heats) AS i;
        END IF;
    END IF;

    RETURN NEW;
END;
$trigger$ LANGUAGE plpgsql;


CREATE TRIGGER trg_sync_heats_on_round_update
AFTER UPDATE ON ss_round_details
FOR EACH ROW
EXECUTE FUNCTION handle_update_on_round_details();