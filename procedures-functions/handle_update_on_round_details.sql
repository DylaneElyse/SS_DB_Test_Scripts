DROP TRIGGER IF EXISTS trg_sync_heats_on_round_update ON ss_round_details;
DROP FUNCTION IF EXISTS handle_update_on_round_details();

CREATE OR REPLACE FUNCTION handle_update_on_round_details()
    RETURNS TRIGGER AS $trigger$
BEGIN
    IF NEW.num_heats IS DISTINCT FROM OLD.num_heats THEN
        DELETE FROM ss_heat_details
        WHERE round_id = OLD.round_id; 

        IF NEW.num_heats > 0 THEN
            INSERT INTO ss_heat_details (round_id, heat_num)
            SELECT
                NEW.round_id,
                i
            FROM generate_series(1, NEW.num_heats) AS i;
        END IF;
    END IF;

    RETURN NEW;
END;
$trigger$ LANGUAGE plpgsql;


CREATE TRIGGER trg_handle_update_on_round_details
	AFTER UPDATE ON ss_round_details
	FOR EACH ROW
	EXECUTE FUNCTION handle_update_on_round_details();