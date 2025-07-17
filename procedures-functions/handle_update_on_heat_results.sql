CREATE OR REPLACE FUNCTION handle_update_on_heat_results()
    RETURNS TRIGGER AS $function$
BEGIN
    IF NEW.event_id IS DISTINCT FROM OLD.event_id OR
        NEW.division_id IS DISTINCT FROM OLD.division_id OR
        NEW.athlete_id IS DISTINCT FROM OLD.athlete_id
    THEN
        UPDATE ss_run_results
        SET
            event_id = NEW.event_id,
            division_id = NEW.division_id,
            athlete_id = NEW.athlete_id
        WHERE
            heat_id = OLD.heat_id AND
            event_id = OLD.event_id AND
            division_id = OLD.division_id AND
            athlete_id = OLD.athlete_id;
    END IF;

    RETURN NULL;
END;
$function$ LANGUAGE plpgsql;


CREATE TRIGGER trg_handle_update_on_heat_results
	AFTER UPDATE ON ss_heat_results
	FOR EACH ROW
	EXECUTE FUNCTION handle_update_on_heat_results();